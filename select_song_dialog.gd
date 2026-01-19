extends FileDialog

signal closing_window()

var selected_song_path: String = ""

func _ready() -> void:
	Global.select_song_dialog = self
	
	file_selected.connect(_on_file_selected)
	canceled.connect(_on_canceled)
	


func ask_for_song(base_global_path: String = ""):
	selected_song_path = ""
	current_dir = base_global_path
	show()
	await closing_window
	return selected_song_path

func close_window() -> void:
	closing_window.emit()
	hide()

func _on_file_selected(path: String):
	print("_on_file_selected path ", path)
	selected_song_path = path
	close_window()

func _on_canceled():
	close_window()

func _on_close_window():
	close_window()
