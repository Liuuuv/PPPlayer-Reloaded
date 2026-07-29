extends Control
class_name PlaylistsTab

@onready var tab_container: TabContainer = %TabContainer
@onready var playlists_list_tab: PlaylistsListTab = %PlaylistsListTab
@onready var playlist_content_tab: PlaylistContentTab = %PlaylistContentTab


func _ready() -> void:
	Global.playlists_tab = self
	tab_container.current_tab = 0
	
	for i in tab_container.get_child_count():
		var child: BaseTab = tab_container.get_children()[i] as BaseTab
		child.tab_index = i
		child.parent_tab_container = tab_container
	
	playlist_content_tab.back_button.pressed.connect(_on_playlist_content_tab_back_button_pressed)
	playlist_content_tab.reload_button.pressed.connect(_on_playlist_content_tab_reload_button_pressed)
	
	_initialize.call_deferred()

func _initialize() -> void:
	reload_playlists()

func reload_playlists() -> void:
	playlists_list_tab.reload_playlists()

## Returns if [param proposed_name] can be used as a playlist name.[br]
## Call this before [method create_playlist] to ensure the name is safe to use.
func is_name_available(proposed_name: String) -> bool: # TODO, check for good use of letters
	var all_playlists: Dictionary = Global.playlists.get("playlists", {})
	if all_playlists.has(proposed_name):
		return false
	else:
		return true

## Displays the said playlist on the tab.
func display_playlist(playlist_name: String) -> void:
	tab_container.current_tab = 1
	playlist_content_tab.display_playlist(playlist_name)

func create_playlist(playlist_name: String, reload: bool = true):
	var all_playlists: Dictionary = Global.playlists.get("playlists", {})
	if all_playlists.has(playlist_name):
		push_error("This name already exists, skipping.")
		return
	all_playlists.set(playlist_name, {})

## Adds YouTube songs to the [param playlist_name] playlist.[br]
## [b]DO NOT use this function if the songs are already downloaded (and thus has a local_id). Use [method add_song_to_playlist] instead.[/b]
func add_multiple_youtube_ids_to_playlist(youtube_ids: PackedStringArray, playlist_name: String, reload: bool = true) -> void:
	if not playlist_name in Global.playlists.get("playlists", {}):
		push_error("No playlist named %s" % playlist_name)
		return
	for youtube_id: String in youtube_ids:
		add_youtube_id_to_playlist(youtube_id, playlist_name, false)
	if reload:
		reload_playlists()
		reload_playlist_content()

## Adds a YouTube song to the [param playlist_name] playlist.[br]
## [b]DO NOT use this function if the song is already downloaded (and thus has a local_id). Use [method add_song_to_playlist] instead.[/b]
func add_youtube_id_to_playlist(youtube_id: String, playlist_name: String, reload: bool = true) -> void:
	if not playlist_name in Global.playlists.get("playlists", {}):
		push_error("No playlist named %s" % playlist_name)
		return
	if youtube_id.is_empty():
		push_error("The YouTube ID is empty.")
		return
	if not youtube_id.length() == 11:
		push_error("The length of you YouTube ID is NOT 11, is it really a YouTube ID??")
		return
	var all_playlists: Dictionary = Global.playlists.get("playlists", {}).get(playlist_name, {})
	var current_content: Array = all_playlists.get("content", [])
	
	## adds the youtube_id or the local_id
	current_content.append(youtube_id)
		
	all_playlists.set("content", current_content)
	Global.save_playlists()
	if reload:
		reload_playlists()
		reload_playlist_content()

## Adds a song (from its local ID) to the [param playlist_name] playlist.[br]
## If the song is not a YouTube song, it will be specified in the storage.
func add_multiple_songs_to_playlist(local_ids: String, playlist_name: String, reload: bool = true) -> void:
	if not playlist_name in Global.playlists.get("playlists", {}):
		push_error("No playlist named %s" % playlist_name)
		return
	for local_id: String in local_ids:
		add_song_to_playlist(local_id, playlist_name, false)
	if reload:
		reload_playlists()
		reload_playlist_content()

## Adds a song (from its local ID) to the [param playlist_name] playlist.[br]
## If the song is not a YouTube song, it will be specified in the storage.
func add_song_to_playlist(local_id: String, playlist_name: String, reload: bool = true) -> void:
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
	if reload:
		reload_playlists()
		reload_playlist_content()

func remove_from_displayed_playlist(index: int, reload: bool = true) -> void:
	remove_from_playlist(playlist_content_tab.current_displayed_playlist_name, index, reload)
	if reload:
		reload_playlist_content()

## [param index] is the index of the song you'd like to remove.
func remove_from_playlist(playlist_name: String, index: int, reload: bool = true) -> void:
	var playlist_info: Dictionary = Global.playlists.get("playlists", {}).get(playlist_name, {})
	var content: Array = playlist_info.get("content", [])
	content.remove_at(index)
	Global.save_playlists()
	if reload:
		reload_playlists()
		reload_playlist_content()

func delete_playlist(playlist_name: String, reload: bool = true) -> void:
	var all_playlists: Dictionary = Global.playlists.get("playlists", {})
	all_playlists.erase(playlist_name)
	
	var playlist_order: Array = Global.playlists.get("order", {})
	if playlist_order.has(playlist_name):
		playlist_order.erase(playlist_name)
	
	Global.save_playlists()
	if reload:
		reload_playlists()
		reload_playlist_content()

func reload_playlist_content() -> void:
	playlist_content_tab.reload_playlist_content()

func _on_playlist_content_tab_back_button_pressed() -> void:
	tab_container.current_tab = 0
	playlist_content_tab.reset()
	reload_playlists()

func _on_playlist_content_tab_reload_button_pressed() -> void:
	reload_playlist_content()

















#
