extends Sprite2D

@export var item_type: String = ""
@export var item_description: String = ""

@onready var label = $Label


func _ready():
	label.text = item_type
	label.visible = false  # hide description initially


func _on_mouse_entered():
	label.text = item_description
	label.visible = true
	print("Hovering: " + item_type)


func _on_mouse_exited():
	label.visible = false
	print("Hover ended!")
