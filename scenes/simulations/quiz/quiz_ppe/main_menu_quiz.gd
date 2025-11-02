extends Node2D

var dlg

func _ready() -> void:
	dlg = Dialogic.start("QuizStartMenu")  
	add_child(dlg)
	dlg.connect("event", Callable(self, "_on_dialogic_event"))

func _on_dialogic_event(arg: String) -> void:
	if arg == "go_to_question1":
		get_tree().change_scene_to_file("res://scenes/simulations/quiz/quiz_ppe/question1.tscn")
