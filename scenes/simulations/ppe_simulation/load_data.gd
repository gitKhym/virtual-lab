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
	var items = data.get("phases")[0].get("items")
	for item_data in items:
		for item: Area2D in get_node("Phase 1").get_children():
			if item.id == item_data.id:
				item.id = (item_data.id) 
				item.item_name = (item_data.item_name) 
				item.description = (item_data.description)
