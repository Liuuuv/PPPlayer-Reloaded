extends Window
class_name SettingsWindow

func _ready() -> void:
	Global.settings_window = self
	
	close_requested.connect(_on_close_requested)

func open() -> void:
	show()

func close() -> void:
	hide()

func _on_close_requested():
	close()
