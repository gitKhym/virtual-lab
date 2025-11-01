extends Node2D

# --- Constants ---
const BALANCE_DATA_PATH: String = "res://data/Measurements/balance_data.json"
const INTRO: String = "res://dialogic/dialogs/measurement/MeasurementIntroduction.dtl"

# --- Node references ---
@onready var S: Node2D = $Scale
@onready var IC: Node2D = $itemcontainer
@onready var UI: CanvasLayer = $UI
@onready var scale_display: Label = $Scale/Display
@onready var tare_button: TextureButton = $Scale/Tare
@onready var instruction_label: Label = $UI/uibackground/instructionlabel
@onready var feedback_label: Label = $UI/uibackground/feedbacklabel
@onready var item_container: Node2D = $itemcontainer
@onready var washer: Sprite2D = $itemcontainer/washersmall
@onready var hitmarker: Marker2D = $hitmarker
@onready var ui_handler: CanvasLayer = $UI

# --- Game state ---
var tare_applied: bool = false
var current_mass_g: float = 0.0
var washer_data: Dictionary = {}
var active_washer_name: String = "washer"
var completed_conversions: Array[String] = []

# -------------------------------------------------------------
func _ready() -> void:
	_validate_nodes()
	_initialize_ui()
	_connect_signals()
	_load_washer_data()
	_hide_all_game_nodes()
	var dlg = Dialogic.start(INTRO, "Balance_introduction")
	if dlg:
		await dlg.tree_exited
	SceneReset.play_transition('dissolve')
	await get_tree().create_timer(1.0).timeout
	_show_all_game_nodes()


func _hide_all_game_nodes() -> void:
	if UI:
		UI.visible = false
	if IC:
		IC.visible = false
	if S:
		S.visible = false

func _show_all_game_nodes() -> void:
	if UI:
		UI.visible = true
	if IC:
		IC.visible = true
	if S:
		S.visible = true
		
func _validate_nodes() -> void:
	var critical_nodes := [scale_display, tare_button, instruction_label, feedback_label, item_container, washer, hitmarker, ui_handler]
	for node in critical_nodes:
		if not node:
			push_error("Required node not found: %s" % node.name)

func _initialize_ui() -> void:
	scale_display.text = "0.00 g"
	instruction_label.text = "Click the Tare button to get started!"
	feedback_label.text = ""
	tare_applied = false
	completed_conversions.clear()

	if ui_handler.has_method("_initialize_ui_hidden"):
		ui_handler._initialize_ui_hidden()

func _connect_signals() -> void:
	if tare_button and not tare_button.pressed.is_connected(_on_tare_pressed):
		tare_button.pressed.connect(_on_tare_pressed)

# -------------------------------------------------------------
func _load_washer_data() -> void:
	if not FileAccess.file_exists(BALANCE_DATA_PATH):
		push_error("Data file not found: %s" % BALANCE_DATA_PATH)
		return
	
	var file: FileAccess = FileAccess.open(BALANCE_DATA_PATH, FileAccess.READ)
	if not file:
		push_error("Failed to open data file: %s" % BALANCE_DATA_PATH)
		return
	
	var json: Variant = JSON.parse_string(file.get_as_text())
	if json == null or not json.has("washers"):
		push_error("Invalid JSON or missing 'washers' key in: %s" % BALANCE_DATA_PATH)
		return
	
	washer_data = json.washers

# -------------------------------------------------------------
func _on_tare_pressed() -> void:
	if ui_handler and ui_handler.conversion_complete:
		await _handle_completion_reset()
		return

	# Normal tare behavior
	tare_applied = true
	current_mass_g = 0.0
	scale_display.text = "0.00 g"
	feedback_label.text = "Balance tared! You can now weigh the item."
	instruction_label.text = "Drag the item onto the scale to weigh it."

	if item_container.has_method("reset_position"):
		item_container.reset_position()

	if ui_handler.has_method("_initialize_ui_hidden"):
		ui_handler._initialize_ui_hidden()

func _handle_completion_reset() -> void:
	if item_container and item_container.has_method("slide_off_and_disappear"):
		await item_container.slide_off_and_disappear()
	
	ui_handler.reset_ui_state()
	scale_display.text = "0.00 g"
	tare_applied = false
	current_mass_g = 0.0
	feedback_label.text = ""
	instruction_label.text = "Click the Tare button to reset the balance."

# -------------------------------------------------------------
func _on_washer_dropped() -> void:
	await get_tree().process_frame
	_update_active_washer_name()

	if not tare_applied:
		feedback_label.text = "Oops! Always tare before weighing."
		current_mass_g = _get_current_mass() 
	else:
		current_mass_g = _get_current_mass()
		feedback_label.text = "Item placed correctly! Weight recorded."

	scale_display.text = "%.2f g" % current_mass_g

	if ui_handler and ui_handler.has_method("show_conversion_ui"):
		ui_handler.show_conversion_ui()

func _update_active_washer_name() -> void:
	var washer_names := ["washerstacked", "washermedium", "washersmall", "weight"]
	for washer_name in washer_names:
		if item_container.has_node(washer_name) and item_container.get_node(washer_name).visible:
			active_washer_name = washer_name
			return
	active_washer_name = "washer"

func _get_current_mass() -> float:
	if washer_data.has(active_washer_name) and washer_data[active_washer_name].has("mass_g"):
		return washer_data[active_washer_name]["mass_g"]
	
	push_warning("Item mass not found for: " + active_washer_name)
	return 0.0

# -------------------------------------------------------------
func mark_conversion_complete(washer_name: String) -> void:
	if not washer_name in completed_conversions:
		completed_conversions.append(washer_name)
		print("Conversion completed for: ", washer_name)
		_check_all_conversions_complete()

func _check_all_conversions_complete() -> void:
	var all_washers := ["washerstacked", "washermedium", "washersmall", "weight"]
	var all_completed := true
	
	for washer_name in all_washers:
		if not washer_name in completed_conversions:
			all_completed = false
			break
	
	if all_completed:
		await get_tree().create_timer(1.0).timeout


func reset_all_progress() -> void:
	completed_conversions.clear()
	_initialize_ui()
	if item_container.has_method("reset_all_items"):
		item_container.reset_all_items()
