extends Node2D

var data_path = "res://data/simulations/ppe.json"
var data: Dictionary = {}


func _ready():
	load_json()
	assign_items()


func load_json():
	var f = FileAccess.open(data_path, FileAccess.READ)
	if not f:
		push_error("Failed to open data.json")
		return

	var json = f.get_as_text()
	f.close()

	var json_object = JSON.new()
	json_object.parse(json)

	data = json_object.data


func assign_items():
	var items := {}
	for control_phase in %Phases.get_children():
		for item: Area2D in control_phase.get_children():
			items[item.id] = item

	for phase in data.phases:
		for item_data in phase.items:
			if item_data.id in items:
				var item = items[item_data.id]
				for k in item_data.keys():
					item.set(k, item_data[k])
