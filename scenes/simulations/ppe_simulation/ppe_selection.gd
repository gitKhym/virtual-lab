extends Area2D

@export var id: String
@export var item_name: String
@export var description: String

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
