extends CheckButton

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	
	pressed.connect(_on_pressed)
	
	_initialize.call_deferred()

func _initialize():
	Config.disable_logs = not Global.settings.get("logs_enabled", true)
	button_pressed = not Config.disable_logs

func _on_pressed() -> void:
	if button_pressed:
		Config.disable_logs = false
	else:
		Config.disable_logs = true
	Global.settings.set("logs_enabled", not Config.disable_logs)
	Global.save_settings()
