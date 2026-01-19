extends ButtonComponent


func _ready() -> void:
	Global.settings_changed.connect(_on_settings_changed)

func _physics_process(delta: float) -> void:
	return

func _on_settings_changed():
	print("_on_settings_changed")
	tooltip_text = Global.get_downloads_path()

func _pressed() -> void:
	var new_downloads_path: String = await Global.select_file_dialog.ask_for_folder(Tools.filepath_to_global(Global.get_downloads_path()))
	if new_downloads_path != "":
		Global.change_downloads_path(new_downloads_path)
	
	
