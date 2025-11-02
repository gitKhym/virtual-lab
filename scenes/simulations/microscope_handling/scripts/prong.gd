extends Area2D

@onready var slide = %SlideArea
@export var is_left_prong: bool = false

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if slide.sample_on_destination:
			slide.lock_slide()
			slide.set_prong_active(is_left_prong, true)
			self.z_index = slide.z_index + 1
		else:
			print(name, " clicked, but slidye is not on destination.")
		get_viewport().set_input_as_handled()
