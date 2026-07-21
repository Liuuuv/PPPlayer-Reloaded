extends Control
class_name PlaylistsTab

@onready var playlists_list: PlaylistList = %PlaylistsList

func _ready() -> void:
	Global.playlists_tab = self
	_initialize.call_deferred()

func _initialize():
	for playlist_name in Global.playlists:
		var playlist_info: Dictionary = Global.playlists.get(playlist_name, {})
		var playlist_content: Dictionary = playlist_info.get("content", {})
		var playlist_item: Global.PlaylistItem = Global.PlaylistItem.new()
		playlist_item.initialize(
			playlist_name,
			playlist_info.get("description", ""),
			len(playlist_info.get("youtube_ids", [])),
			playlist_info.get("duration_string", ""),
		)
		playlists_list._add_item(playlist_item)
	
