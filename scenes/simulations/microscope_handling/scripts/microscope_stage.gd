extends Node2D

@onready var prepare_slide_button = $PrepareSlideButton
@onready var slide = %SlideArea
@onready var next_button = $Next

var is_slide_in_place = false
var sample_secured_dialog_played = false

func _ready():
	Dialogic.start("microscope_stage_start")
	prepare_slide_button.pressed.connect(_on_prepare_slide_button_pressed)

func _process(delta):
	if slide.both_prongs_active and slide.sample_on_destination and not sample_secured_dialog_played:
		sample_secured_dialog_played = true
		Dialogic.start("sample_secured")
		next_button.visible = true

func _on_slide_area_body_entered(body):
	if body.is_in_group("slides"):
		is_slide_in_place = true
		print("Slide in place")

func _on_prepare_slide_button_pressed():
	var tween = create_tween()
	Dialogic.start("slide_prepared")
	tween.tween_property(slide, "position:x", slide.position.x - 100, 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT) 

func _on_next_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/simulations/microscope_handling/microscope_practice.tscn")
