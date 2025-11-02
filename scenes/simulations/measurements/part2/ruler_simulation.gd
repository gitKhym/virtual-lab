extends Node2D

const WASHER_DATA_PATH: String = "res://data/Measurements/washer_data.json"
const INTRO: String = "res://dialogic/dialogs/measurement/MeasurementIntroduction.dtl"
const SNAP_DISTANCE: float = 5.0
const CONVERSION_TOLERANCE: float = 0.001
# --- Node references ---
@onready var UI: CanvasLayer = $UI
@onready var WC: Node2D = $washercontainer
@onready var R: Node2D = $ruler
@onready var washers: Dictionary = _initialize_washers()
@onready var washer_marker: Marker2D = $washercontainer/washersmall/hitmarker
@onready var down_arrow: Node2D = $washercontainer/washersmall/downarrow
@onready var ruler_zero: Marker2D = $ruler/asset/zeromark
@onready var feedback: Label = $UI/uibackground/FeedbackLabel
@onready var instruction: Label = $UI/uibackground/InstructionLabel
@onready var ruler: Node2D = $ruler
@onready var cm_label: Label = $UI/measurementbackground/MeasurementLabel
@onready var meters_container: Sprite2D = $UI/Meters
@onready var mm_container: Sprite2D = $UI/Millimetres
@onready var confirm_button: TextureButton = $UI/Confirm
@onready var meters_input: LineEdit = $UI/Meters/MetersLabel
@onready var mm_input: LineEdit = $UI/Millimetres/MillimetresLabel

var washer_order: Array[String] = ["washersmall", "washermedium", "washerlarge"]
var current_index: int = 0
var locked: bool = false
var washer_data: Dictionary = {}
var measured_values: Dictionary = {}
var ruler_start_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	_validate_critical_nodes()
	_initialize_ui()
	_initialize_washers_visibility()
	_connect_signals()
	_load_washer_data()
	var dlg = Dialogic.start(INTRO, "Ruler_Introduction")
	if dlg:
		await dlg.tree_exited
	
func _validate_critical_nodes() -> void:
	var critical_nodes := [washer_marker, down_arrow, ruler_zero, feedback, instruction, ruler, confirm_button]
	for node in critical_nodes:
		if not node:
			push_error("Missing required node: %s" % node.name)

func _initialize_ui() -> void:
	down_arrow.visible = false
	instruction.text = "Drag the ruler and 
	align the  0  mark with the washer edge."
	feedback.text = ""
	
	for node in [meters_container, mm_container, confirm_button]:
		if node:
			node.visible = false
	
	ruler_start_pos = ruler.global_position

func _initialize_washers_visibility() -> void:
	for i in washer_order.size():
		var washer_name: String = washer_order[i]
		if washers.has(washer_name) and washers[washer_name]:
			washers[washer_name].visible = (i == 0)
			washers[washer_name].modulate.a = 1.0

func _connect_signals() -> void:
	if confirm_button and not confirm_button.pressed.is_connected(_on_confirm_pressed):
		confirm_button.pressed.connect(_on_confirm_pressed)


func _process(_delta: float) -> void:
	if locked or not _are_marker_nodes_valid():
		return
	
	if ruler_zero.global_position.distance_to(washer_marker.global_position) <= SNAP_DISTANCE:
		snap_to_marker()

func _are_marker_nodes_valid() -> bool:
	return washer_marker and ruler_zero and is_instance_valid(washer_marker) and is_instance_valid(ruler_zero)


func snap_to_marker() -> void:
	locked = true
	
	var offset: Vector2 = washer_marker.global_position - ruler_zero.global_position
	ruler.global_position += offset
	ruler.set_process_input(false)
	
	_update_measured_values()
	_update_ui_after_snap()
	_animate_arrow()
	_show_conversion_ui()

func _update_measured_values() -> void:
	var washer_name: String = washer_marker.get_parent().name
	if washer_data.has(washer_name):
		measured_values = washer_data[washer_name].duplicate()
	else:
		measured_values = {"size_cm": 0.0, "size_m": 0.0, "size_mm": 0.0}
		push_warning("Missing washer data for: %s" % washer_name)

func _update_ui_after_snap() -> void:
	var washer_name: String = washer_marker.get_parent().name
	var readable_name: String = washer_name.replace("washer", "").capitalize()
	
	instruction.text = "Perfect! The ruler is in place!
	The %s washer measures %.1f cm." % [readable_name, measured_values.size_cm]
	feedback.text = "Now convert the value 
	to both millimetres and meters."

func _animate_arrow() -> void:
	if not down_arrow:
		return
	
	down_arrow.visible = true
	down_arrow.scale = Vector2.ZERO
	
	var tween: Tween = create_tween()
	tween.tween_property(down_arrow, "scale", Vector2(1.8, 1.8), 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(down_arrow, "scale", Vector2(2.0, 2.0), 0.15).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(down_arrow, "scale", Vector2(1.8, 1.8), 0.1)

func _show_conversion_ui() -> void:
	var ui_nodes: Array = [cm_label, meters_container, mm_container, confirm_button]
	var visible_nodes: Array = ui_nodes.filter(func(node): return node != null)
	
	for node in visible_nodes:
		node.visible = true
		node.modulate.a = 0.0
	
	var fade_tween: Tween = create_tween()
	for node in visible_nodes:
		fade_tween.tween_property(node, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)
	
	if cm_label:
		cm_label.text = "Measured: %.1f cm" % measured_values.size_cm


func _on_confirm_pressed() -> void:
	if not _validate_inputs():
		feedback.text = "Please enter valid numbers in both boxes."
		return
	
	var entered_m: float = meters_input.text.to_float()
	var entered_mm: float = mm_input.text.to_float()
	
	var m_correct: bool = is_equal_approx(entered_m, measured_values.size_m)
	var mm_correct: bool = is_equal_approx(entered_mm, measured_values.size_mm)
	
	_handle_conversion_result(m_correct, mm_correct)

func _validate_inputs() -> bool:
	return meters_input.text.is_valid_float() and mm_input.text.is_valid_float()

func is_equal_approx(a: float, b: float, tolerance: float = CONVERSION_TOLERANCE) -> bool:
	return abs(a - b) < tolerance

func _handle_conversion_result(m_correct: bool, mm_correct: bool) -> void:
	if m_correct and mm_correct:
		feedback.text = "Correct!"
		instruction.text = "Great work. Moving to the next washer..."
		await get_tree().create_timer(1.2).timeout
		_advance_to_next_washer()
	elif m_correct:
		feedback.text = "M value is correct, but MM value is incorrect.\nHint: Multiply CM by 10 to get MM \n(move decimal right 1 place)."
	elif mm_correct:
		feedback.text = "MM value is correct, but M value is incorrect.\nHint: Divide CM by 100 to get M \n(move decimal left 2 places)."
	else:
		feedback.text = "Both conversion values are incorrect.\nHint: For CM to MM: ×10 (decimal right 1)\nFor CM to M: ÷100 (decimal left 2)"


func _advance_to_next_washer() -> void:
	if current_index + 1 >= washer_order.size():
		feedback.text = "All washers completed!"
		instruction.text = "You've finished all measurements!"
		await get_tree().create_timer(2.0).timeout
		SceneTransistion.change_scene("res://scenes/simulations/measurements/part3/balance_game.tscn")
		return
	
	var current_name: String = washer_order[current_index]
	var next_name: String = washer_order[current_index + 1]
	
	if not _validate_washer_nodes(current_name, next_name):
		return
	
	await _transition_to_next_washer(current_name, next_name)
	_reset_ui_state()

func _validate_washer_nodes(current_name: String, next_name: String) -> bool:
	return washers.has(current_name) and washers[current_name] and washers.has(next_name) and washers[next_name]

func _transition_to_next_washer(current_name: String, next_name: String) -> void:
	SceneReset.play_transition('dissolve')
	
	var fade_out: Tween = create_tween()
	fade_out.tween_property(washers[current_name], "modulate:a", 0.0, 0.5)
	await fade_out.finished
	
	washers[current_name].visible = false
	current_index += 1
	washers[next_name].visible = true
	washers[next_name].modulate.a = 0.0
	
	_update_washer_references(next_name)
	_reset_ruler_position()
	
	var fade_in: Tween = create_tween()
	fade_in.tween_property(washers[next_name], "modulate:a", 1.0, 0.3)
	await fade_in.finished

func _update_washer_references(washer_name: String) -> void:
	washer_marker = get_node_or_null("washercontainer/%s/hitmarker" % washer_name) as Marker2D
	down_arrow = get_node_or_null("washercontainer/%s/downarrow" % washer_name) as Node2D
	
	if not washer_marker:
		push_error("Missing washer marker for: %s" % washer_name)
	if not down_arrow:
		push_error("Missing down arrow for: %s" % washer_name)

func _reset_ruler_position() -> void:
	if ruler.has_method("disable_dragging"):
		ruler.disable_dragging()
	
	ruler.set_process_input(false)
	ruler.global_position = ruler_start_pos
	
	await get_tree().create_timer(0.1).timeout
	
	if ruler.has_method("enable_dragging"):
		ruler.enable_dragging()
	ruler.set_process_input(true)

func _reset_ui_state() -> void:
	locked = false
	if down_arrow:
		down_arrow.visible = false
	
	instruction.text = "Drag the ruler and 
	align the 0 mark with the washer's edge."
	feedback.text = ""
	
	[meters_container, mm_container, confirm_button].map(func(node): 
		if node: 
			node.visible = false
	)
	
	meters_input.text = ""
	mm_input.text = ""


func _load_washer_data() -> void:
	if not FileAccess.file_exists(WASHER_DATA_PATH):
		push_error("Washer data file not found: %s" % WASHER_DATA_PATH)
		return
	
	var file: FileAccess = FileAccess.open(WASHER_DATA_PATH, FileAccess.READ)
	if not file:
		push_error("Could not open file: %s" % WASHER_DATA_PATH)
		return
	
	var json: Variant = JSON.parse_string(file.get_as_text())
	if json == null or not json.has("washers"):
		push_error("Invalid JSON or missing 'washers' key in: %s" % WASHER_DATA_PATH)
		return
	
	washer_data = json.washers

func _initialize_washers() -> Dictionary:
	var washer_container := $washercontainer
	if not washer_container:
		push_error("Missing washercontainer node")
		return {}
	
	var washer_nodes := {}
	for washer_name in washer_order:
		washer_nodes[washer_name] = washer_container.get_node_or_null(washer_name)
		if not washer_nodes[washer_name]:
			push_error("Missing washer node: %s" % washer_name)
	
	return washer_nodes
