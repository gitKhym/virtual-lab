extends Sprite2D

@onready var marker: Marker2D = $marker  
@onready var answer_marker: Marker2D = get_tree().get_root().find_child("boxtarget", true, false)

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var hover: bool = false
var can_drag: bool = true
var start_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	start_position = global_position


func _process(_delta: float) -> void:
	if not texture:
		return

	var local_mouse: Vector2 = to_local(get_global_mouse_position())
	var tex_size: Vector2 = texture.get_size() * scale
	var hover_rect := Rect2(-tex_size / 2.0, tex_size)
	hover = hover_rect.has_point(local_mouse)

	queue_redraw()


func _input(event: InputEvent) -> void:
	if not can_drag:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var local_mouse := to_local(event.position)
			var tex_size := texture.get_size() * scale
			var click_rect := Rect2(-tex_size / 2.0, tex_size)
			if click_rect.has_point(local_mouse):
				dragging = true
				drag_offset = event.position - global_position
		else:
			if dragging:
				dragging = false
				_check_snap()

	elif event is InputEventMouseMotion and dragging:
		global_position = event.position - drag_offset


func _check_snap() -> void:
	if not answer_marker:
		return
	var snap_rect := Rect2(answer_marker.global_position - Vector2(60, 60), Vector2(120, 120))
	if snap_rect.has_point(global_position):
		global_position = answer_marker.global_position
	else:
		_reset_position()

func enable_dragging() -> void:
	can_drag = true
	dragging = false

func disable_dragging() -> void:
	can_drag = false
	dragging = false

func _reset_position() -> void:
	global_position = start_position
