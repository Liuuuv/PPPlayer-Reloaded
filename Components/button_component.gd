extends Button
class_name ButtonComponent

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	pass
