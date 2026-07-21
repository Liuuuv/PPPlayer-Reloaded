extends Control
class_name PlaylistsTab

@onready var playlists_list: PlaylistList = %PlaylistsList

func _ready() -> void:
	Global.playlists_tab = self
	_initialize.call_deferred()

func _initialize() -> void:
	reload_playlists()

func reload_playlists() -> void:
	playlists_list.clear_items()
	for playlist_name in Global.playlists:
		var playlist_info: Dictionary = Global.playlists.get(playlist_name, {})
		var playlist_content: Array = playlist_info.get("content", [])
		var playlist_item: Global.PlaylistItem = Global.PlaylistItem.new()
		playlist_item.initialize(
			playlist_name,
			playlist_info.get("description", ""),
			len(playlist_content),
			playlist_info.get("duration_string", ""),
		)
		playlists_list._add_item(playlist_item)

func add_song_to_playlist(local_id: String, playlist_name: String) -> void:
	if not playlist_name in Global.playlists:
		push_error("No playlist named %s" % playlist_name)
		return
	var playlist_infos: Dictionary = Global.playlists.get(playlist_name, {})
	var current_content: Array = playlist_infos.get("content", [])
	
	## adds the youtube_id or the local_id
	var song_info: Dictionary = Global.song_infos.get(local_id, {})
	var youtube_id: String = song_info.get("video_id", "")
	if youtube_id:
		current_content.append(youtube_id)
	else:
		current_content.append("local__%s" % local_id)
		
	playlist_infos.set("content", current_content)
	Global.save_playlists()



















#
