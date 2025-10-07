extends TextureRect

signal value_changed(float)

var is_dragging = false
var drag_start_y = 0.0
var total_rotation = 0.0

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_y = get_global_mouse_position().y
			else:
				is_dragging = false

	if event is InputEventMouseMotion and is_dragging:
		var drag_delta = get_global_mouse_position().y - drag_start_y
		var rotation_amount = drag_delta * 0.35
		var value_change = drag_delta * 0.001

		rotation_degrees += rotation_amount
		emit_signal("value_changed", value_change)

		drag_start_y = get_global_mouse_position().y
