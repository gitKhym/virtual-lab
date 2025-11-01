extends CanvasLayer

# --- Constants ---
const BALANCE_DATA_PATH: String = "res://data/Measurements/balance_data.json"

# --- Node references ---
@onready var kg_container: Sprite2D = $Kilograms
@onready var mg_container: Sprite2D = $Milligrams
@onready var confirm_button: TextureButton = $Confirm
@onready var instruction_label: Label = $uibackground/instructionlabel
@onready var feedback_label: Label = $uibackground/feedbacklabel
@onready var kg_input: LineEdit = $Kilograms/Kilogramslabel
@onready var mg_input: LineEdit = $Milligrams/Milligramslabel

# --- UI Elements ---
@onready var ui_elements: Array = [kg_container, mg_container, confirm_button]

# --- Data ---
var washer_data: Dictionary = {}
var current_mass: Dictionary = {}
var current_washer_name: String = "washer"
var conversion_complete: bool = false

# -------------------------------------------------------------
func _ready() -> void:
	_initialize_ui_hidden()
	_connect_signals()
	_load_washer_data()

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

func _initialize_ui_hidden() -> void:
	for node in ui_elements:
		if node:
			node.visible = false
			node.modulate.a = 0.0

	instruction_label.text = "Drag the item into the scale!"
	feedback_label.text = ""
	kg_input.text = ""
	mg_input.text = ""
	conversion_complete = false

func show_conversion_ui() -> void:
	_update_active_washer_data()

	for node in ui_elements:
		if node:
			node.visible = true
			node.modulate.a = 0.0

	var tween: Tween = create_tween()
	for node in ui_elements:
		if node:
			tween.tween_property(node, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)

	instruction_label.text = "Now convert the item's weight to kilograms and milligrams."
	feedback_label.text = "Enter both values, then press Check."
	conversion_complete = false

func _update_active_washer_data() -> void:
	var item_container: Node2D = get_parent().get_node("itemcontainer")
	if not item_container:
		push_warning("Itemcontainer not found.")
		return

	var washer_names: Array[String] = ["washerstacked", "washermedium", "washersmall", "weight"]
	for washer_name in washer_names:
		if item_container.has_node(washer_name) and item_container.get_node(washer_name).visible:
			current_washer_name = washer_name
			break

	if washer_data.has(current_washer_name):
		var mass_g: float = washer_data[current_washer_name].get("mass_g", 0.0)
		current_mass = {
			"g": mass_g,
			"kg": mass_g / 1000.0,
			"mg": mass_g * 1000.0
		}
	else:
		push_warning("Mass data missing for washer: " + current_washer_name)
		current_mass = {"g": 0.0, "kg": 0.0, "mg": 0.0}

func _connect_signals() -> void:
	if confirm_button and not confirm_button.pressed.is_connected(_on_confirm_pressed):
		confirm_button.pressed.connect(_on_confirm_pressed)

func _on_confirm_pressed() -> void:
	if not _validate_inputs():
		feedback_label.text = "Please enter valid numbers in both boxes."
		return

	var entered_kg: float = kg_input.text.to_float()
	var entered_mg: float = mg_input.text.to_float()

	var kg_correct: bool = entered_kg == current_mass.kg
	var mg_correct: bool = entered_mg == current_mass.mg

	_handle_conversion_result(kg_correct, mg_correct)

func _validate_inputs() -> bool:
	return kg_input.text.is_valid_float() and mg_input.text.is_valid_float()

func _handle_conversion_result(kg_correct: bool, mg_correct: bool) -> void:
	if kg_correct and mg_correct:
		conversion_complete = true
		feedback_label.text = "Correct! Both conversion values are accurate."
		instruction_label.text = "Great work! Press the Tare button to continue."
		_mark_conversion_complete()
	elif kg_correct:
		feedback_label.text =  "KG value is correct, but MG value is incorrect.\nHint: Multiply grams by 1000 to get MG \n(move decimal right 3 places)."
	elif mg_correct:
		feedback_label.text = "MG value is correct, but KG value is incorrect.\nHint: Divide grams by 1000 to get KG \n(move decimal left 3 places)."
	else:
		feedback_label.text = "Both conversion values are incorrect.\nHint: For grams to MG: ×1000 (decimal right 3)\nFor grams to KG: ÷1000 (decimal left 3)"

func _mark_conversion_complete() -> void:
	var parent: Node = get_parent()
	if parent and parent.has_method("mark_conversion_complete"):
		parent.mark_conversion_complete(current_washer_name)

func reset_ui_state() -> void:
	for node in ui_elements:
		if node:
			node.visible = false
			node.modulate.a = 0.0

	kg_input.text = ""
	mg_input.text = ""
	instruction_label.text = "Drag the item into the scale."
	feedback_label.text = ""
	conversion_complete = false
