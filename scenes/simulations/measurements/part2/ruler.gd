extends Node2D

const PIXELS_PER_CM := 168.0 / 5.0   
const CM_PER_PIXEL := (1.0 / PIXELS_PER_CM) * 1.54

@onready var asset: Sprite2D = $asset
@onready var zero_mark: Marker2D = $asset/zeromark
@onready var ui_label: Label = get_tree().get_root().find_child("MeasurementLabel", true, false)

var dragging := false
var drag_offset := Vector2.ZERO
var hover := false
var last_measurement := 0.0
var can_drag := true 

# -------------------------------------------------------------
func _ready() -> void:
	if ui_label:
		ui_label.visible = true  # keep it visible always
		ui_label.text = "Measured: 0.00 cm"
	else:
		push_warning("⚠MeasurementLabel not found in UI.")

# -------------------------------------------------------------
func _process(_delta: float) -> void:
	if not asset.texture or not ui_label:
		return

	var local_mouse: Vector2 = asset.to_local(get_global_mouse_position())
	var tex_size: Vector2 = asset.texture.get_size() * asset.scale
	var hover_height: float = tex_size.y * 0.50      
	var width_buffer: float = 13.0                   
	var y_offset: float = tex_size.y * 0.05       

	var ruler_rect := Rect2(
		Vector2(-tex_size.x / 2.0 - width_buffer, -tex_size.y / 2.0 + y_offset),
		Vector2(tex_size.x + width_buffer * 2.0, hover_height)
	)

	hover = ruler_rect.has_point(local_mouse)

	if hover:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var zero_x: float = zero_mark.global_position.x
		var dist_px: float = mouse_pos.x - zero_x
		var dist_cm: float = dist_px * CM_PER_PIXEL
		last_measurement = dist_cm
		ui_label.text = "Measured: %.1f cm" % dist_cm
	else:
		ui_label.text = "Measured: %.1f cm" % last_measurement

	queue_redraw()

func _input(event: InputEvent) -> void:
	if not can_drag:  
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var local_mouse := asset.to_local(event.position)
			var tex_size := asset.texture.get_size() * asset.scale
			var ruler_rect := Rect2(-tex_size / 2.0, tex_size)
			if ruler_rect.has_point(local_mouse):
				dragging = true
				drag_offset = event.position - global_position
		else:
			dragging = false

	elif event is InputEventMouseMotion and dragging:
		global_position = event.position - drag_offset

func enable_dragging() -> void:
	can_drag = true

func disable_dragging() -> void:
	can_drag = false
	dragging = false 
