extends ButtonComponent

signal confirm()

func _on_pressed() -> void:
	confirm.emit()
