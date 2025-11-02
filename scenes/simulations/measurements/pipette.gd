extends Sprite2D

var water_mask_value = 0.0
var fill_speed = 125.0
var unfill_speed = 20.0

var water_node: TextureRect
var pipette_bulb_button: TextureButton
var check_button: TextureButton
var target_ml = 0
var goal_label = Label
var feedback_label = Label
var starting_water_mask_value = 0.0

var is_pipette_filled = false
var awaiting_release = false

var total_ml_excreted = 0
var good_attempts_count = 0

func _ready():
	water_node = %Water
	pipette_bulb_button = %PipetteBulbButton
	goal_label = %GoalLabel
	check_button = %CheckButton
	
	set_new_target()
	
	pipette_bulb_button.button_up.connect(_on_pipette_bulb_released)
	pipette_bulb_button.button_down.connect(_on_pipette_bulb_pressed)
	check_button.pressed.connect(_on_check_button_pressed)
	
	Dialogic.start("pipette_intro")
	
func _process(delta):
	if water_mask_value == 100.0:
		if not is_pipette_filled:
			if good_attempts_count == 0:
				Dialogic.start("pipette_filled")
			is_pipette_filled = true
			awaiting_release = true

	if water_mask_value == 0.0:
		if is_pipette_filled:
			is_pipette_filled = false
			awaiting_release = true

	if pipette_bulb_button.is_pressed():
		if awaiting_release:
			pass
		elif is_pipette_filled == false:
			water_mask_value = clamp(water_mask_value + fill_speed * delta, 0.0, 100.0)
		else:
			water_mask_value = clamp(water_mask_value - unfill_speed * delta, 0.0, 100.0)

	update_water_mask()

func _on_pipette_bulb_pressed():
	starting_water_mask_value = water_mask_value

func _on_pipette_bulb_released():
	if is_pipette_filled == false and water_mask_value < 100.0 and water_mask_value > 0.0:
		Dialogic.start("pipette_not_filled_fully")
		water_mask_value = 0
		
	if is_pipette_filled == true and water_mask_value < starting_water_mask_value:
		const MAX_PIPETTE_VOLUME = 11.0
		var mask_change = starting_water_mask_value - water_mask_value
		var ml_excreted = (mask_change / 100.0) * MAX_PIPETTE_VOLUME
		var rounded_ml_excreted = round(ml_excreted * 100.0) / 100.0
		
		total_ml_excreted = total_ml_excreted + rounded_ml_excreted

	awaiting_release = false


func set_new_target():
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	target_ml = round(rng.randf_range(0.5, 10) * 10) / 10.0
	goal_label.text = "Measure: " + str(target_ml) + " ml"
	
func update_water_mask():
	var fill_amount_shader = water_mask_value / 100.0
	if water_node and water_node.material:
		water_node.material.set_shader_parameter("fill_amount", fill_amount_shader)

func _on_check_button_pressed():
	var difference = abs(total_ml_excreted - target_ml)
	
	print(difference)
	
	const MAX_GOOD_ATTEMPTS = 3
	var dialog_name = ""

	Dialogic.VAR.Simulations.Measurement.measured_ml = total_ml_excreted

	if difference <= 0.3:
		good_attempts_count += 1
		
		if good_attempts_count >= MAX_GOOD_ATTEMPTS:
			dialog_name = "pipette_volume_finished"
			var dlg = Dialogic.start(dialog_name)
			if dlg:
				await dlg.tree_exited
			SceneTransistion.change_scene("res://scenes/simulations/measurements/measuring_volume.tscn")
			return 
		else:
			dialog_name = "pipette_volume_good"
			set_new_target()
			
	else:  
		dialog_name = "pipette_volume_needs_practice"
	

	Dialogic.start(dialog_name)
	

	total_ml_excreted = 0
	water_mask_value = 0.0
	update_water_mask()
