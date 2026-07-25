extends Node

signal downloads_folder_changed() ## emitted when a new song has been added to the downloads folder (added by file, downloaded)
signal settings_changed()
signal song_infos_changed()


const SETTINGS_PATH: String = "user://settings.json"
const SONG_INFOS_PATH: String = "user://song_infos.json"
const DOWNLOADED_SONGS_PATH: String = "user://downloaded_songs.json"
var PYTHON_SCRIPTS_PATH = OS.get_user_data_dir().path_join("PythonFiles") + "/"
const LOGS_PATH: String = "user://logs.json"
const LYRICS_PATH: String = "user://lyrics.json"
const PLAYLISTS_PATH: String = "user://playlists.json"
const DOWNLOADS_TRACKING_PATH: String = "user://download_tracking.json"
const SONG_PREFERENCES_PATH: String = "user://song_preferences.json"

## CACHE
const CACHE_DIR_NAME: String = "_cache" ## in downloads/
const RESULTS_CACHE_DIR_NAME: String = "_results_cache" ## in downloads/CACHE_DIR_NAME
const RESULTS_CACHE_SONG_TEMPLATE: String = "song__%s"
const RESULTS_CACHE_SONG_THUMBNAIL_TEMPLATE: String = "song_thumbnail__%s"
const RESULTS_CACHE_ARTIST_TEMPLATE: String = "artist__%s"
const RESULTS_CACHE_ARTIST_THUMBNAIL_TEMPLATE: String = "artist_thumbnail__%s"
const RESULTS_CACHE_SEARCH_RESULT_TEMPLATE: String = "search__%s" ## % query
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
	RESULTS,
	LOCAL_PLAYLIST,
}


var is_in_editor: bool = OS.has_feature("editor")
var settings: Dictionary = DEFAULT_SETTINGS ## Change this with [method change_settings].

## [codeblock]
## local_id: {
##		"artist": String,
##		"artist_id": String,
##		"display_name": String,
##		"extension": String,
##		"release_date": String,
##		"thumbnail_path": String,
##		"video_id": String
##	}
## [/codeblock]
var song_infos: Dictionary = {} ## {id: {display_name, extension, release_date, artist, album}}
var downloaded_songs: Dictionary = {} ## {id: local_id} [br] Stores the [b] YOUTUBE IDS [b].
var lyrics: Dictionary = {} ## {id: lyrics}
var song_preferences: Dictionary = {} ## {id: {volume_offset: float, like: bool, favorite: bool}}
## [codeblock]
## {
## 		"playlists": {
## 			playlist_name: String: {
## 				"content": [
## 					String 	## ('local__XXXX' for local song IDs, otherwise YouTube IDs. In this case 'youtube_id' refers to a local_id, not sharable)
## 				],
## 				"thumbnail": String,
## 				"description": String,
## 				"duration_string": String,
## 			}
## 		}
## 		"order": [
## 			String
## 		]
## }
## [/codeblock]
var playlists: Dictionary = {}
## [codeblock]
## {
## 		"interrupt": [],
## 		"current_queue": [],
## }
## [/codeblock]
var downloads_tracking: Dictionary = {}

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

var current_playlist: CurrentPlaylist ## what's playing now.
var downloaded_tab: DownloadedTab ## all the downloaded songs.
var downloads_tab: DownloadsTab ## currently downloading.
var stats_tab: StatsTab ## where stats are displayed/processed.
var playlists_tab: PlaylistsTab ## Where all the local playlists are shown.
var music_player: MusicPlayer ## not meant to be accesed.
var song_panel: SongPanel

var artist_page: ArtistPage
var playlist_page: PlaylistPage
var search_results_page: SearchResultsPage

var search_tab: SearchTab

var main_tab_container: MainTabContainer

var all_displayed_names: Dictionary = {} ## {id: display_name}

var song_streams: Dictionary = {} ## {id: SongItemOLD}

var active_page: BasePage

class BaseSongItem:
	var id: String = "":
		set = _id_setter
	var title: String = "SONG NAME"
	var artists: Array = [{"name": "ARTIST", "id": ""}]
	var duration_string: String = "XX:XX"
	
	var location: SONG_ITEMS_LOCATIONS = SONG_ITEMS_LOCATIONS.NONE
	var scroll_list_belong: SongVirtualScrollList
	var index: int = 0
	
	func initialize(id_: String, title_: String, artists_: Array, duration_string_: String, scroll_list_belong_: SongVirtualScrollList, index_: int):
		id = id_
		title = title_
		artists = artists_
		duration_string = duration_string_
		scroll_list_belong = scroll_list_belong_
		index = index_
	
	func _id_setter(new_id: String):
		id = new_id
	
	func get_artists() -> String:
		return ", ".join(artists.map(func(a): return a["name"]))

class SongItem extends BaseSongItem: ## Local song items, used to display local songs.
	var IsInQueue: bool = false
	
	var youtube_id: String = ""
	
	func _init() -> void:
		pass
	
	
	func _id_setter(new_id: String):
		super._id_setter(new_id)
		var song_info: Dictionary = Global.song_infos.get(id, {})
		youtube_id = song_info.get("video_id", "")
		title = song_info.get("display_name", "")
		artists = [{"name": song_info.get("artist", ""), "id": song_info.get("artist_id", "")}] ## TODO CHANGE THIS SHI
		#duration_string = song_info.get("display_name", "")
	
	func is_selected() -> String:
		if index in scroll_list_belong.multiselection:
			return "■" # ▣
		else:
			if scroll_list_belong.multiselection.is_empty():
				if scroll_list_belong.hovered_idx == index and scroll_list_belong.is_hovering_selection_box:
					return "☐"
				else:
					return ""
			else:
				if scroll_list_belong.hovered_idx == index and scroll_list_belong.is_hovering_selection_box:
					return "▣"
				else:
					return "☐"
	
	#func is_thumbnail_hovered() -> bool:
		#if scroll_list_belong.hovered_idx == index and scroll_list_belong.is_hovering_thumbnail:
			#return true
		#else:
			#return false
	
	func when_thumbnail_hovered() -> Texture2D:
		if scroll_list_belong.hovered_idx == index and scroll_list_belong.is_hovering_thumbnail:
			return preload("uid://dhv41h24nlxce") ## play icon
		else:
			return null
	
	func is_playing() -> bool:
		return location == Global.SONG_ITEMS_LOCATIONS.CURRENT_PLAYLIST and SongManager.playing_song_index == index

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
	
	func is_currently_downloading() -> bool:
		return Global.downloads_tab.current_downloading_song == video_id

class ResultSongItem extends BaseSongItem:
	var infos: Dictionary = {}
	
	func _init() -> void:
		location = SONG_ITEMS_LOCATIONS.RESULTS
	
	func when_thumbnail_hovered() -> Texture2D:
		if scroll_list_belong.hovered_idx == index and scroll_list_belong.is_hovering_thumbnail:
			if is_downloaded():
				return preload("uid://dhv41h24nlxce") ## play icon
			elif Global.downloads_tab.current_downloading_song == id:
				return preload("uid://uqagxicvduqv") ## loading icon
			elif Global.downloads_tab.downloading_queue.has(id):
				return preload("uid://b5do7mtgrgjaf") ## is in queue icon
			else:
				return preload("uid://d3uf60lqrs7yd") ## download icon
		else:
			return null
	
	func get_artists() -> String:
		return ", ".join(artists.map(func(a): return a["name"]))
	
	func get_thumbnail() -> Texture2D:
		return Tools.get_cached_results(Global.RESULTS_CACHE_SONG_THUMBNAIL_TEMPLATE % id)
	
	func is_downloaded() -> bool:
		return Global.downloaded_songs.has(id) ## id is youtube_id here
	
	func is_downloading() -> bool:
		return Global.downloads_tab.current_downloading_song == id

class PlaylistItem:
	var playlist_name: String = "ayo this is my name"
	var description: String = "a desc? who writes those"
	var num_titles: int = 0
	var duration_string: String = "infinite"
	
	func _init() -> void:
		pass
	
	func initialize(playlist_name_: String, description_: String, num_titles_: int, duration_string_: String):
		playlist_name = playlist_name_
		description = description_
		num_titles = num_titles_
		description = duration_string_

func _ready() -> void:
	initialize.call_deferred()
	print("editor? ", is_in_editor)

func initialize() -> void:
	print("initializing global..")
	initialize_settings()
	initialize_song_infos()
	initialize_downloaded_songs()
	initialize_lyrics()
	initialize_song_preferences()
	initialize_playlists()
	initialize_downloads_tracking()
	print("settings ", settings)
	#print("song_infos ", song_infos)
	
	#init_song_items()
	
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
	print("initializing song preferences")
	load_song_preferences()
	if song_preferences == {}:
		save_song_preferences()

func initialize_playlists() -> void:
	print("initializing playlists")
	load_playlists()
	if playlists == {}:
		playlists = {
			"playlists": {
				"Liked songs": {}
			},
			"order": [
				"Liked songs"
			],
		}
		save_playlists()

func initialize_downloads_tracking() -> void:
	print("initializing playlists")
	load_downloads_tracking()
	if downloads_tracking == {}:
		downloads_tracking.set("interrupt", [])
		downloads_tracking.set("current_queue", [])
		save_downloads_tracking()

#func init_song_items():
	#var dir = DirAccess.open(get_downloads_path())
	#var id: int = 1
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#while file_name != "":
			#if not dir.current_is_dir():
				#var extension = file_name.get_extension()
				#if extension in ["mp3", "ogg", "wav"]:
					#var full_path = get_downloads_path() + file_name
					#print("fullpath ", full_path)
					#song_streams[id] = Tools.get_song_stream(full_path)
					#id += 1
			#file_name = dir.get_next()

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

func load_playlists() -> void:
	print("loading playlists")
	playlists = Tools.load_json_file(PLAYLISTS_PATH)

func save_playlists() -> void:
	Tools.write_json_file(playlists, PLAYLISTS_PATH)

func load_downloads_tracking() -> void:
	print("loading downloads_tracking")
	downloads_tracking = Tools.load_json_file(DOWNLOADS_TRACKING_PATH)

func save_downloads_tracking() -> void:
	Tools.write_json_file(downloads_tracking, DOWNLOADS_TRACKING_PATH)


func downloaded_song_add(youtube_id: String, local_id: String =""): ## [param local_id] represent the local ID.
	downloaded_songs.set(youtube_id, local_id)

func downloaded_song_remove(video_id: String):
	downloaded_songs.erase(video_id)

func change_settings(setting_name: String, value: Variant) -> void:
	settings.set(setting_name, value)
	print("settings changed ", setting_name, " ", value)
	logs_display.write("Settings changed. Setting name: %s, Value: %s" % [setting_name, value])
	save_settings()

func change_song_info(id: String, info_name: String, value: Variant, save: bool = true) -> void:
	if not song_infos.has(id):
		song_infos.set(id, {})
		
	
	song_infos.get(id).set(info_name, value)
	logs_display.write("Song infos changed. ID: %s, Info Name: %s, Value: %s" % [id, info_name, value])
	#print("song infos changed ", change_settings)
	
	if save:
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
	
	Global.change_song_info(id, "display_name", infos.get("title", "") if infos.get("title", "") else "", false)
	Global.change_song_info(id, "extension", extension if extension else "", false)
	Global.change_song_info(id, "video_id", video_id if video_id else "", false)
	
	var release_date: String = infos.get("release_date", "") if infos.get("release_date", "") else ""
	if release_date:
		Global.change_song_info(id, "release_date", infos.get("release_date", "") if infos.get("release_date", "") else "", false)
	else:
		Global.change_song_info(id, "release_date", infos.get("upload_date", "") if infos.get("upload_date", "") else "", false)
	Global.change_song_info(id, "artist", infos.get("channel", "") if infos.get("channel", "") else "", false)
	Global.change_song_info(id, "artist_id", infos.get("channel_id", "") if infos.get("channel_id", "") else "", false)
	#Global.change_song_info(id, "album", album)
	save_song_infos()

func get_thumbnail_path(id: String, extension: String = "webp"):
	var song_info: Dictionary = song_infos.get(id)
	if song_info:
		var thumbnail_path: String = song_info.get("thumbnail_path", "")
		if thumbnail_path == "":
			#Global.logs_display.write("song_item > load_thumbnail, no thumbnail path provided. Trying using: %s" % id + ".webp", LogsDisplay.MESSAGE.WARNING)
			thumbnail_path = id + "." + extension
		
		var full_path: String = Global.get_downloads_path() + thumbnail_path
		return full_path
	else:
		logs_display.write("get_thumbnail_path, Can't find the song info for the ID: %s" % id, LogsDisplay.MESSAGE.ERROR)
		return ""

func can_delete_song(id: String) -> bool:
	if Global.current_playlist.content_ids.has(id):
		if Global.music_player.current_stream_id == id:
			return false
	return true

func delete_song_informations(id: String):
	logs_display.write("Deleting song informations from ID %s" % id, LogsDisplay.MESSAGE.DEBUG)
	Global.song_infos.erase(id)
	Global.save_song_infos()
	Global.song_preferences.erase(id)
	Global.save_song_preferences()
	Global.lyrics.erase(id)
	Global.save_lyrics()
	Global.downloaded_song_remove(id)
	Global.save_downloaded_songs()
	if Global.current_playlist.content_ids.has(id):
		Global.current_playlist.content_ids.erase(id)
	
	logs_display.write("Successfully deleted the song informations for the ID: %s" % id, LogsDisplay.MESSAGE.INFO)
