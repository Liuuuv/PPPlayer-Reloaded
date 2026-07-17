extends Node

signal downloads_folder_changed() ## emitted when a new song has been added to the downloads folder (added by file, downloaded)
signal settings_changed()
signal song_infos_changed()


const SETTINGS_PATH: String = "res://settings.json"
const SONG_INFOS_PATH: String = "res://song_infos.json"
const DOWNLOADED_SONGS_PATH: String = "res://downloaded_songs.json"
const LOGS_PATH: String = "res://logs.json"
const LYRICS_PATH: String = "res://lyrics.json"
const SONG_PREFERENCES_PATH: String = "res://song_preferences.json"

## CACHE
const CACHE_DIR_NAME: String = "_cache" ## in downloads/
const RESULTS_CACHE_DIR_NAME: String = "_results_cache" ## in downloads/CACHE_DIR_NAME
const RESULTS_CACHE_SONG_TEMPLATE: String = "song__%s"
const RESULTS_CACHE_SONG_THUMBNAIL_TEMPLATE: String = "song_thumbnail__%s"
const RESULTS_CACHE_ARTIST_TEMPLATE: String = "artist__%s"
const RESULTS_CACHE_ARTIST_THUMBNAIL_TEMPLATE: String = "artist_thumbnail__%s"
#enum CACHE_TEMPLATES {
	#NONE,
	#RESULTS_CACHE_SONG_TEMPLATE,
	#RESULTS_CACHE_SONG_THUMBNAIL_TEMPLATE,
	#RESULTS_CACHE_ARTIST_TEMPLATE,
	#RESULTS_CACHE_ARTIST_THUMBNAIL_TEMPLATE,
#}

const default_downloads_path: String = "res://downloads/"
const song_item_scene = preload("res://Misc/song_item.tscn")
const download_item_scene = preload("res://Misc/download_item.tscn")

const DEFAULT_SETTINGS: Dictionary = {
	"downloads_path": default_downloads_path,
	"last_id": "",
	"user_path": "",
}

const DEFAULT_SONG_INFOS: Dictionary = {
	"display_name": "",
	"extension": "",
	"video_id": "",
	"thumbnail_path": "",
	"release_date": "",
	"artist": "",
	"artist_id": "",
}


enum SONG_ITEMS_LOCATIONS {
	NONE,
	CURRENT_PLAYLIST,
	DOWNLOADED,
	DOWNLOADS,
}

var settings: Dictionary = DEFAULT_SETTINGS
var song_infos: Dictionary = {} ## {id: {display_name, extension, release_date, artist, album}}
var downloaded_songs: Dictionary = {} ## {id: 0} ## TODO useless bc song_infos exists
var lyrics: Dictionary = {} ## {id: lyrics}
var song_preferences: Dictionary = {} ## {id: {volume_offset: float, like: bool, favorite: bool}}

var main: Main

var select_folder_dialog: SelectFolderDialog
var select_song_dialog: SelectSongDialog
var insert_text_dialog: InsertTextDialog
var confirmation_dialog: CustomConfirmationDialog

var logs_display: LogsDisplay
var settings_window: SettingsWindow
var summary_window: SummaryWindow
var info_window: InfoWindow
var list_window: ListWindow
var edit_lyrics_window: EditLyricsWindow

var current_playlist: CurrentPlaylist ## what's playing now
var downloaded_tab: DownloadedTab ## all the downloaded songs
var downloads_tab: DownloadsTab ## currently downloading
#var songs_download: SongsDownload ## currently downloading
var music_player: MusicPlayer ## not meant to be accesed
var song_panel: SongPanel

var artist_page: ArtistPage
var playlist_page: PlaylistPage

var all_displayed_names: Dictionary = {} ## {display_name: id}

var song_streams: Dictionary = {} ## {id: SongItemOLD}

class SongItem:
	var SongName: String = "SONG NAME"
	var Artist: String = "ARTIST"
	var DurationString: String = "XX:XX"
	var IsInQueue: bool = false
	
	var id: String = "":
		set(new_id):
			id = new_id
			initialize.call_deferred()
	var infos: Dictionary = {}
	var location: SONG_ITEMS_LOCATIONS = SONG_ITEMS_LOCATIONS.NONE
	var scroll_list_belong: SongVirtualScrollList
	var index: int = 0
	
	
	func _init() -> void:
		pass
	
	func initialize():
		#Global.logs_display.write("initializing song item... ID: %s " % id)
		#tooltip_text = "ID: " + id
		infos = Global.song_infos.get(id, {})
		SongName = infos.get("display_name", "") + "          " + id
		Artist = infos.get("artist", "")
	
	func is_selected() -> String:
		if index in scroll_list_belong.multiselection:
			return "■" # ▣
		else:
			if scroll_list_belong.multiselection.is_empty():
				if scroll_list_belong.hovered_idx == index:
					return "☐"
				else:
					return ""
			else:
				return "☐"
	
	func is_thumbnail_hovered() -> bool:
		if scroll_list_belong.hovered_idx == index and scroll_list_belong.is_hovering_thumbnail:
			return true
		else:
			return false

class DownloadSongItem:
	var SongName: String = "SONG NAME"
	
	var video_id: String = "":
		set(new_id):
			video_id = new_id
			initialize.call_deferred()
	var infos: Dictionary = {}
	var location: String = ""
	var index: int = 0
	var is_downloading: bool = false
	
	
	func _init() -> void:
		pass
	
	func initialize():
		pass
		#Global.logs_display.write("initializing song item... ID: %s " % id)
		##tooltip_text = "ID: " + id
		#infos = Global.song_infos.get(id, {})
		#SongName = infos.get("display_name", "") + "          " + id
	
	func is_current_downloading_song(video_id: String) -> String:
		return "DOWNLOADING" if Global.downloads_tab.current_downloading_song == video_id else ""

class ResultSongItem:
	var title: String = "SONG NAME"
	var artists: Array = ["ARTIST"]
	var duration_string: String = "XX:XX"
	
	var id: String = "":
		set(new_id):
			id = new_id
			initialize.call_deferred()
	var infos: Dictionary = {}
	var scroll_list_belong: SongVirtualScrollList
	var index: int = 0
	
	
	func _init() -> void:
		pass
	
	func initialize():
		#Global.logs_display.write("initializing song item... ID: %s " % id)
		#tooltip_text = "ID: " + id
		pass
	
	
	
	func is_thumbnail_hovered() -> bool:
		if scroll_list_belong.hovered_idx == index and scroll_list_belong.is_hovering_thumbnail:
			return true
		else:
			return false
	
	func get_artists() -> String:
		return ", ".join(artists)
	
	func get_thumbnail() -> Texture2D:
		return Tools.get_cached_results(Global.RESULTS_CACHE_SONG_THUMBNAIL_TEMPLATE % id)
	

func _ready() -> void:
	initialize.call_deferred()
	

func initialize() -> void:
	print("initializing global..")
	initialize_settings()
	initialize_song_infos()
	initialize_downloaded_songs()
	initialize_lyrics()
	initialize_song_preferences()
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

func initialize_lyrics() -> void:
	print("initializing lyrics")
	load_lyrics()
	if lyrics == {}:
		save_lyrics()

func initialize_song_preferences() -> void:
	print("initializing lyrics")
	load_song_preferences()
	if song_preferences == {}:
		save_song_preferences()

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
	print("changing downloads path")
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
	logs_display.write("Song infos saved.", LogsDisplay.MESSAGE.INFO)
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

func save_lyrics() -> void:
	Tools.write_json_file(lyrics, LYRICS_PATH)

func load_lyrics() -> void:
	print("loading lyrics")
	lyrics = Tools.load_json_file(LYRICS_PATH)

func load_song_preferences() -> void:
	print("loading song settings")
	song_preferences = Tools.load_json_file(SONG_PREFERENCES_PATH)

func save_song_preferences() -> void:
	Tools.write_json_file(song_preferences, SONG_PREFERENCES_PATH)

func downloaded_song_add(video_id: String):
	downloaded_songs.set(video_id, 0)

func downloaded_song_remove(video_id: String):
	downloaded_songs.erase(video_id)

func change_settings(setting_name: String, value: Variant) -> void:
	settings.set(setting_name, value)
	print("settings changed ", setting_name, " ", value)
	logs_display.write("Settings changed. Setting name: %s, Value: %s" % [setting_name, value])
	save_settings()

func change_song_info(id: String, info_name: String, value: Variant) -> void:
	if not song_infos.has(id):
		song_infos.set(id, {})
		
	
	song_infos.get(id).set(info_name, value)
	logs_display.write("Song infos changed. ID: %s, Info Name: %s, Value: %s" % [id, info_name, value])
	#print("song infos changed ", change_settings)
	save_song_infos()


func create_song_itemOLD(id: String) -> SongItemOLD:
	var song_item = song_item_scene.instantiate()
	song_item.id = id
	return song_item

func create_song_item(id: String) -> SongItem:
	var song_item = SongItem.new()
	song_item.id = id
	return song_item

func create_result_song_item(video_id: String) -> ResultSongItem:
	var song_item = ResultSongItem.new()
	song_item.id = video_id
	return song_item

func create_download_itemOLD(id: String) -> DownloadItemOLD:
	var download_item = download_item_scene.instantiate()
	download_item.id = id
	return download_item

func create_download_item(video_id: String) -> DownloadSongItem:
	var download_item = DownloadSongItem.new()
	download_item.video_id = video_id
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
			
			song_infos.erase(id)
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
