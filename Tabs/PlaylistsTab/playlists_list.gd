extends BaseVirtualScrollList
class_name PlaylistList

var context_menu: ContextMenu

func _ready() -> void:
	super._ready()
	_initialize_context_menu()

func _on_item_left_clicked(idx: int) -> void:
	super._on_item_left_clicked(idx)
	if idx < 0:
		return
	var playlist_item: Global.PlaylistItem = items.get(idx)
	if playlist_item:
		Global.playlists_tab.display_playlist(playlist_item.playlist_name)



func _initialize_context_menu():
	context_menu = ContextMenu.new()
	
	context_menu.MenuOpened.connect(_on_context_menu_opened)
	
	context_menu.attach_to(self)
	context_menu.set_minimum_size(Vector2i(400, 0))
	#context_menu.add_placeholder_item("%s" % _get_selected_idx(), true, null)
	context_menu.add_header_item("HEADER", null)
	
	context_menu.add_item("Delete", _delete, false, null)
	
	
	context_menu.connect_to(self)
	

func _on_context_menu_opened():
	selected_idx = hovered_idx


func _delete() -> void:
	var playlist_item: Global.PlaylistItem = items.get(selected_idx)
	
	var confirm: bool = await Global.confirmation_dialog.ask_for_confirmation(
		"Are ya sure to delete? (%s titles)" % playlist_item.num_titles,
		"Are you sure you want to permenantly delete %s?" % [playlist_item.playlist_name]
	)
	#if not Global.can_delete_song(song_id):
		#Global.confirmation_dialog.ask_for_confirmation(
			#"I refuse.",
			#"You can't delete this song, maybe it is currently playing?"
		#)
		#return
	if confirm:
		Global.playlists_tab.delete_playlist(playlist_item.playlist_name)









#
