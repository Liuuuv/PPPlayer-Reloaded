extends Node

signal downloads_folder_changed()
signal settings_changed()
signal song_infos_changed()


const SETTINGS_PATH: String = "res://settings.json"
const SONG_INFOS_PATH: String = "res://song_infos.json"
const DOWNLOADED_SONGS_PATH: String = "res://downloaded_songs.json"
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

var select_file_dialog: FileDialog
var select_song_dialog: FileDialog
var insert_text_dialog: InsertTextDialog
var confirmation_dialog: ConfirmationDialog

var logs_display: LogsDisplay

var current_playlist: CurrentPlaylist
var songs_download: SongsDownload
var music_player: MusicPlayer
var song_panel: SongPanel


var song_streams: Dictionary = {} ## {id: SongItem}



func _ready() -> void:
	initialize.call_deferred()
	

func initialize() -> void:
	print("initializing global..")
	initialize_settings()
	initialize_song_infos()
	initialize_downloaded_songs()
	print("settings ", settings)
	print("song_infos ", song_infos)
	
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


func create_song_item(id: String) -> SongItem:
	var song_item = song_item_scene.instantiate()
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
