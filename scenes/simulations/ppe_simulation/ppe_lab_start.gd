extends Node2D
@onready var clothes_hotspot: Area2D = $ClothesHotspot  # Add the correct path
const PPE_SCENE_PATH := "res://scenes/simulations/ppe_simulation/ppe_simulation.tscn"

var _busy := false

func _ready() -> void:
	await get_tree().create_timer(1.5).timeout
	clothes_hotspot.input_pickable = true
	clothes_hotspot.monitoring = false
	
	var background_sprite = get_node("Background")  
	
	if not clothes_hotspot.input_event.is_connected(_on_hotspot_input):
		clothes_hotspot.input_event.connect(_on_hotspot_input)
	var original_modulate = background_sprite.modulate if background_sprite else Color.WHITE
	
	# Dim the background
	if background_sprite:
		var fade_tween = create_tween()
		fade_tween.tween_property(background_sprite, "modulate", Color(0.5, 0.5, 0.5, 1.0), 0.5)
	
	var dlg_ui := Dialogic.start("res://dialogic/dialogs/testing/introduction.dtl")
	if dlg_ui:
		await Dialogic.timeline_ended
		if background_sprite:
			var restore_tween = create_tween()
			restore_tween.tween_property(background_sprite, "modulate", original_modulate, 0.5)
			await restore_tween.finished
		
	clothes_hotspot.monitoring = true



func _on_hotspot_input(_vp, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_clothes_clicked()

func _on_clothes_clicked() -> void:
	if _busy: 
		return
	
	_busy = true
	
	SceneTransistion.change_scene(PPE_SCENE_PATH)  
