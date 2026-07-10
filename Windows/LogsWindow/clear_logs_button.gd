extends ButtonComponent

signal clear_logs()

func _pressed() -> void:
	clear_logs.emit()
	
