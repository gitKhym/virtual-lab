extends Node2D

enum ACCURACY { HIGH, LOW }
enum PRECISION { HIGH, LOW }

var current_accuracy: ACCURACY
var current_precision: PRECISION

var selected_accuracy: ACCURACY
var selected_precision: PRECISION

var correct_answers = 0
const ANSWERS_TO_WIN = 3

const DOT_RADIUS = 10
const NUM_DOTS = 10

@onready var high_accuracy_button = %HighAccuracyButton
@onready var low_accuracy_button = %LowAccuracyButton
@onready var high_precision_button = %HighPrecisionButton
@onready var low_precision_button = %LowPrecisionButton
@onready var target: Sprite2D = $Target

var target_center: Vector2
var target_radius: float

func _ready():
	Dialogic.start("accuracy_start")
	target_radius = (target.texture.get_width() * target.scale.x) / 2.0
	target_center = target.position
	
	high_accuracy_button.pressed.connect(_on_accuracy_selected.bind(ACCURACY.HIGH))
	low_accuracy_button.pressed.connect(_on_accuracy_selected.bind(ACCURACY.LOW))
	high_precision_button.pressed.connect(_on_precision_selected.bind(PRECISION.HIGH))
	low_precision_button.pressed.connect(_on_precision_selected.bind(PRECISION.LOW))
	
	new_round()

func new_round():
	current_accuracy = ACCURACY.values()[randi() % 2]
	current_precision = PRECISION.values()[randi() % 2]

	high_accuracy_button.disabled = false
	low_accuracy_button.disabled = false
	high_precision_button.disabled = true
	low_precision_button.disabled = true
	
	spawn_dots()

func spawn_dots():
	var center_offset = Vector2.ZERO
	if current_accuracy == ACCURACY.LOW:
		center_offset = Vector2(randf_range(-target_radius / 2, target_radius / 2),
								randf_range(-target_radius / 2, target_radius / 2))

	var spread = 0.0
	if current_precision == PRECISION.HIGH:
		spread = target_radius / 5
	else:
		spread = target_radius / 2

	for i in range(NUM_DOTS):
		var dot_pos = target_center + center_offset
		if spread > 0:
			var angle = TAU * i / NUM_DOTS
			var radius = spread * sqrt(randf())
			dot_pos += Vector2(cos(angle), sin(angle)) * radius

		var dot = Sprite2D.new()
		dot.texture = preload("res://assets/simulations/measurement/pin.png")
		dot.position = dot_pos
		add_child(dot)

func _on_accuracy_selected(sa: ACCURACY):
	selected_accuracy = sa
	high_accuracy_button.disabled = true
	low_accuracy_button.disabled = true
	high_precision_button.disabled = false
	low_precision_button.disabled = false

func _on_precision_selected(sp: PRECISION):
	selected_precision = sp
	high_precision_button.disabled = true
	low_precision_button.disabled = true
	
	check_answer()

func check_answer():
	if selected_accuracy == current_accuracy and selected_precision == current_precision:
		correct_answers += 1
		var dialog = Dialogic.start('accuracy_correct')
		add_child(dialog)
		dialog.connect("timeline_ended", Callable(self, "post_dialog_action"))
	else:
		var dialog = Dialogic.start('accuracy_incorrect')
		add_child(dialog)
		dialog.connect("timeline_ended", Callable(self, "post_dialog_action"))

func post_dialog_action():
	if correct_answers >= ANSWERS_TO_WIN:
		var dialog = Dialogic.start('accuracy_finished')
		add_child(dialog)
	else:
		new_round()

func _draw():
	draw_circle(target_center, target_radius, Color.RED)
