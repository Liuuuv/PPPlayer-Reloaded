extends Node

signal downloads_folder_changed()
signal settings_changed()
signal song_infos_changed()


const SETTINGS_PATH: String = "res://settings.json"
const SONG_INFOS_PATH: String = "res://song_infos.json"
const DOWNLOADED_SONGS_PATH: String = "res://downloaded_songs.json"
const LOGS_PATH: String = "res://logs.json"
const default_downloads_path: String = "res://downloads/"
const song_item_scene = preload("res://Misc/song_item.tscn")
const download_item_scene = preload("res://Misc/download_item.tscn")

const DEFAULT_SETTINGS: Dictionary = {
	"downloads_path": default_downloads_path,
	"last_id": "",
	"user_path": "",
}

var settings: Dictionary = DEFAULT_SETTINGS
var song_infos: Dictionary = {} ## {id: {url, name, extension, release_date, artist, album}}
var downloaded_songs: Dictionary = {}


var main: Main

var select_folder_dialog: SelectFolderDialog
var select_song_dialog: SelectSongDialog
var insert_text_dialog: InsertTextDialog
var confirmation_dialog: CustomConfirmationDialog

var logs_display: LogsDisplay
var settings_window: SettingsWindow

var current_playlist: CurrentPlaylist ## what's playing now
var downloaded_tab: DownloadedTab ## all the downloaded songs
var songs_download: SongsDownload ## currently downloading
var music_player: MusicPlayer
var song_panel: SongPanel


var song_streams: Dictionary = {} ## {id: SongItemOLD}

class SongItem:
	var SongName: String = "SONG NAME"
	var Artist: String = "ARTIST"
	var DurationString: String = "XX:XX"
	
	var id: String = "":
		set(new_id):
			id = new_id
			initialize.call_deferred()
	var infos: Dictionary = {}
	var location: String = ""
	var index: int = 0
	
	
	func _init() -> void:
		pass
	
	func initialize():
		Global.logs_display.write("initializing song item... ID: %s " % id)
		#tooltip_text = "ID: " + id
		infos = Global.song_infos.get(id, {})
		SongName = infos.get("display_name", "") + "          " + id
		
		#load_thumbnail()
		
	#func initialize_context_menu():
		#context_menu = ContextMenu.new()
		#context_menu.attach_to(self)
		#context_menu.set_minimum_size(Vector2i(400, 0))
		#context_menu.add_item("Infos", Callable(self, "_show_infos"), false, null)
		#context_menu.add_item("Delete", Callable(self, "_delete"), false, null)
		##context_menu.add_checkbox_item("Enable third Button", Callable(self, "_enableThirdButton"), false, false, null)
		#context_menu.add_placeholder_item("Disabled", true, null)
		#context_menu.add_seperator()
		#var subMenu : ContextMenu = context_menu.add_submenu("Submenu")
		#subMenu.add_item("Run the Submenu Test", Callable(self, "_runTest"), false, null)
		#
		#context_menu.connect_to(self)
	
	
	
	#func load_thumbnail() -> void:
		##request_thumbnail_later()
		##return
		#
		#var thumbnail_path: String = Global.get_thumbnail_path(id)
		#if thumbnail_path == "":
			#return
		#
		#if not FileAccess.file_exists(thumbnail_path):
			##print("song_item > load_thumbnail, no thumbnail path provided and this path doesn't work neither: ", full_path)
			#Global.logs_display.write("song_item > load_thumbnail, no thumbnail path provided and this path doesn't work neither: %s" % thumbnail_path, LogsDisplay.MESSAGE.ERROR)
			#return
		#
		#var image := Image.new()
		#var error = image.load(thumbnail_path)
		## TODO W 0:02:39:139   song_item.gd:89 @ load_thumbnail(): Loaded resource as image file, this will not work on export: 'res://downloads/z.webp'. Instead, import the image file as an Image resource and load it normally as a resource.
#
		#if error != OK:
			##push_error("song_item > load_thumbnail, error when loading the thumbnail. Full path: %s, Error: %s" % [full_path, error])
			#Global.logs_display.write("song_item > load_thumbnail, error when loading the thumbnail. Full path: %s, Error: %s" % [thumbnail_path, error], LogsDisplay.MESSAGE.ERROR)
			#return
		#
		#var texture := ImageTexture.create_from_image(image)
		#thumbnail.texture = texture

func _ready() -> void:
	initialize.call_deferred()
	

func initialize() -> void:
	print("initializing global..")
	initialize_settings()
	initialize_song_infos()
	initialize_downloaded_songs()
	print("settings ", settings)
	#print("song_infos ", song_infos)
	
	#init_song_items()
	#init_download_path()
	
	#print("song_labels", song_streams)

func initialize_settings() -> void:
	print("initializing settings..")
	load_settings()
	if settings == {}:
		settings = DEFAULT_SETTINGS
		save_settings()
		load_settings()

func initialize_song_infos() -> void:
	print("initializing song infos..")
	load_song_infos()
	if song_infos == {}:
		save_song_infos()

func initialize_downloaded_songs() -> void:
	print("initializing downloaded songs")
	load_downloaded_songs()
	if downloaded_songs == {}:
		save_downloaded_songs()

func init_song_items():
	var dir = DirAccess.open(get_downloads_path())
	var id: int = 1
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var extension = file_name.get_extension()
				if extension in ["mp3", "ogg", "wav"]:
					var full_path = get_downloads_path() + file_name
					print("fullpath ", full_path)
					song_streams[id] = Tools.get_song_stream(full_path)
					id += 1
			file_name = dir.get_next()

func init_download_path():
	pass

func get_downloads_path() -> String:
	return settings.get("downloads_path")

func change_downloads_path(new_downloads_path: String) -> void:
	print("chaning downloads path")
	if not new_downloads_path.ends_with("/"):
		new_downloads_path += "/"
	settings.set("downloads_path", new_downloads_path)
	settings_changed.emit()
	save_settings()

func save_settings() -> void:
	Tools.write_json_file(settings, SETTINGS_PATH)

func load_settings() -> void:
	print("loading settings..")
	settings = Tools.load_json_file(SETTINGS_PATH)
	if settings != {}:
		settings_changed.emit()

func save_song_infos() -> void:
	Tools.write_json_file(song_infos, SONG_INFOS_PATH)

func load_song_infos() -> void:
	print("loading song infos..")
	song_infos = Tools.load_json_file(SONG_INFOS_PATH)
	if song_infos != {}:
		song_infos_changed.emit()

func save_downloaded_songs() -> void:
	Tools.write_json_file(downloaded_songs, DOWNLOADED_SONGS_PATH)

func load_downloaded_songs() -> void:
	print("loading song infos..")
	downloaded_songs = Tools.load_json_file(DOWNLOADED_SONGS_PATH)

func downloaded_song_add(video_id: String):
	downloaded_songs.set(video_id, 0)

func downloaded_song_remove(video_id: String):
	downloaded_songs.erase(video_id)

func change_settings(setting_name: String, value: Variant) -> void:
	settings.set(setting_name, value)
	print("settings changed ", setting_name, " ", value)
	save_settings()

func change_song_info(id: String, info_name: String, value: Variant) -> void:
	if not song_infos.has(id):
		song_infos.set(id, {})
		
	
	song_infos.get(id).set(info_name, value)
	print("song infos changed ", change_settings)
	save_song_infos()


func create_song_itemOLD(id: String) -> SongItemOLD:
	var song_item = song_item_scene.instantiate()
	song_item.id = id
	return song_item

func create_song_item(id: String) -> SongItem:
	var song_item = SongItem.new()
	song_item.id = id
	return song_item

func create_download_item(id: String) -> DownloadItem:
	var download_item = download_item_scene.instantiate()
	download_item.id = id
	return download_item

func generate_new_id() -> String:
	var last_id: String = settings.get("last_id")
	
	## next id
	var next_id: String = Tools.get_next_id(last_id)
	
	change_settings("last_id", next_id)
	
	return next_id

func create_song_infos(id: String, infos: Dictionary, extension: String, video_id: String = "", thumbnail_path: String = ""):
	
	Global.change_song_info(id, "display_name", infos.get("title", ""))
	Global.change_song_info(id, "extension", extension)
	Global.change_song_info(id, "video_id", video_id)
	Global.change_song_info(id, "thumbnail_path", thumbnail_path)
	Global.change_song_info(id, "release_date", infos.get("release_date", ""))
	Global.change_song_info(id, "artist", infos.get("channel", ""))
	Global.change_song_info(id, "artist_id", infos.get("channel_id", ""))
	#Global.change_song_info(id, "album", album)

func get_thumbnail_path(id: String):
	var song_info: Dictionary = song_infos.get(id)
	if song_info:
		var thumbnail_path: String = song_info.get("thumbnail_path")
		if thumbnail_path == "":
			#Global.logs_display.write("song_item > load_thumbnail, no thumbnail path provided. Trying using: %s" % id + ".webp", LogsDisplay.MESSAGE.WARNING)
			thumbnail_path = id + ".webp"
		
		var full_path: String = Global.get_downloads_path() + thumbnail_path
		return full_path
	else:
		logs_display.write("get_thumbnail_path, Can't find the song info for the ID: %s" % id, LogsDisplay.MESSAGE.ERROR)
		return ""

func delete_song(id: String):
	logs_display.write("Deleting song from ID %s" % id, LogsDisplay.MESSAGE.DEBUG)
	var song_info: Dictionary = song_infos.get(id)
	var error: Error
	if song_info:
		var extension: String = song_info.get("extension", "")
		if extension:
			var full_path: String = get_downloads_path() + id + "." + extension
			error = DirAccess.remove_absolute(full_path)
			if error != OK:
				push_error("delete_song, can't delete the song %s" % full_path)
				logs_display.write("delete_song, Can't delete the file. can't remove the file %s" % full_path, LogsDisplay.MESSAGE.ERROR)
			
			if not downloaded_songs.erase(song_info.get("video_id")):
				logs_display.write("delete_song, the video_id was not available for the ID: %s" % id, LogsDisplay.MESSAGE.ERROR)
			save_downloaded_songs()
			
			var thumbnail_path: String = get_thumbnail_path(id)
			if thumbnail_path != "":
				error = DirAccess.remove_absolute(thumbnail_path)
				if error != OK:
					push_error("delete_song, Can't delete the thumbnail %s" % thumbnail_path)
					logs_display.write("delete_song, Can't delete the thumbnail %s" % full_path, LogsDisplay.MESSAGE.ERROR)
			
			song_info.erase(id)
			save_song_infos()
			
			if current_playlist.content_ids.has(id):
				current_playlist.content_ids.erase(id)
			
		else:
			logs_display.write("delete_song, Can't delete the song. no extension found in song_infos for the ID: %s" % id, LogsDisplay.MESSAGE.ERROR)
			return
	else:
		logs_display.write("delete_song, Can't delete the song. Can't find the song info for the ID: %s" % id, LogsDisplay.MESSAGE.ERROR)
		return
	
	logs_display.write("Successfully deleted the song for the ID: %s" % id, LogsDisplay.MESSAGE.INFO)
