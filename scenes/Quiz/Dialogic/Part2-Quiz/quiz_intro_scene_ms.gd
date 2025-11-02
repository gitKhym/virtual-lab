extends Node2D

var dialog

func _ready() -> void:
	dialog = Dialogic.start("res://scenes/Quiz/Dialogic/Part2-Quiz/Quiz-Intro.dtl")
	if dialog:
		await dialog.tree_exited
	SaveManager.complete_mode("completed_microscope")
	SceneTransistion.change_scene("res://scenes/main_menu2/main_menu_2.tscn")
