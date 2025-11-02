extends Sprite2D

signal continuous_pour_requested(amount)
signal water_source_over_pour_area(is_over)

var dragging = false
var drag_offset = Vector2()
var is_over_pour_area = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_rect().has_point(to_local(event.position)):
				dragging = true
				drag_offset = global_position - event.position
			elif not event.pressed and dragging:
				dragging = false
				_on_drop()

	if event is InputEventMouseMotion and dragging:
		global_position = event.position + drag_offset
		_check_pour_area()

func _check_pour_area():
	var graduated_cylinder = get_parent().get_node("GraduatedCylinder")
	if graduated_cylinder:
		var drop_zone = graduated_cylinder.get_node("WaterDropZone")
		if drop_zone:
			var overlaps = drop_zone.overlaps_area(self)
			var new_is_over_pour_area = overlaps
			if new_is_over_pour_area != is_over_pour_area:
				is_over_pour_area = new_is_over_pour_area
				emit_signal("water_source_over_pour_area", is_over_pour_area)

func _on_drop():
	if not is_over_pour_area:
		global_position = Vector2(500, 300)

func start_continuous_pour():
	if is_over_pour_area:
		emit_signal("continuous_pour_requested", 1.0)

func stop_continuous_pour():
	pass
