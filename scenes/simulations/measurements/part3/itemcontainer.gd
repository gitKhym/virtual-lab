extends Node2D

# --- Node references ---
@onready var hitmarker: Marker2D = $"../hitmarker"

# --- Washer data ---
var washer_names: Array[String] = ["washersmall", "washermedium", "washerstacked", "weight"]
var current_index: int = 0
var washer: Sprite2D = null
var next_washer: Sprite2D = null

# --- Drag state ---
var is_dragging: bool = false
var offset: Vector2 = Vector2.ZERO
var snap_distance: float = 10.0
var locked: bool = false
var start_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	_initialize_washers()
	set_process_input(true)

func _initialize_washers() -> void:
	washer = get_node_or_null(washer_names[current_index])
	if washer:
		start_position = washer.global_position
	else:
		push_error("Missing washer node: %s" % washer_names[current_index])

	for i in range(1, washer_names.size()):
		var next_node = get_node_or_null(washer_names[i])
		if next_node:
			next_node.visible = false
			next_node.modulate.a = 0.0


func _input(event: InputEvent) -> void:
	if locked or not washer:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and _is_mouse_over_washer(event.position):
				is_dragging = true
				offset = washer.global_position - event.position
				get_viewport().set_input_as_handled()
			elif not event.pressed and is_dragging:
				is_dragging = false
				_check_for_snap()
	elif event is InputEventMouseMotion and is_dragging:
		washer.global_position = event.position + offset


func _is_mouse_over_washer(mouse_pos: Vector2) -> bool:
	if not washer or not washer.texture:
		return false

	var tex_size := washer.texture.get_size() * washer.scale
	var top_left := washer.global_position - (tex_size / 2)
	var rect := Rect2(top_left, tex_size)
	return rect.has_point(mouse_pos)


func _check_for_snap() -> void:
	if not hitmarker or not washer:
		return

	var dist := washer.global_position.distance_to(hitmarker.global_position)
	if dist <= snap_distance:
		_snap_to_hitmarker()


func _snap_to_hitmarker() -> void:
	if not washer or not hitmarker:
		return

	washer.global_position = hitmarker.global_position
	locked = true

	var tween := create_tween()
	tween.tween_property(washer, "scale", washer.scale * 1.2, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(washer, "scale", washer.scale, 0.1)

	get_parent().call_deferred("_on_washer_dropped")


func slide_off_and_disappear() -> void:
	if not washer:
		return

	locked = true
	is_dragging = false

	var tween := create_tween()
	var slide_distance := -400.0
	var slide_target := washer.global_position + Vector2(slide_distance, 0)

	tween.tween_property(washer, "global_position", slide_target, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(washer, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished

	if washer:
		washer.visible = false

	await _spawn_next_washer()


func _spawn_next_washer() -> void:
	if current_index + 1 >= washer_names.size():
		print("All  completed.")
		return

	current_index += 1
	next_washer = get_node_or_null(washer_names[current_index])

	if not next_washer:
		push_warning("Missing washer node for index %d" % current_index)
		return

	next_washer.visible = true
	next_washer.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(next_washer, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished

	_switch_to_next_washer()

func _switch_to_next_washer() -> void:
	if not next_washer:
		push_warning("No next washer to switch to.")
		return

	washer = next_washer
	hitmarker = washer.get_node_or_null("target") if washer.has_node("target") else $"../hitmarker"
	start_position = washer.global_position
	locked = false

func reset_position() -> void:
	if not washer:
		return

	washer.global_position = start_position
	washer.modulate.a = 1.0
	washer.visible = true
	locked = false
