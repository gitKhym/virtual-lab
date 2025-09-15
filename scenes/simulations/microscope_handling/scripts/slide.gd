extends Area2D

var dragging = false
var offset = Vector2()
var sample_on_destination = false
var locked_in_place = false
var left_prong_active = false
var right_prong_active = false
var both_prongs_active = false

func _ready():
	add_to_group("slide_group")
	var sample_area = get_node("SampleArea")
	sample_area.area_entered.connect(_on_SampleArea_area_entered)
	sample_area.area_exited.connect(_on_SampleArea_area_exited)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		dragging = false

func _input_event(viewport, event, shape_idx):
	if not locked_in_place and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		dragging = true
		offset = global_position - event.position
		get_viewport().set_input_as_handled()

func _process(delta):
	if dragging and not locked_in_place:
		global_position = get_global_mouse_position() + offset
	
	if left_prong_active and right_prong_active and not both_prongs_active:
		both_prongs_active = true
		
	elif (not left_prong_active or not right_prong_active) and both_prongs_active:
		both_prongs_active = false
		

func _on_SampleArea_area_entered(area: Area2D):
	if area.name == "SampleAreaDestination":
		sample_on_destination = true

func _on_SampleArea_area_exited(area: Area2D):
	if area.name == "SampleAreaDestination":
		sample_on_destination = false

func lock_slide():
	locked_in_place = true
	dragging = false

func unlock_slide():
	locked_in_place = false
	left_prong_active = false
	right_prong_active = false

func set_prong_active(is_left_prong: bool, active: bool):
	if is_left_prong:
		left_prong_active = active
	else:
		right_prong_active = active
