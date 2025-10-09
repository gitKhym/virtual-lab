extends Node2D

@onready var sample40x = $Sample40x
@onready var sample90x = $Sample90x
@onready var sample130x = $Sample130x
@onready var coarse_adjustment_knob = $CoarseAdjustmentKnob
@onready var button40x = $"40xButton"
@onready var button90x = $"90xButton"
@onready var button130x = $"130xButton"
@onready var observe_sample_button = $ObserveSampleButton
@onready var specimen_border = $SpecimenBorder
@onready var next_button = $Next

var current_objective = ""
var focus = 0.0

func _ready():
	coarse_adjustment_knob.value_changed.connect(_on_coarse_knob_value_changed)
	observe_sample_button.pressed.connect(_on_observe_sample_pressed)
	button40x.pressed.connect(_on_objective_button_pressed.bind("40x"))
	button90x.pressed.connect(_on_objective_button_pressed.bind("90x"))
	button130x.pressed.connect(_on_objective_button_pressed.bind("130x"))
	next_button.pressed.connect(_on_next_pressed)

	sample40x.visible = false
	sample90x.visible = false
	sample130x.visible = false
	
	button40x.visible = false
	button90x.visible = false
	button130x.visible = false
	
	specimen_border.visible = false
	next_button.visible = false

	update_view()
	Dialogic.start("microscope_practice_start")


func _input(event):
	pass

func _on_observe_sample_pressed():
	observe_sample_button.visible = false
	sample40x.visible = true
	specimen_border.visible = true
	next_button.visible = true
	current_objective = "40x"
	
	Dialogic.timeline_ended.connect(_on_dialogic_intro_ended)
	Dialogic.start("microscope_practice_40x_intro")

func _on_dialogic_intro_ended(timeline_name):
	Dialogic.timeline_ended.disconnect(_on_dialogic_intro_ended)
	if timeline_name == "microscope_practice_40x_intro":
		button90x.visible = true
	elif timeline_name == "microscope_practice_90x_intro":
		button130x.visible = true

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
	print(focus)
	update_view()
	
func _on_next_pressed():
	if focus >= 0.66:
		match current_objective:
			"40x":
				focus = 0
				current_objective = "90x"
				_on_objective_button_pressed("90x")
				Dialogic.start("microscope_practice_90x_intro")
			"90x":
				focus = 0
				current_objective = "130x"
				_on_objective_button_pressed("130x")
				Dialogic.start("microscope_practice_130x_intro")
			"130x":
				focus = 0
				next_button.visible = false
				Dialogic.start("microscope_practice_complete")
				button40x.visible = true
				button90x.visible = true	
				button130x.visible = true
	else:
		Dialogic.start("microscope_practice_focus_incorrect")


func update_view():
	var focus_quality = 1.0 - abs(focus - 0.8)
	var blur_amount = 1.0 - focus_quality
	
	sample40x.material.set_shader_parameter("blur_amount", blur_amount)
	sample90x.material.set_shader_parameter("blur_amount", blur_amount)
	sample130x.material.set_shader_parameter("blur_amount", blur_amount)
