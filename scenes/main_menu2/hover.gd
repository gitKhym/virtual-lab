extends Area2D

@onready var shape_visual = $hoverarea

var default_color = Color(0, 0, 0, 0)
var hover_color = Color(0.1, 0.1, 0.1, 0.1)

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	shape_visual.color = default_color

func _on_mouse_entered():
	create_tween().tween_property(shape_visual, "color", hover_color, 0.2)

func _on_mouse_exited():
	create_tween().tween_property(shape_visual, "color", default_color, 0.2)
