extends Control

@onready var title: Label             = $"Label"
@onready var start_btn: TextureButton = $"VBoxContainer/START"

var _title_start_pos: Vector2

func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)

	start_btn.scale = Vector2.ONE
	_center_pivot(start_btn)
	start_btn.resized.connect(_on_btn_resized.bind(start_btn))

	_title_start_pos = title.position
	title.pivot_offset = title.size / 2.0
	title.resized.connect(func(): title.pivot_offset = title.size / 2.0)
	_animate_title()

func _on_btn_resized(b: Control) -> void:
	_center_pivot(b)

func _center_pivot(b: Control) -> void:
	b.pivot_offset = b.size / 2.0

func _press_pop(b: Control) -> void:
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
	t.tween_property(title, "position:y", _title_start_pos.y - 10, 0.8)\
	 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(title, "position:y", _title_start_pos.y, 0.8)\
	 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.finished.connect(_animate_title) 



func _on_start_pressed() -> void:
	_press_pop(start_btn)
	SceneTransistion.change_scene("res://scenes/main_menu2/main_menu_2.tscn")
