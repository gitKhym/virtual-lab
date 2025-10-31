extends Node2D

var dialog

func _ready() -> void:
	dialog = Dialogic.start("Quiz-Intro")
	add_child(dialog)
