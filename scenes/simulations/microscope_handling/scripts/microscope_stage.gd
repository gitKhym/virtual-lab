extends Node2D

var is_slide_in_place = false

func _on_slide_area_body_entered(body):
	if body.is_in_group("slides"):
		is_slide_in_place = true
		print("Slide in place")
