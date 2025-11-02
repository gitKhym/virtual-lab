extends Area2D

# Item data
@export var id: String
var item_name: String
var description: String
var feedback: String
var is_correct: bool

var current_is_correct: bool
@onready var sprite = $Sprite
@onready var Ui = %UI
@onready var phase_controller = %Phases

@export var float_distance: float = 3.5
@export var float_speed: float = 10.0

var original_position: Vector2
var floating = false
var float_direction = 1.0
var offset = 0.0


func _ready():
	original_position = sprite.position
	Dialogic.timeline_ended.connect(_on_dialog_finished)


func _process(delta):
	if floating:
		offset += float_direction * float_speed * delta
		if offset > float_distance:
			offset = float_distance
			float_direction = -1
		elif offset < -float_distance:
			offset = -float_distance
			float_direction = 1
		sprite.position = original_position + Vector2(0, -offset)
	else:
		sprite.position = original_position


func _on_mouse_entered():
	Ui.update_text(item_name, description)
	floating = true


func _on_mouse_exited():
	floating = false


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		Dialogic.VAR.Simulations.PPE.selected_item_id = id
		Dialogic.start("res://dialogic/dialogs/simulations/ppe/ppe_selection_dialog.dtl")


func _on_dialog_finished():
	var selected_id = Dialogic.VAR.Simulations.PPE.selected_item_id
	if selected_id != id:
		return
	if is_correct:
		phase_controller.handle_correct()
	else:
		phase_controller.handle_incorrect()
	# ADD THIS: Check if the selected item is "sneakers" and go to next scene
	if selected_id == "sneakers":
		# Wait a moment for any animations to finish
		go_to_next_scene()


func go_to_next_scene():
	var next_scene_path = "res://scenes/simulations/ppe_simulation/ppe_scenarios.tscn"
	await get_tree().create_timer(1.5).timeout
	SceneTransistion.change_scene(next_scene_path)
