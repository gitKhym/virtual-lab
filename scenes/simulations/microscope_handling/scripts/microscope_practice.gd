extends Node2D

@onready var sample40x = $Sample40x
@onready var sample90x = $Sample90x
@onready var sample130x = $Sample130x
@onready var coarse_adjustment_knob = $CoarseAdjustmentKnob
@onready var button40x = $"40xButton"
@onready var button90x = $"90xButton"
@onready var button130x = $"130xButton"

var current_objective = ""
var focus = 0.0

func _ready():
	coarse_adjustment_knob.value_changed.connect(_on_coarse_knob_value_changed)
	button40x.pressed.connect(_on_objective_button_pressed.bind("40x"))
	button90x.pressed.connect(_on_objective_button_pressed.bind("90x"))
	button130x.pressed.connect(_on_objective_button_pressed.bind("130x"))

	update_view()
	Dialogic.start("microscope_practice_start")

func _input(event):
	pass

func _on_objective_button_pressed(objective):
	current_objective = objective

	sample40x.visible = false
	sample90x.visible = false
	sample130x.visible = false

	if objective == "40x":
		sample40x.visible = true
	elif objective == "90x":
		sample90x.visible = true
	elif objective == "130x":
		sample130x.visible = true

	update_view()

func _on_coarse_knob_value_changed(value):
	focus += value
	focus = clamp(focus, 0.0, 1.0)
	update_view()

func update_view():
	# Assume 0.8 is the perfect focus
	var focus_quality = 1.0 - abs(focus - 0.8)
	
	# The blur amount is inversely proportional to the focus quality.
	var blur_amount = 1.0 - focus_quality
	
	sample40x.material.set_shader_parameter("blur_amount", blur_amount)
	sample90x.material.set_shader_parameter("blur_amount", blur_amount)
	sample130x.material.set_shader_parameter("blur_amount", blur_amount)
