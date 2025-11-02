extends Node2D
const CONVERSION_DATA_PATH: String = "res://data/Measurements/conversion_data.json"
const INTRO: String = "res://dialogic/dialogs/measurement/MeasurementIntroduction.dtl"

@onready var bg: CanvasLayer = $UI
@onready var question_label: Label = $UI/uibackground/questionlabel
@onready var feedback_label: Label = $UI/uibackground/feedbacklabel
@onready var answer_marker: Marker2D = $UI/uibackground/answerbox/boxtarget
@onready var choice_boxes: Array[Sprite2D] = [
	$UI/choicebox, $UI/choicebox2, $UI/choicebox3
]
var questions: Array = []
var current_index: int = 0
var current_question: Dictionary = {}
var processing_answer: bool = false


func _ready() -> void:
	_load_conversion_data()
	_start_game()
	var dlg = Dialogic.start(INTRO, "Conversion_introduction")
	if dlg:
		await dlg.tree_exited
	
	
func _load_conversion_data() -> void:
	if not FileAccess.file_exists(CONVERSION_DATA_PATH):
		push_error("Conversion data file not found: %s" % CONVERSION_DATA_PATH)
		return
	
	var file: FileAccess = FileAccess.open(CONVERSION_DATA_PATH, FileAccess.READ)
	if not file:
		push_error("Failed to open file: %s" % CONVERSION_DATA_PATH)
		return
	
	var json: Variant = JSON.parse_string(file.get_as_text())
	if json == null or not json.has("questions"):
		push_error("Invalid JSON or missing 'questions' key")
		return
	questions = json.questions as Array

func _start_game() -> void:
	current_index = 0
	_show_question(current_index)

func _show_question(index: int) -> void:
	if index >= questions.size():
		_finish_game()
		return
	
	current_question = questions[index] as Dictionary
	question_label.text = str(current_question.get("question", "Missing question"))
	_setup_choices()
	feedback_label.text = ""
	processing_answer = false

func _finish_game() -> void:
	question_label.text = "Congratulation!"
	feedback_label.text = "You've finished the warm-up Quiz!"
	for cbox in choice_boxes:
		cbox.visible = false
	await get_tree().create_timer(2.0).timeout
	SceneTransistion.change_scene("res://scenes/simulations/measurements/part2/rulerSimulation.tscn")

func _setup_choices() -> void:
	var choices: Array = current_question.get("choices", []) as Array
	var shuffled_choices: Array = choices.duplicate()
	shuffled_choices.shuffle()
	
	for i in choice_boxes.size():
		var cbox: Sprite2D = choice_boxes[i]
		var has_choice: bool = i < shuffled_choices.size()
		
		cbox.visible = has_choice
		if has_choice:
			var choice_value: String = str(shuffled_choices[i])
			cbox.name = choice_value
			
			if cbox.has_node("choice"):
				var choice_label: Label = cbox.get_node("choice")
				choice_label.text = choice_value
			
			if cbox.has_method("enable_dragging"):
				cbox.enable_dragging()
		
		if cbox.has_method("_reset_position"):
			cbox._reset_position()

func _next_question() -> void:
	current_index += 1
	await get_tree().create_timer(0.5).timeout
	_show_question(current_index)


func _process(_delta: float) -> void:
	if processing_answer:
		return
	
	for cbox in choice_boxes:
		if cbox.visible and _is_choice_snapped(cbox):
			processing_answer = true
			_on_choice_dropped(cbox)
			break

func _is_choice_snapped(choicebox: Sprite2D) -> bool:
	return choicebox.global_position.distance_to(answer_marker.global_position) < 10.0

func _on_choice_dropped(choicebox: Sprite2D) -> void:
	var chosen_value: String = choicebox.name
	var correct_answer: String = str(current_question.get("answer", ""))
	
	if chosen_value == correct_answer:
		feedback_label.text = current_question.get("feedback_correct", "Correct!")
		await get_tree().create_timer(1).timeout
		_next_question()
	else:
		feedback_label.text = current_question.get("feedback_wrong", "Incorrect. Try again.")
		if choicebox.has_method("_reset_position"):
			choicebox._reset_position()
		await get_tree().create_timer(1.5).timeout
		processing_answer = false
