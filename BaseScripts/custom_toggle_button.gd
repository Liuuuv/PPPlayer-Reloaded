extends Button
class_name CustomToggleButton

@export var pressed_icon: Texture2D

@onready var unpressed_icon: Texture2D = icon

func _ready() -> void:
	toggle_mode = true
	
	toggled.connect(_on_toggled)

func _on_toggled(toggled_on: bool):
	if toggled_on:
		icon = pressed_icon
	else:
		icon = unpressed_icon






#
