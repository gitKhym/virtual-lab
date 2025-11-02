extends Node2D

var dialog

func _ready() -> void:
	dialog = Dialogic.start("res://scenes/Quiz/Dialogic/Part3-Quiz/Quiz-Intro.dtl")
	add_child(dialog)
