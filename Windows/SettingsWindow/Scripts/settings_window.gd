extends Window
class_name SettingsWindow

@onready var tab_container: TabContainer = %TabContainer

@onready var clear_file_cache_button: ButtonComponent = %ClearFileCacheButton
@onready var clear_memory_cache_button: ButtonComponent = %ClearMemoryCacheButton
@onready var clear_file_memory_cache_button: ButtonComponent = %ClearFileMemoryCacheButton

@onready var version_label: Label = %VersionLabel
@onready var ytdlp_version_label: Label = %YTDLPVersionLabel


func _ready() -> void:
	Global.settings_window = self
	
	tab_container.current_tab = 0
	
	YtDlp.got_current_version.connect(_on_got_current_version)
	close_requested.connect(_on_close_requested)
	clear_file_cache_button.pressed.connect(_on_clear_file_cache_button_pressed)
	clear_memory_cache_button.pressed.connect(_on_clear_memory_cache_button_pressed)
	clear_file_memory_cache_button.pressed.connect(_on_clear_file_memory_cache_button_pressed)
	
	version_label.text = "Version %s" % Config.APP_VERSION
	
func open() -> void:
	show()

func close() -> void:
	hide()

func _on_close_requested() -> void:
	close()

func _on_clear_file_cache_button_pressed() -> void:
	Tools.clear_file_cache()

func _on_clear_memory_cache_button_pressed() -> void:
	Tools._result_thumbnail_cache = {}
	Tools._thumbnail_cache = {}

func _on_clear_file_memory_cache_button_pressed() -> void:
	Tools.clear_file_cache()
	Tools._result_thumbnail_cache = {}
	Tools._thumbnail_cache = {}

func _on_got_current_version() -> void:
	ytdlp_version_label.text = ytdlp_version_label.text % YtDlp.current_version.strip_edges()
