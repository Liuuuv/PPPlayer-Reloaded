extends ButtonComponent

func _pressed() -> void:
	Global.logs_display.write("bonjour", LogsDisplay.MESSAGE.INFO)
