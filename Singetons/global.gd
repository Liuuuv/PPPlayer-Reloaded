extends Node

signal downloads_folder_changed()
signal settings_changed()
signal song_infos_changed()


const SETTINGS_PATH: String = "res://settings.json"
const SONG_INFOS_PATH: String = "res://song_infos.json"
const default_downloads_path: String = "res://downloads/"
const song_item_scene = preload("res://Misc/song_item.tscn")

const DEFAULT_SETTINGS: Dictionary = {
	"downloads_path": default_downloads_path,
	"last_id": "",
	"user_path": "",
}

var settings: Dictionary = DEFAULT_SETTINGS
var song_infos: Dictionary = {} ## {id: {url, name, extension, release_date, artist, album}}


var main: Main

var select_file_dialog: FileDialog
var select_song_dialog: FileDialog
var insert_text_dialog: InsertTextDialog
var confirmation_dialog: ConfirmationDialog

var current_playlist: CurrentPlaylist
var music_player: MusicPlayer
var song_panel: SongPanel


var song_streams: Dictionary = {} ## {id: SongItem}



func _ready() -> void:
	initialize.call_deferred()
	

func initialize() -> void:
	print("initializing global..")
	initialize_settings()
	initialize_song_infos()
	print("settings ", settings)
	print("song_infos ", song_infos)
	
	init_song_items()
	init_download_path()
	
	print("song_labels", song_streams)

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

func generate_new_id() -> String:
	var last_id: String = settings.get("last_id")
	
	## next id
	var next_id: String = Tools.get_next_id(last_id)
	
	change_settings("last_id", next_id)
	
	return next_id
