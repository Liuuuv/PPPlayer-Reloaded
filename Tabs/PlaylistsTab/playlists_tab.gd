extends Control
class_name PlaylistsTab

@onready var playlists_list: BaseVirtualScrollList = %PlaylistsList

func _ready() -> void:
	Global.playlists_tab = self
	_initialize.call_deferred()

func _initialize():
	for i in 15:
		var playlist_item: Global.PlaylistItem = Global.PlaylistItem.new()
		playlists_list._add_item(playlist_item)
