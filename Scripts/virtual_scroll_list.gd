extends BaseVirtualScrollList
class_name SongVirtualScrollList


@export var location: Global.SONG_IDS_LOCATIONS

var context_menu: ContextMenu

func _ready() -> void:
	super._ready()
	_initialize_context_menu()

#func _physics_process(delta: float) -> void:
	#print("selected_idx ", selected_idx)

func clear_song_items() -> void:
	items.clear()
	queue_redraw()

func add_song_item(id: String) -> Global.SongItem:
	var song_item: Global.SongItem = Global.create_song_item(id)
	song_item.location = location
	items.append(song_item)
	queue_redraw()
	return song_item

func _initialize_context_menu():
	context_menu = ContextMenu.new()
	
	context_menu.MenuOpened.connect(_on_context_menu_opened)
	
	context_menu.attach_to(self)
	context_menu.set_minimum_size(Vector2i(400, 0))
	#context_menu.add_placeholder_item("%s" % _get_selected_idx(), true, null)
	context_menu.add_header_item("HEADER", null)
	match location:
		Global.SONG_IDS_LOCATIONS.DOWNLOADED:
			context_menu.add_item("Preview", _preview_selected_song, false, null)
			context_menu.add_item("Add to current playlist", _add_selected_song_to_current_playlist, false, null)
			context_menu.add_item("Add to the queue (end)", _add_selected_to_queue_end, false, null)
			context_menu.add_item("Infos", Callable(self, "_show_infos"), false, null)
			context_menu.add_item("Delete (WIP)", Callable(self, "_delete"), false, null)
		Global.SONG_IDS_LOCATIONS.CURRENT_PLAYLIST:
			context_menu.add_item("Play from here", _play_from_here, false, null)
			context_menu.add_item("Preview", _preview_selected_song, false, null)
			context_menu.add_item("Infos", Callable(self, "_show_infos"), false, null)
			context_menu.add_item("Remove", Callable(self, "_remove_selected"), false, null)
	#context_menu.add_checkbox_item("Enable third Button", Callable(self, "_enableThirdButton"), false, false, null)
	
	context_menu.add_seperator()
	var subMenu : ContextMenu = context_menu.add_submenu("Submenu")
	subMenu.add_item("Run the Submenu Test", Callable(self, "_runTest"), false, null)
	
	context_menu.connect_to(self)

func _get_selected_idx() -> int:
	return selected_idx

func _set_header_text(text: String) -> void:
	if not context_menu.has_header:
		push_error("No header.")
		return
	context_menu._menu.set_item_text(0, text)

func _on_item_left_clicked(idx: int) -> void:
	super._on_item_left_clicked(idx)
	_set_header_text("Selected %s-th song" % idx)

func _on_item_right_clicked(idx: int) -> void:
	super._on_item_right_clicked(idx)
	_set_header_text("Selected %s-th song" % idx)

func _on_context_menu_opened() -> void:
	selected_idx = hovered_idx
	_set_header_text("Selected %s-th song" % selected_idx)

func _preview_selected_song() -> void:
	var song_item: Global.SongItem = items.get(selected_idx)
	SongManager.play_from_id(song_item.id)
	#SongManager.play_last_song_from_current_playlist()

func _add_selected_to_queue_end() -> void:
	var song_item: Global.SongItem = items.get(selected_idx)
	SongManager.add_to_queue_end(song_item.id)

func _add_selected_song_to_current_playlist() -> void:
	var song_item: Global.SongItem = items.get(selected_idx)
	SongManager.add_to_current_playlist(song_item.id)
	#SongManager.play_last_song_from_current_playlist()

func _play_from_here() -> void: ## should only be called for a current_playlist song
	if location != Global.SONG_IDS_LOCATIONS.CURRENT_PLAYLIST:
		push_error("trying to play from here not from the current playlist, skipping")
		return
	var song_item: Global.SongItem = items.get(selected_idx)
	SongManager.playing_song_index = selected_idx
	SongManager.play_from_id(song_item.id)

func _remove_selected() -> void:
	items.remove_at(selected_idx)
	queue_redraw()

func _show_infos() -> void:
	var song_item: Global.SongItem = items.get(selected_idx)
	Global.info_window.display_info(song_item.id)
