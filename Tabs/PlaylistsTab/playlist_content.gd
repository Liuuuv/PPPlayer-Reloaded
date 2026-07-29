extends BaseTab
class_name PlaylistContentTab

@onready var playlist_content: SongVirtualScrollList = %PlaylistContent
@onready var back_button: ButtonComponent = %BackButton
@onready var reload_button: ButtonComponent = %ReloadButton
@onready var play_button: ButtonComponent = %PlayButton

var current_displayed_playlist_name: String = ""
var local_ids_displayed: Array[String] = [] ## Used ONLY when displaying local IDs, not playlists.

func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)

## Used to display a playlist's content.
func display_playlist(playlist_name: String) -> void:
	current_displayed_playlist_name = playlist_name
	local_ids_displayed = []
	
	playlist_content.clear_items()
	
	var content: Array = Global.playlists.get("playlists", {}).get(playlist_name, {}).get("content", [])
	
	var song_item: Global.SongItem
	var id: String ## will be a YouTube ID except if it starts with "local__". In this case, it's a local ID.
	for idx in len(content):
		id = content.get(idx)
		if id.begins_with("local__"): ## local id
			song_item = Global.create_song_item(id.trim_prefix("local__"))
			playlist_content._add_item(song_item)
		else: ## youtube id
			var local_id: String = Global.downloaded_songs.get(id, "")
			if local_id:
				song_item = Global.create_song_item(local_id)
				playlist_content._add_item(song_item)

## Used to display customized IDs.
func display_ids(local_ids: Array[String]) -> void:
	local_ids_displayed = local_ids.duplicate()
	current_displayed_playlist_name = ""
	
	playlist_content.clear_items()
	
	var song_item: Global.SongItem
	var id: String ## will be a YouTube ID except if it starts with "local__". In this case, it's a local ID.
	for local_id in local_ids:
		song_item = Global.create_song_item(local_id)
		playlist_content._add_item(song_item)


func reset():
	current_displayed_playlist_name = ""

func reload_playlist_content() -> void:
	if current_displayed_playlist_name:
		display_playlist(current_displayed_playlist_name)
	elif not local_ids_displayed.is_empty():
		display_ids(local_ids_displayed)

func _on_play_button_pressed() -> void:
	var local_content: Array[String] = []
	if current_displayed_playlist_name == "": ## Not displaying a playlist
		if not local_ids_displayed.is_empty(): ## Displaying local IDs
			local_content = Array(local_ids_displayed)
	else:
		var content: Array = Global.playlists.get("playlists", {}).get(current_displayed_playlist_name, {}).get("content", [])
		for youtube_id: String in content:
			if youtube_id.begins_with("local__"): ## already a local id
				local_content.append(youtube_id.trim_prefix("local__"))
			else:
				var local_id: String = Global.downloaded_songs.get(youtube_id, "")
				if local_id:
					local_content.append(local_id)
			
	if local_content:
		Global.current_playlist.clear_items()
		Global.current_playlist.content_ids = local_content
		Global.current_playlist.reload_song_items()
		SongManager.play_from_index(0, true)
#
