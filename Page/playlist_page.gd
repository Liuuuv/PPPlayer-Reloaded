extends BasePage
class_name PlaylistPage

@onready var playlist_content: SongVirtualScrollList = %PlaylistContent


func _ready() -> void:
	super._ready()
	
	Global.playlist_page = self
	close()
#
#func display_local_playlist(playlist_name: String):
	#open()
	#playlist_content.clear_items()
	#
	#var content: Array = Global.playlists.get("playlists", {}).get(playlist_name, {}).get("content", [])
	#
	#var song_item: Global.SongItem
	#var id: String
	#for idx in len(content):
		#id = content.get(idx)
		#if id.begins_with("local__"): ## local id
			#song_item = Global.create_song_item(id.trim_prefix("local__"))
			#playlist_content._add_item(song_item)
		#else: ## youtube id
			#var local_id: String = Global.downloaded_songs.get(id, "")
			#if local_id:
				#song_item = Global.create_song_item(local_id)
				#playlist_content._add_item(song_item)





#
