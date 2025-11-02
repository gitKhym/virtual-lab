# quiz_intro_scene.gd  (attach to your Node2D)
extends Node2D

const SIMPLE_INPUT := preload("res://Scenes/SimpleInput.tscn")

# Async helper that shows your input UI and returns the entered text (or null if cancelled)
func ask_text(prompt: String = "") -> String:
	var ui := SIMPLE_INPUT.instantiate()
	# If you have a prompt label in the scene, set it here (safe-check in case you removed it)
	if ui.has_node("InputLayer/PanelBox/PromptLabel"):
		ui.get_node("InputLayer/PanelBox/PromptLabel").text = prompt
	
	add_child(ui)
	
	var text := ""
	var done := false
	
	ui.submitted.connect(func(t): text = t; done = true)
	ui.cancelled.connect(func(): text = ""; done = true)
	
	# wait until one of the signals flips `done`
	while not done:
		await get_tree().process_frame
	
	ui.queue_free()
	return text

func _ready() -> void:
	# Quick smoke test – shows ONLY your custom box
	var answer := await ask_text("Type your answer below.")
	print("You typed: ", answer)
