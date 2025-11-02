extends Node2D

@onready var ppe = $Background/PPE
@onready var ppe_check = $Background/PPE/CheckMark
@onready var microscope = $Background/Microscope
@onready var microscope_check = $Background/Microscope/CheckMark
@onready var measurement = $Background/Measurement
@onready var measurement_check = $Background/Measurement/CheckMark
@onready var background = $Background

var dlg
var _busy := false
var next_scene_path: String = ""

func _ready():
	if not ppe.is_connected("input_event", _on_ppe_input):
		ppe.connect("input_event", _on_ppe_input)
	if not microscope.is_connected("input_event", _on_microscope_input):
		microscope.connect("input_event", _on_microscope_input)
	if not measurement.is_connected("input_event", _on_measurement_input):
		measurement.connect("input_event", _on_measurement_input)
	
	update_all_visuals()

func update_all_visuals():
	update_ppe_visual()
	update_microscope_visual()
	update_measurement_visual()

func update_ppe_visual():
	if ppe_check:
		ppe_check.visible = SaveManager.is_mode_completed("completed_ppe")

func update_microscope_visual():
	if microscope_check:
		microscope_check.visible = SaveManager.is_mode_completed("completed_microscope")

func update_measurement_visual():
	if measurement_check:
		measurement_check.visible = SaveManager.is_mode_completed("completed_measurement")

func start_dialogic_with_dim(timeline_label: String):
	if _busy:
		return
	
	_busy = true
	
	var original_modulate = background.modulate if background else Color.WHITE
	if background:
		var fade_tween = create_tween()
		fade_tween.tween_property(background, "modulate", Color(0.5, 0.5, 0.5, 1.0), 0.5)
	
	dlg = Dialogic.start("Main_Menu2", timeline_label)
	if not Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.connect(_on_dialogic_signal)
	if dlg:
		await dlg.tree_exited
	if background:
		var restore_tween = create_tween()
		restore_tween.tween_property(background, "modulate", original_modulate, 0.5)
		await restore_tween.finished
	
	_busy = false

func _on_dialogic_signal(argument: String):
	if argument == "proceed" and next_scene_path != "":
		SceneTransistion.change_scene(next_scene_path)
		next_scene_path = ""  

func _on_ppe_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if SaveManager.is_mode_completed("completed_ppe"):
			next_scene_path = "res://scenes/simulations/ppe_simulation/ppe_lab_start.tscn"
			start_dialogic_with_dim("PPE_introduction_completed")
		else:
			next_scene_path = "res://scenes/simulations/ppe_simulation/ppe_lab_start.tscn"
			start_dialogic_with_dim("ppe_start")


func _on_microscope_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if SaveManager.is_mode_completed("completed_microscope"):
			next_scene_path = "res://scenes/simulations/microscope_handling/microscope_parts.tscn"
			start_dialogic_with_dim("microscope_introduction_start")
		else:
			next_scene_path = "res://scenes/simulations/microscope_handling/microscope_parts.tscn"
			start_dialogic_with_dim("microscope_start")


func _on_measurement_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if SaveManager.is_mode_completed("completed_measurement"):
			next_scene_path = "res://scenes/simulations/measurements/part1/conversion_test.tscn"
			start_dialogic_with_dim("measurement_introduction_completed")
		else:
			next_scene_path = "res://scenes/simulations/measurements/part1/conversion_test.tscn"
			start_dialogic_with_dim("measurement_start")


func reset_progress():
	SaveManager.reset_progress()
	update_all_visuals()
