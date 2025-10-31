extends Control

signal text_submitted(text)

@onready var entry: LineEdit = $Entry
@onready var confirm_btn: Button = $ConfirmBtn

func _ready() -> void:
	confirm_btn.disabled = true
	entry.text_changed.connect(_on_text_changed)
	confirm_btn.pressed.connect(_on_confirm)

func _on_text_changed(t: String) -> void:
	confirm_btn.disabled = t.strip_edges() == ""

func _on_confirm() -> void:
	emit_signal("text_submitted", entry.text)
	queue_free()
