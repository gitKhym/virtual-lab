extends Area2D

# Item data
@export var id: String
var item_name: String
var description: String
var feedback: String
var is_correct: bool

@onready var sprite = $Sprite
@onready var Ui = %UI

@export var float_distance: float = 3.5
@export var float_speed: float = 10.0

var original_position: Vector2
var floating = false
var float_direction = 1.0
var offset = 0.0

func _ready():
	original_position = sprite.position

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
		
		Dialogic.VAR.ItemFeedback.feedback_text = feedback
		Dialogic.start("res://dialogic/dialogs/simulations/ppe/ppe_selection_dialog.dtl")
		
		if is_correct:
			handle_correct()
		else:
			handle_incorrect()

func handle_correct():
	pass
	
func handle_incorrect():
	pass
