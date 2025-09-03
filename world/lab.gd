extends Node2D

func _ready() -> void:
	var dlg := Dialogic.start("timeline")  
	add_child(dlg)
