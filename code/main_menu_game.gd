extends Control

@onready var title: Label = get_node_or_null("Label")
@onready var start_btn: Button = get_node_or_null("MainButtons/START")
@onready var settings_btn: Button = get_node_or_null("MainButtons/SETTINGS")
@onready var exit_btn: Button = get_node_or_null("MainButtons/EXIT")
@onready var main_buttons: VBoxContainer = get_node_or_null("MainButtons")
@onready var options: Control = get_node_or_null("Options")
@onready var options_back_btn: Button = get_node_or_null("Options/Label/BACK")

var _title_start_pos: Vector2
var _options_tween: Tween

func _ready() -> void:
	if start_btn:
		start_btn.pressed.connect(_on_start_pressed)
		_setup_button(start_btn)
	if settings_btn:
		settings_btn.pressed.connect(_on_settings_pressed)
		_setup_button(settings_btn)
	if exit_btn:
		exit_btn.pressed.connect(_on_exit_pressed)
		_setup_button(exit_btn)
	if options:
		_center_pivot(options)
		options.visible = false
		options.modulate.a = 0.0
		options.scale = Vector2.ONE
	if options_back_btn:
		options_back_btn.pressed.connect(_on_back_pressed)
	if main_buttons:
		main_buttons.visible = true
	if start_btn:
		start_btn.grab_focus()
	if title:
		_title_start_pos = title.position
		title.pivot_offset = title.size / 2.0
		title.resized.connect(func(): title.pivot_offset = title.size / 2.0)
		_animate_title()
	set_process_unhandled_key_input(true)

func _show_options() -> void:
	if not options: return
	if _options_tween and _options_tween.is_valid():
		_options_tween.kill()
	if main_buttons:
		main_buttons.visible = false
	_center_pivot(options)
	options.visible = true
	options.scale = Vector2(0.94, 0.94)
	options.modulate.a = 0.0
	var t := get_tree().create_tween()
	_options_tween = t
	t.set_parallel(true)
	t.tween_property(options, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(options, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _show_main() -> void:
	if not options:
		if main_buttons: main_buttons.visible = true
		return
	if _options_tween and _options_tween.is_valid():
		_options_tween.kill()
	var t := get_tree().create_tween()
	_options_tween = t
	t.set_parallel(true)
	t.tween_property(options, "scale", Vector2(0.94, 0.94), 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.tween_property(options, "modulate:a", 0.0, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.finished.connect(func ():
		if options: options.visible = false
		if main_buttons: main_buttons.visible = true
		if start_btn: start_btn.grab_focus())

func _on_start_pressed() -> void:
	_press_pop(start_btn)
	await get_tree().create_timer(0.18).timeout
	get_tree().change_scene_to_file("res://world/lab.tscn")

func _on_settings_pressed() -> void:
	_press_pop(settings_btn)
	await get_tree().create_timer(0.18).timeout
	_show_options()

func _on_back_pressed() -> void:
	_show_main()

func _on_exit_pressed() -> void:
	_press_pop(exit_btn)
	await get_tree().create_timer(0.18).timeout
	get_tree().quit()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and options and options.visible:
		_on_back_pressed()

func _setup_button(b: Button) -> void:
	b.scale = Vector2.ONE
	_center_pivot(b)
	b.resized.connect(_on_btn_resized.bind(b))
	_connect_hover_effects(b)

func _connect_hover_effects(b: Button) -> void:
	b.mouse_entered.connect(_hover_in.bind(b))
	b.mouse_exited.connect(_hover_out.bind(b))
	b.focus_entered.connect(_hover_in.bind(b))
	b.focus_exited.connect(_hover_out.bind(b))

func _on_btn_resized(b: Button) -> void:
	_center_pivot(b)

func _center_pivot(c: Control) -> void:
	c.pivot_offset = c.size / 2.0

func _hover_in(b: Button) -> void:
	_center_pivot(b)
	var t := get_tree().create_tween()
	t.tween_property(b, "scale", Vector2(1.06, 1.06), 0.09).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _hover_out(b: Button) -> void:
	var t := get_tree().create_tween()
	t.tween_property(b, "scale", Vector2.ONE, 0.09).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _press_pop(b: Button) -> void:
	_center_pivot(b)
	var t := get_tree().create_tween()
	t.tween_property(b, "scale", Vector2(0.96, 0.96), 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(b, "scale", Vector2(1.06, 1.06), 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(b, "scale", Vector2.ONE, 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _animate_title() -> void:
	var t := get_tree().create_tween()
	t.set_loops()
	t.parallel().tween_property(title, "position:y", _title_start_pos.y - 10, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(title, "scale", Vector2(1.03, 1.03), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(title, "position:y", _title_start_pos.y, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(title, "scale", Vector2.ONE, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_back_options_pressed() -> void:
	pass
