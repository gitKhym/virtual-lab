extends TextureButton

var pressed_once = false

func _ready():
	pressed.connect(_on_PrepareSlideButton_pressed)

func _on_PrepareSlideButton_pressed():
	if not pressed_once:
		pressed_once = true
		self.disabled = true

		var tween = create_tween()
		
		var viewport_height = get_viewport_rect().size.y
		var target_y = viewport_height + self.size.y

		tween.tween_property(self, "position:y", target_y, 0.5)
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_QUAD)
