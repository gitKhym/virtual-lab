extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dlg = Dialogic.start("question1")   # use the timeline NAME, not file path
	add_child(dlg)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
