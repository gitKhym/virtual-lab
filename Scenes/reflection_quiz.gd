extends Node2D

var d

func _ready() -> void:
	d = Dialogic.start("Question23")
	if d and d.get_parent() == null:
		d.name = "DialogicNode"
		add_child(d)
