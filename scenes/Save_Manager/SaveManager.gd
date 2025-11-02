extends Node

var save_path := "res://data/Save/game_progress.save"
var current_save_data := {
	"completed_ppe": false,
	"completed_microscope": false,
	"completed_measurement": false
}

func _ready():
	load_progress()

func save_progress():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_var(current_save_data)
		file.close()
		print("Game saved!")
	else:
		print("Error saving game")

func load_progress():
	if not FileAccess.file_exists(save_path):
		print("No save file found")
		return
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		current_save_data = file.get_var()
		file.close()
		print("Game loaded!")

func complete_mode(mode_key: String):
	current_save_data[mode_key] = true
	save_progress()

func is_mode_completed(mode_key: String) -> bool:
	return current_save_data.get(mode_key, false)

func reset_progress():
	current_save_data = {
		"completed_ppe": false,
		"completed_microscope": false,
		"completed_measurement": false
	}
	save_progress()
	print("Progress reset!")
