extends Control
class_name PlaylistContentTab

@onready var playlist_content: SongVirtualScrollList = %PlaylistContent
@onready var back_button: ButtonComponent = %BackButton


func _ready() -> void:
	pass

func display_playlist(playlist_name: String) -> void:
	playlist_content.clear_items()
	
	var content: Array = Global.playlists.get("playlists", {}).get(playlist_name, "").get("content", [])
	
	var song_item: Global.SongItem
	var id: String
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







#
