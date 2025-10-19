extends HSlider

@export var audio_bus_name: String = "BG MUSIC"

var _bus_id: int = -1

func _ready() -> void:

	min_value = 0.0
	max_value = 100.0
	step = 1.0

	_bus_id = AudioServer.get_bus_index(audio_bus_name)
	if _bus_id == -1:
		push_error("Audio bus not found: '%s'".format([audio_bus_name]))
		return

	# Initialize slider from current bus volume
	var current_db: float = AudioServer.get_bus_volume_db(_bus_id)
	var pct: float = clamp(db_to_linear(current_db) * 100.0, 0.0, 100.0)
	value = pct

	value_changed.connect(_on_value_changed_percent)
	_on_value_changed_percent(value)

func _on_value_changed_percent(pct: float) -> void:
	if _bus_id == -1:
		return

	var lin: float = clamp(pct / 100.0, 0.0, 1.0)
	var db: float = clamp(linear_to_db(max(lin, 0.001)), -60.0, 0.0)

	AudioServer.set_bus_volume_db(_bus_id, db)
	AudioServer.set_bus_mute(_bus_id, lin <= 0.001)
