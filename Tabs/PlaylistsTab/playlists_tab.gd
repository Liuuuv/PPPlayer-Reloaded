extends Control
class_name PlaylistsTab

@onready var tab_container: TabContainer = %TabContainer
@onready var playlists_list_tab: PlaylistsListTab = %PlaylistsListTab
@onready var playlist_content_tab: PlaylistContentTab = %PlaylistContentTab


func _ready() -> void:
	Global.playlists_tab = self
	tab_container.current_tab = 0
	
	playlist_content_tab.back_button.pressed.connect(_on_playlist_content_tab_back_button_pressed)
	
	_initialize.call_deferred()

func _initialize() -> void:
	reload_playlists()

func reload_playlists() -> void:
	playlists_list_tab.reload_playlists()

func display_playlist(playlist_name: String) -> void:
	tab_container.current_tab = 1
	playlist_content_tab.display_playlist(playlist_name)

func add_song_to_playlist(local_id: String, playlist_name: String) -> void:
	if not playlist_name in Global.playlists.get("playlists", {}):
		push_error("No playlist named %s" % playlist_name)
		return
	var playlist_infos: Dictionary = Global.playlists.get("playlists", {}).get(playlist_name, {})
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


func _on_playlist_content_tab_back_button_pressed() -> void:
	tab_container.current_tab = 0


















#
