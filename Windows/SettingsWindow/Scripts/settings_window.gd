extends Window
class_name SettingsWindow

@onready var tab_container: TabContainer = %TabContainer

@onready var clear_file_cache_button: ButtonComponent = %ClearFileCacheButton
@onready var clear_memory_cache_button: ButtonComponent = %ClearMemoryCacheButton
@onready var clear_file_memory_cache_button: ButtonComponent = %ClearFileMemoryCacheButton
@onready var fix_file_desync_button: ButtonComponent = %FixFileDesyncButton

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
	
	fix_file_desync_button.pressed.connect(_on_fix_file_desync_button_pressed)
	
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
	CacheManager._result_thumbnail_cache = {}
	CacheManager._thumbnail_cache = {}

func _on_clear_file_memory_cache_button_pressed() -> void:
	Tools.clear_file_cache()
	CacheManager._result_thumbnail_cache = {}
	CacheManager._thumbnail_cache = {}

func _on_got_current_version() -> void:
	ytdlp_version_label.text = ytdlp_version_label.text % YtDlp.current_version.strip_edges()

func _on_fix_file_desync_button_pressed() -> void:
	var time = Time.get_ticks_msec()
	_add_song_infos_from_downloaded_songs()
	_add_downloaded_song_from_song_info()
	_update_song_infos_from_folder()

## if youtube_id is missing from song_info[br]
## or[br]
## if local_id is missing from song_infos.
func _add_song_infos_from_downloaded_songs() -> void:
	var time = Time.get_ticks_msec()
	var song_infos_changed: bool = false
	for youtube_id: String in Global.downloaded_songs.keys():
		var local_id: String = Global.downloaded_songs.get(youtube_id)
		
		## if youtube_id is missing from song_info
		if Global.song_infos.has(local_id):
			var song_info: Dictionary = Global.song_infos.get(local_id)
			if not song_info.get("video_id", ""):
				song_info.set("video_id", youtube_id)
				print("Downloaded songs > Song infos: missing YouTube ID ", local_id)
				song_infos_changed = true
		else: ## if local_id is missing from song_infos
			Global.song_infos.set(local_id, {"video_id": youtube_id})
			song_infos_changed = true
			print("Downloaded songs > Song infos: missing local ID: ", local_id)
	
	if song_infos_changed:
		Global.save_song_infos()
	print("_add_song_infos_from_downloaded_songs: %ss" % ((Time.get_ticks_msec() - time)/1000.0))

## if song_infos has a youtube_id that downloaded_songs has not.
func _add_downloaded_song_from_song_info() -> void:
	var time = Time.get_ticks_msec()
	var downloaded_songs_changed: bool = false
	for local_id: String in Global.song_infos:
		var song_info: Dictionary = Global.song_infos.get(local_id)
		var youtube_id: String = song_info.get("video_id", "")
		if youtube_id:
			if not Global.downloaded_songs.has(youtube_id):
				Global.downloaded_songs.set(youtube_id, local_id)
				print("Song infos > Downloaded songs: missing YouTube ID: %s, with local ID: %s " % [youtube_id, local_id])
		
	
	if downloaded_songs_changed:
		Global.save_downloaded_songs()
	print("_add_downloaded_song_from_song_info: %ss" % ((Time.get_ticks_msec() - time)/1000.0))

## creates song infos if necessary[br]
## and[br]
## sets extension if not done
func _update_song_infos_from_folder():
	var time = Time.get_ticks_msec()
	var dir = DirAccess.open(Global.get_downloads_path())
	var id: String = ""
	var song_infos_changed: bool = false
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			id = file_name.get_basename()
			if not Tools.is_id(id) or not Global.song_infos.has(id):
				file_name = dir.get_next()
				continue
			if not dir.current_is_dir():
				var extension = file_name.get_extension()
				if extension in Global.SUPPORTED_EXTENSIONS:
					#var full_path = Global.get_downloads_path() + file_name
					#print("reload_song_list > fullpath ", full_path)
					
					if not Global.song_infos.has(id):
						Global.create_song_infos(
							id,
							"",
							extension,
							"",
							[],
							"",
							"",
							"",
						)
						song_infos_changed = true
						Global.logs_display.write("Missing (ID:) %s in song infos" % id)
					else:
						var song_info: Dictionary = Global.song_infos_get(id)
						if not song_info.has("extension"):
							song_info.set("extension", extension)
							song_infos_changed = true
			file_name = dir.get_next()
	
	if song_infos_changed:
		Global.save_song_infos()
	print("_update_song_infos_from_folder: %ss" % ((Time.get_ticks_msec() - time)/1000.0))







#
