extends Window
class_name SettingsWindow

@onready var clear_memory_cache: ButtonComponent = %ClearMemoryCache


func _ready() -> void:
	Global.settings_window = self
	
	close_requested.connect(_on_close_requested)
	clear_memory_cache.pressed.connect(_on_clear_memory_cache_pressed)
	
	
func open() -> void:
	show()

func close() -> void:
	hide()

func _on_close_requested():
	close()


func _on_clear_memory_cache_pressed() -> void:
	Global.logs_display.write("Deleting cache...", LogsDisplay.MESSAGE.DEBUG)
	var full_path: String = Global.get_downloads_path() + Global.CACHE_DIR_NAME
	if DirAccess.dir_exists_absolute(full_path):
		
		var error: Error = Tools.clear_directory_contents(full_path)
		Tools._result_thumbnail_cache = {}
		Tools._thumbnail_cache = {}
		if error != OK:
			Global.logs_display.write("Error when deleting cache: %s" % error, LogsDisplay.MESSAGE.ERROR)
		else:
			Global.logs_display.write("Cache deleted successfully", LogsDisplay.MESSAGE.INFO)
	else:
		Global.logs_display.write("Cache didn't exist", LogsDisplay.MESSAGE.INFO)
