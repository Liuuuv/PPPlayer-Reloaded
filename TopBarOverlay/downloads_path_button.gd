extends ButtonComponent

var context_menu: ContextMenu

func _ready() -> void:
	_initialize_context_menu()
	
	Global.settings_changed.connect(_on_settings_changed)
	


func _on_settings_changed():
	print("_on_settings_changed")
	tooltip_text = Global.get_downloads_path()

func _pressed() -> void:
	var new_downloads_path: String = await Global.select_folder_dialog.ask_for_folder(Tools.filepath_to_global(Global.get_downloads_path()))
	if new_downloads_path != "":
		Global.change_downloads_path(new_downloads_path)
	

func _initialize_context_menu():
	context_menu = ContextMenu.new()
	
	
	context_menu.attach_to(self)
	context_menu.set_minimum_size(Vector2i(400, 0))
	#context_menu.add_placeholder_item("%s" % _get_selected_idx(), true, null)
	context_menu.add_header_item("HEADER", null)
	context_menu.add_item("Open Folder", _open_downloads_folder, false, null)

	context_menu.connect_to(self)

func _open_downloads_folder() -> void:
	OS.shell_open(Global.get_downloads_path())
