extends Node2D

@export var phases: Array[Node] = []
var current_phase_index: int = 0


func _ready():
	show_phase(current_phase_index)

func handle_correct():
	next_phase()

func handle_incorrect():
	print("incorrect")

func show_phase(index: int):
	for i in range(phases.size()):
		phases[i].visible = i == index

func next_phase():
	current_phase_index += 1
	if current_phase_index < phases.size():
		show_phase(current_phase_index)
	else:
		print("Completed")
