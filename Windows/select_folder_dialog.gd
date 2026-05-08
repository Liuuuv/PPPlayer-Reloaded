extends FileDialog
class_name SelectFolderDialog

signal closing_window()

var selected_dir_path: String = ""

func _ready() -> void:
	Global.select_folder_dialog = self
	
	canceled.connect(_on_canceled)
	dir_selected.connect(_on_dir_selected)



func ask_for_folder(base_global_path: String = ""):
	selected_dir_path = ""
	current_dir = base_global_path
	show()
	await closing_window
	return selected_dir_path

func close_window() -> void:
	closing_window.emit()
	hide()

func _on_dir_selected(dir: String):
	print("_on_dir_selected ", dir)
	selected_dir_path = dir

func _on_canceled():
	close_window()

func _on_close_window():
	close_window()
