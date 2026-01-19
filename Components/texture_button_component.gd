extends TextureButton
class_name TextureButtonComponent

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	
	toggled.connect(_on_toggled)

func _on_toggled(on: bool) -> void:
	pass
