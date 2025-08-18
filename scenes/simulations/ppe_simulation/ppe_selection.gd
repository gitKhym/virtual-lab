extends Area2D

@export var id: String
@export var item_name: String
@export var description: String

# Get the UI node directly from the scene tree
@onready var Ui = %UI


func _on_mouse_entered():
	Ui.update_text(item_name, description)


func _on_mouse_exited():
	Ui.clear_text()
