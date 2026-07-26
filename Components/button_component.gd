extends Button
class_name ButtonComponent

@onready var default_icon: Texture2D = icon
@onready var loading_icon: Texture2D = preload("uid://uqagxicvduqv")

## Use this to deactivate the button while a demand is already processing.[br]
## It will disable the button and change its icon.
var is_loading: bool = false:
	set(on):
		if is_loading == on:
			return
		is_loading = on
		if is_loading:
			icon = loading_icon
			disabled = true
		else:
			icon = default_icon
			disabled = false

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	pass
