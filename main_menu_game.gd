extends Control

@onready var title: Label            = $"Label"
@onready var start_btn: Button       = $"VBoxContainer/START"
@onready var settings_btn: Button    = $"VBoxContainer/SETTINGS"
@onready var exit_btn: Button        = $"VBoxContainer/EXIT"

var _title_start_pos: Vector2

func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)

	start_btn.scale = Vector2.ONE
	settings_btn.scale = Vector2.ONE
	exit_btn.scale = Vector2.ONE

	_center_pivot(start_btn)
	_center_pivot(settings_btn)
	_center_pivot(exit_btn)
	start_btn.resized.connect(_on_btn_resized.bind(start_btn))
	settings_btn.resized.connect(_on_btn_resized.bind(settings_btn))
	exit_btn.resized.connect(_on_btn_resized.bind(exit_btn))

	_connect_hover_effects(start_btn)
	_connect_hover_effects(settings_btn)
	_connect_hover_effects(exit_btn)

	_title_start_pos = title.position
	title.pivot_offset = title.size / 2.0
	title.resized.connect(func(): title.pivot_offset = title.size / 2.0)
	_animate_title()

func _connect_hover_effects(b: Button) -> void:
	b.mouse_entered.connect(_hover_in.bind(b))
	b.mouse_exited.connect(_hover_out.bind(b))
	b.focus_entered.connect(_hover_in.bind(b))
	b.focus_exited.connect(_hover_out.bind(b))

func _on_btn_resized(b: Button) -> void:
	_center_pivot(b)

func _center_pivot(b: Control) -> void:
	b.pivot_offset = b.size / 2.0

func _hover_in(b: Button) -> void:
	_center_pivot(b)
	var t := get_tree().create_tween()
	t.tween_property(b, "scale", Vector2(1.06, 1.06), 0.09)\
	 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _hover_out(b: Button) -> void:
	var t := get_tree().create_tween()
	t.tween_property(b, "scale", Vector2.ONE, 0.09)\
	 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _press_pop(b: Button) -> void:
	_center_pivot(b)
	var t := get_tree().create_tween()
	t.tween_property(b, "scale", Vector2(0.96, 0.96), 0.05)\
	 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(b, "scale", Vector2(1.06, 1.06), 0.07)\
	 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(b, "scale", Vector2.ONE, 0.06)\
	 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _animate_title() -> void:
	var t := get_tree().create_tween()
	t.set_loops()
	t.parallel().tween_property(title, "position:y", _title_start_pos.y - 10, 0.8)\
	 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(title, "scale", Vector2(1.03, 1.03), 0.8)\
	 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(title, "position:y", _title_start_pos.y, 0.8)\
	 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(title, "scale", Vector2.ONE, 0.8)\
	 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_start_pressed() -> void:
	_press_pop(start_btn)
	get_tree().change_scene_to_file("res://world/lab.tscn")

#enablewhensettingsmade
func _on_settings_pressed() -> void:
	#_press_pop(settings_btn)
	#get_tree().change_scene_to_file("res://world/settings.tscn") #changepathtoprperone
	pass

func _on_exit_pressed() -> void:
	_press_pop(exit_btn)
	get_tree().quit()
