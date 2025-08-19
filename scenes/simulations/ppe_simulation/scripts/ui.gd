extends Control

@onready var title_label = %TitleLabel
@onready var description_label = %DescriptionLabel

func update_text(title: String, description: String):
	title_label.text = title
	description_label.text = description

func clear_text():
	title_label.text = ""
	description_label.text = ""
