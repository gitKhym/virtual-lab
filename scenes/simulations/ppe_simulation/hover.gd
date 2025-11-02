extends Area2D

@onready var sprite: Sprite2D = $test

func _ready():
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _on_mouse_entered():
	sprite.modulate = Color(1.3, 1.3, 1.3) # brighten on hover

func _on_mouse_exited():
	sprite.modulate = Color(1, 1, 1) # normal color
