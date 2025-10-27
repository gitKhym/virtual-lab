extends Sprite2D

var water_mask_value = 0.0
var fill_speed = 20.0
var water_node: TextureRect
var pour_button: TextureButton
var pour_out_button: TextureButton
var check_button: TextureButton
var target_ml = 0
var goal_label = Label
var feedback_label = Label

var good_attempts_count = 0

func _ready():
	water_node = $Water
	pour_button = %PourButton
	pour_out_button = %PourOutButton
	check_button = %CheckButton
	goal_label = %GoalLabel
	feedback_label = %FeedbackLabel
	
	set_new_target()

	if check_button:
		check_button.connect("pressed", Callable(self, "_on_check_button_pressed"))

func _process(delta):
	if pour_button and pour_button.is_pressed():
		water_mask_value = clamp(water_mask_value + fill_speed * delta, 0.0, 100.0)
	if pour_out_button and pour_out_button.is_pressed():
		water_mask_value = clamp(water_mask_value - fill_speed * delta, 0.0, 100.0)

	update_water_mask()
	
func set_new_target():
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	target_ml = float(rng.randi_range(15, 50))
	goal_label.text = "Measure: " + str(target_ml) + " ml"



func update_water_mask():
	var fill_amount_shader = water_mask_value / 100.0
	if water_node and water_node.material:
		water_node.material.set_shader_parameter("fill_amount", fill_amount_shader)


func _on_check_button_pressed():
	var measured_ml = get_ml_from_mask_value(water_mask_value)
	var difference = abs(measured_ml - target_ml)
	
	var dialog_name = ""
	if difference == 0:
		dialog_name = "measuring_volume_excellent"
		set_new_target()
		good_attempts_count += 1
	elif difference <= 1:
		good_attempts_count += 1
		if good_attempts_count <= 3:
			dialog_name = "measuring_volume_good"
			set_new_target()
		else:
			dialog_name = "measuring_volume_finished"
	elif difference <= 3:
		dialog_name = "measuring_volume_needs_practice"
		
	Dialogic.VAR.Simulations.Measurement.measured_ml = get_ml_from_mask_value(water_mask_value)
	Dialogic.start(dialog_name)

	water_mask_value = 0.0
	update_water_mask()

func get_ml_from_mask_value(mask_value: float) -> float:
	return snapped(mask_value / 2.0, 0.1)
