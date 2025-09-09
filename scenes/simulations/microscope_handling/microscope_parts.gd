extends Node2D

@onready var info_label = $InfoLabel

var part_info = {
	"Eyepiece": "Eyepiece Lens (Ocular) – Look through here (10x or 15x). Tip: Eyepieces can be replaced to change magnification.",
	"Tube": "Tube – Connects eyepiece to objectives.",
	"Arm": "Arm – For support and carrying. Tip: Always carry with one hand on the arm, one under the base.",
	"Base": "Base – Foundation, stabilizes the microscope.",
	"Illuminator": "Illuminator/Light Source – Provides light.",
	"Stage": "Stage + Stage Clips – Where slides go; clips secure them.",
	"Mechanical Stage Knobs": "Mechanical Stage Knobs – Move slide smoothly left-right / up-down.",
	"Revolving Nosepiece": "Revolving Nosepiece (Turret) – Rotates objective lenses.",
	"Objective Lenses": "Objective Lenses (4x, 10x, 40x, 100x) – Different magnifications. Trivia: Color-coded for easy identification.",
	"Rack Stop": "Rack Stop – Prevents lens from crushing slides.",
	"Condenser Lens": "Condenser Lens – Focuses light on specimen.",
	"Diaphragm/Iris": "Diaphragm/Iris – Adjusts light intensity.",
	"Coarse Adjustment Knob": "Coarse Adjustment Knob – Large movements for rough focus.",
	"Fine Adjustment Knob": "Fine Adjustment Knob – Small movements for sharp focus."
}

func _on_part_button_pressed(part_name):
	if part_info.has(part_name):
		info_label.text = part_info[part_name]
