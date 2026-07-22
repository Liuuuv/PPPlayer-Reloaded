extends Window
class_name SettingsWindow

@onready var tab_container: TabContainer = %TabContainer

@onready var clear_memory_cache: ButtonComponent = %ClearMemoryCache
@onready var version_label: Label = %VersionLabel
@onready var ytdlp_version_label: Label = %YTDLPVersionLabel


func _ready() -> void:
	Global.settings_window = self
	
	tab_container.current_tab = 0
	
	YtDlp.got_current_version.connect(_on_got_current_version)
	close_requested.connect(_on_close_requested)
	clear_memory_cache.pressed.connect(_on_clear_memory_cache_pressed)
	
	version_label.text = "Version %s" % Config.APP_VERSION
	
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

func _on_got_current_version() -> void:
	ytdlp_version_label.text = ytdlp_version_label.text % YtDlp.current_version.strip_edges()
