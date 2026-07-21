extends BaseVirtualScrollList
class_name PlaylistList

func _on_item_left_clicked(idx: int) -> void:
	super._on_item_left_clicked(idx)
	if idx < 0:
		return
	var playlist_item: Global.PlaylistItem = items.get(idx)
	if playlist_item:
		Global.playlists_tab.display_playlist(playlist_item.playlist_name)















#
