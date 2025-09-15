extends Node2D

@onready var microscope = $Microscope
@onready var slide = $Slide
@onready var view = $View
@onready var feedback_label = $FeedbackLabel

var dragging_microscope = false
var dragging_slide = false

var current_objective = "4x"
var focus = 0.0
var diaphragm = 0.5


var blurry_texture = null # load("res://assets/blurry_view.png")
var sharp_texture = null # load("res://assets/sharp_view.png")

func _ready():
	feedback_label.text = "Click and drag the hand on the arm and base to carry the microscope."
	view.texture = blurry_texture

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if microscope.get_rect().has_point(to_local(event.position)):
					dragging_microscope = true
					feedback_label.text = "Carrying the microscope correctly!"
				elif slide.get_rect().has_point(to_local(event.position)):
					dragging_slide = true
				else:
					feedback_label.text = "Incorrect. Always carry with one hand on the arm, one under the base."
			else:
				dragging_microscope = false
				dragging_slide = false

	if event is InputEventMouseMotion:
		if dragging_microscope:
			microscope.position = event.position
		if dragging_slide:
			slide.position = event.position
			# Check if the slide is over the stage
			if $Microscope/StageArea.get_rect().has_point(to_local(event.position)):
				feedback_label.text = "Slide is on the stage. Secure with clips."
				slide.position = microscope.position + Vector2(0, 150) # Snap to stage
				dragging_slide = false

func _on_objective_button_pressed(objective):
	current_objective = objective
	feedback_label.text = "Switched to " + objective + " objective."
	update_view()

func _on_knob_pressed(knob_type):
	if knob_type == "coarse":
		focus += 0.2
		feedback_label.text = "Using coarse adjustment knob."
	elif knob_type == "fine":
		focus += 0.05
		feedback_label.text = "Using fine adjustment knob."
	focus = clamp(focus, 0.0, 1.0)
	update_view()

func _on_diaphragm_slider_changed(value):
	diaphragm = value
	feedback_label.text = "Adjusting diaphragm."
	update_view()

func update_view():
	# Assume 0.8 is the perfect focus
	var focus_quality = 1.0 - abs(focus - 0.8) 
	# Assume 0.6 is the perfect light
	var light_quality = 1.0 - abs(diaphragm - 0.6) 

	var total_quality = focus_quality * light_quality

	if total_quality > 0.8:
		view.texture = sharp_texture
	else:
		view.texture = blurry_texture

	view.modulate.a = total_quality
