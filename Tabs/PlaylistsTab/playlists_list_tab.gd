extends Control
class_name PlaylistsListTab

@onready var playlists_list: PlaylistList = %PlaylistsList


func _ready() -> void:
	_initialize.call_deferred()

func _initialize() -> void:
	reload_playlists()

func reload_playlists() -> void:
	playlists_list.clear_items()
	for playlist_name in Global.playlists.get("playlists", {}):
		var playlist_info: Dictionary = Global.playlists.get("playlists", {}).get(playlist_name, {})
		var playlist_content: Array = playlist_info.get("content", [])
		var playlist_item: Global.PlaylistItem = Global.PlaylistItem.new()
		playlist_item.initialize(
			playlist_name,
			playlist_info.get("description", ""),
			len(playlist_content),
			playlist_info.get("duration_string", ""),
		)
		playlists_list._add_item(playlist_item)




















#
