extends Node2D

# Camera
@onready var cam: Camera2D = $world/Camera2D

# Scenario nodes organized in a dictionary for better management
@onready var scenarios := {
	"scenario1": {
		"area": $world/scenario1,
		"sprite": $world/scenario1/test,
		"done": false,
		"complete_texture": "res://assets/simulations/ppe/scenarios/sign.png",
		"target_position": null,  
		"move_duration": 0.1
	},
	"scenario2": {
		"area": $world/scenario2, 
		"sprite": $world/scenario2/test2,
		"done": false,
		"complete_texture": "res://assets/simulations/ppe/scenarios/crumpled_gloves.png",
		"target_position": Vector2(39, 118),  
		"move_duration": 0.1,
		"make_empty_on_complete": true  
	},
	"scenario3": {
		"area": $world/scenario3, 
		"sprite": $world/scenario3/test3,
		"done": false,
		"complete_texture": "res://assets/simulations/ppe/scenarios/crumpled_gloves.png",
		"target_position": null,  
		"move_duration": 0.1,
		"make_empty_on_complete": true  
	},
	"scenario4": {
		"area": $world/scenario4, 
		"sprite": $world/scenario4/test4,
		"done": false,
		"complete_texture": "res://assets/simulations/ppe/scenarios/microscopeafter.png",
		"target_position": null,  
		"move_duration": 0.1,  
	}
}

# State variables
var _busy := false
var _original_pos: Vector2
var _original_zoom: Vector2

# Finale coordinates
var _finale_target_pos := Vector2(253, 28)
var _finale_zoom_factor := 2.0  # Adjust this for how much you want to zoom in
var _finale_duration := 1.0     # Duration of the zoom animation

func _ready() -> void:
	_setup_camera()
	_setup_scenarios()
	_connect_dialogic_signals()

func _setup_camera() -> void:
	_original_pos = cam.global_position
	_original_zoom = cam.zoom
	
	# Camera limits
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = 360
	cam.limit_bottom = 180
	cam.limit_smoothed = true

func _setup_scenarios() -> void:
	for scenario_key in scenarios:
		var scenario = scenarios[scenario_key]
		if scenario.area:
			scenario.area.input_pickable = true
			if not scenario.area.input_event.is_connected(_on_scenario_input):
				scenario.area.input_event.connect(_on_scenario_input.bind(scenario_key))
		

		if not scenario.has("target_position"):
			scenario["target_position"] = null
		if not scenario.has("move_duration"):
			scenario["move_duration"] = 0.3
		if not scenario.has("make_empty_on_complete"):
			scenario["make_empty_on_complete"] = false

func _connect_dialogic_signals() -> void:
	if not Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_scenario_input(_viewport: Node, event: InputEvent, _shape_idx: int, scenario_key: String) -> void:
	var scenario = scenarios[scenario_key]
	if scenario.done or _busy or not _is_left_click(event):
		return
	_busy = true
	await _zoom_to_cursor(0.6, 1.7)
	
	await _start_dialog(scenario_key)
	
	_busy = false

func _is_left_click(event: InputEvent) -> bool:
	return (event is InputEventMouseButton and 
			event.pressed and 
			event.button_index == MOUSE_BUTTON_LEFT)

func _start_dialog(scenario_label: String) -> void:
	var dlg = Dialogic.start("res://dialogic/dialogs/testing/ppe_scenario_1file.dtl", scenario_label)
	if dlg:
		add_child(dlg)
		await dlg.tree_exited
		
func _on_dialogic_signal(argument: String) -> void:
	var signal_handlers := {
		"spill_correct": _handle_scenario_complete.bind("scenario1"),
		"waste_correct": _handle_scenario_complete.bind("scenario2"),
		"eat_correct": _handle_scenario_complete.bind("scenario3"),
		"handling_correct": _handle_scenario_complete.bind("scenario4")
	}
	
	if argument in signal_handlers:
		await signal_handlers[argument].call()
		
		# Check if all scenarios are completed after handling this one
		_check_all_scenarios_complete()

func _check_all_scenarios_complete() -> void:
	# Check if all scenarios are done
	var all_completed := true
	for scenario_key in scenarios:
		if not scenarios[scenario_key]["done"]:
			all_completed = false
			break
	
	# If all scenarios are completed, trigger the finale
	if all_completed:
		print("All scenarios completed! Triggering finale...")
		await _zoom_to_finale()  # Zoom to finale coordinates first
		_start_finale()

func _start_finale() -> void:
	# Start the finale dialog (jump to "finale" label in the same timeline file)
	var finale_dlg = Dialogic.start("res://dialogic/dialogs/testing/ppe_scenario_1file.dtl", "scenario5")
	if finale_dlg:
		add_child(finale_dlg)
		await finale_dlg.tree_exited
		print("Finale completed!")
		# Optionally zoom back after finale if needed
		# await _zoom_back(_original_pos, _original_zoom, 1.0)

func _zoom_to_finale() -> void:
	print("Zooming to finale coordinates: ", _finale_target_pos)
	
	var target_zoom := Vector2(_finale_zoom_factor, _finale_zoom_factor)
	
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(cam, "zoom", target_zoom, _finale_duration)
	tw.parallel().tween_property(cam, "global_position", _finale_target_pos, _finale_duration)
	await tw.finished

func _handle_scenario_complete(scenario_key: String) -> void:
	var scenario = scenarios[scenario_key]
	
	if scenario.area and scenario.sprite:
		scenario.done = true
		scenario.area.input_pickable = false
		scenario.area.monitoring = false
		
		# MOVE SPRITE FIRST (before texture change)
		await _move_sprite_to_target(scenario)
		
		# THEN HANDLE VISUAL CHANGES BASED ON SCENARIO TYPE
		if scenario.get("make_empty_on_complete", false):
			# Make sprite empty/transparent for scenario2
			_make_sprite_empty(scenario)
		else:
			# Normal texture change for scenario1
			scenario.sprite.texture = load(scenario.complete_texture)
	
	await _zoom_back(_original_pos, _original_zoom, 0.6)

func _make_sprite_empty(scenario: Dictionary) -> void:
	if scenario.sprite:
		scenario.sprite.modulate = Color(1, 1, 1, 0)
		scenario.sprite.texture = null
		print("Sprite made empty for scenario")

func _move_sprite_to_target(scenario: Dictionary) -> void:
	if scenario.get("target_position") is Vector2 and scenario.sprite:
		var target_pos: Vector2 = scenario.target_position
		var duration: float = scenario.get("move_duration", 0.6)
		
		print("Moving sprite to position: ", target_pos)
		var tw = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.tween_property(scenario.sprite, "position", target_pos, duration)
		await tw.finished
	else:
		print("No target position specified for this scenario, sprite remains in place")

func _zoom_to_cursor(duration: float, zoom_factor: float) -> void:
	var cursor_world_pos: Vector2 = cam.get_global_mouse_position()
	var target_zoom := Vector2(zoom_factor, zoom_factor)
	
	var before := cam.get_screen_center_position()
	var after := cursor_world_pos
	var offset := after - before
	
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(cam, "zoom", target_zoom, duration)
	tw.parallel().tween_property(cam, "global_position", cam.global_position + offset, duration)
	await tw.finished

func _zoom_back(pos: Vector2, zoom: Vector2, duration: float) -> void:
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(cam, "zoom", zoom, duration)
	tw.parallel().tween_property(cam, "global_position", pos, duration)
	await tw.finished
