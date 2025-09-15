extends Control

var dragging = false
var offset = Vector2()

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	var slide_sprite = get_node("Slide")
	if slide_sprite:
		position = slide_sprite.position
		size = slide_sprite.texture.get_size()
		slide_sprite.centered = false
		slide_sprite.position = Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if get_global_rect().has_point(event.position):
				dragging = true
				offset = global_position - event.position
				get_viewport().set_input_as_handled()
		elif event.is_released():
			dragging = false

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position() + offset
