extends ButtonComponent

func _pressed() -> void:
	OS.shell_open(OS.get_user_data_dir())
