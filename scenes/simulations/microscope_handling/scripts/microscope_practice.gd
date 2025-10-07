extends Node2D

@onready var sample = $Sample
@onready var feedback_label = $FeedbackLabel

var current_objective = "4x"
var focus = 0.0
var diaphragm = 0.5

func _ready():
	feedback_label.text = "Use the buttons and slider to adjust the microscope."
	update_view()

func _input(event):
	pass

func _on_objective_button_pressed(objective):
	current_objective = objective
	feedback_label.text = "Switched to " + objective + " objective."
	update_view()

func _on_coarse_knob_value_changed(value):
	focus += value
	focus = clamp(focus, 0.0, 1.0)
	feedback_label.text = "Adjusting coarse focus."
	update_view()

func _on_knob_pressed(knob_type):
	if knob_type == "fine":
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
	
	# The blur amount is inversely proportional to the focus quality.
	var blur_amount = 1.0 - focus_quality
	
	sample.material.set_shader_parameter("blur_amount", blur_amount)
