extends Node2D

@onready var title_label = %TitleLabel
@onready var description_label = %DescriptionLabel
@onready var microscope = %Microscope
@onready var next_button = %NextButton

var microscope_data = {}
var clicked_parts = {}
var total_parts = 0

func _ready():
	next_button.visible = false
	next_button.pressed.connect(_on_NextButton_pressed)
	Dialogic.start("microscope_parts")
	var file = FileAccess.open("res://data/simulations/microscope.json", FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var data = json.get_data()
		if data.has("parts"):
			microscope_data = data.parts
			total_parts = microscope_data.size() - 1
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", content, " at line ", json.get_error_line())

	var areas = microscope.get_children()
	for area in areas:
		var area2d = area.get_node_or_null("Area2D")
		if area2d:
			var collision_polygon = area2d.get_node_or_null("CollisionPolygon2D")
			if collision_polygon:
				var line = Line2D.new()
				line.width = 0.5
				line.default_color = Color(1.0, 0.5, 0.0, 1.0)
				line.visible = false
				line.name = "Outline"
				line.z_index = 100
				line.z_as_relative = false
				
				var offset = area2d.position + collision_polygon.position
				var points = PackedVector2Array()
				for point in collision_polygon.polygon:
					points.append(point + offset)

				if points.size() > 0:
					points.append(points[0])
				line.points = points
				
				area.add_child(line)

			area2d.connect("mouse_entered", _on_mouse_entered.bind(area))
			area2d.connect("mouse_exited", _on_mouse_exited.bind(area))
			area2d.connect("input_event", _on_input_event.bind(area))

func _on_NextButton_pressed():
	get_tree().change_scene_to_file("res://scenes/simulations/microscope_handling/microscope_stage.tscn")

func _on_input_event(viewport, event, shape_idx, area):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
			var part_name = area.name.to_snake_case()
			for part in microscope_data:
				if part.id == part_name:
					title_label.text = part.name
					description_label.text = part.description
					if not clicked_parts.has(part_name):
						clicked_parts[part_name] = true
						if clicked_parts.size() == total_parts:
							Dialogic.start("all_parts_clicked")
							next_button.visible = true
					break

func _on_mouse_entered(area):
	var line = area.get_node_or_null("Outline")
	if line:
		line.visible = true

func _on_mouse_exited(area):
	var line = area.get_node_or_null("Outline")
	if line:
		line.visible = false
