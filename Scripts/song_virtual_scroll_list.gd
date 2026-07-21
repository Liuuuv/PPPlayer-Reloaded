extends BaseVirtualScrollList
class_name SongVirtualScrollList


@export var location: Global.SONG_ITEMS_LOCATIONS ## None is ok, it's planned to be removed
@export var artists_label: Label


@export var thumbnail: TextureRect ## Used for knowing when the thumbnail if hovered

var context_menu: ContextMenu

var left_click_context_menu: ContextMenu
var _context_menu_id_mapping = {} ## because it was not possible to pass a lambda function as an arg (because it was freed to soon because of the GC)

var sub_menu : ContextMenu
var sub_menu_id: int = -1 ## for dynamically changing the submenu
var _sub_menu_id_mapping = {}


var is_hovering_selection_box: bool = false # if x mouse pos is sufficently high
var multiselecting: bool = false:
	set(on):
		if multiselecting == on:
			return
		multiselecting = on
		if not multiselecting:
			multiselection = []
var multiselection: Array = []

var hovering_variables = [
	"is_hovering_thumbnail",
	"is_hovering_artists_label",
]
var is_hovering_thumbnail: bool = false:
	set(on):
		if is_hovering_thumbnail == on:
			return
		is_hovering_thumbnail = on
var is_hovering_artists_label: bool = false

func _ready() -> void:
	super._ready()
	_initialize_context_menu()
	

#func _physics_process(delta: float) -> void:
	#print("selected_idx ", selected_idx)



func add_song_item(id: String) -> Global.SongItem:
	var song_item: Global.SongItem = Global.create_song_item(id)
	song_item.location = location
	song_item.scroll_list_belong = self
	song_item.index = len(items)
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
		Global.SONG_ITEMS_LOCATIONS.DOWNLOADED:
			#context_menu.add_item("Preview", _preview_selected_song, false, null)
			context_menu.add_item("Add to current playlist", _add_selected_song_to_current_playlist, false, null)
			context_menu.add_item("Add to the queue (end)", _add_selected_to_queue_end, false, null)
			context_menu.add_item("Infos", Callable(self, "_show_infos"), false, null)
			context_menu.add_item("Re-download thumbnail", _redownload_thumbnail, false, null)
			
			sub_menu_id = context_menu._nextId
			sub_menu = context_menu.add_submenu("Add to...")
			sub_menu._menu.id_pressed.connect(_on_playlists_sub_menu_id_pressed)
			
			context_menu.add_seperator()
			context_menu.add_item("Delete", Callable(self, "_delete"), false, null)
			
		Global.SONG_ITEMS_LOCATIONS.CURRENT_PLAYLIST:
			context_menu.add_item("Play from here", _play_from_here, false, null)
			#context_menu.add_item("Preview", _preview_selected_song, false, null)
			context_menu.add_item("Infos", Callable(self, "_show_infos"), false, null)
			context_menu.add_item("Remove", Callable(self, "_remove_selected"), false, null)
		Global.SONG_ITEMS_LOCATIONS.RESULTS:
			context_menu.add_item("Download", _download_song, false, null)
			
	
	
	
	
	#context_menu.add_checkbox_item("Enable third Button", Callable(self, "_enableThirdButton"), false, false, null)
	
	context_menu.add_seperator()
	var subMenu : ContextMenu = context_menu.add_submenu("Submenu")
	subMenu.add_item("Run the Submenu Test", Callable(self, "_runTest"), false, null)
	
	context_menu.connect_to(self)
	
	if artists_label:
		_initialize_left_click_context_menu()

func _initialize_left_click_context_menu():
	left_click_context_menu = ContextMenu.new()
	
	left_click_context_menu.MenuOpened.connect(_on_left_click_context_menu_opened)
	left_click_context_menu._menu.id_pressed.connect(_on_left_click_context_id_pressed)
	
	
	left_click_context_menu.attach_to(self)
	left_click_context_menu.set_minimum_size(Vector2i(400, 0))
	#context_menu.add_placeholder_item("%s" % _get_selected_idx(), true, null)
	left_click_context_menu.add_header_item("HEADER", null)
	
	left_click_context_menu.add_seperator()
	
	left_click_context_menu.leftClick = true
	left_click_context_menu.set_condition(_can_show_left_click_context_menu) ## must not be a lambda function for example because it is freed before it is used.
	left_click_context_menu.connect_to(self)

func _can_show_left_click_context_menu():
	return is_hovering_artists_label

func _on_left_click_context_menu_opened() -> void:
	if hovered_idx < 0:
		return
	#_set_header_text("Explore")
	left_click_context_menu.clear_items()
	_context_menu_id_mapping = {}
	left_click_context_menu.add_header_item("Go to", null)
	var base_song_item: Global.BaseSongItem = items.get(hovered_idx)
	## TODO change "get_artists" to "get_artist_names"
	for artist: Dictionary in base_song_item.artists:
		_context_menu_id_mapping.set(left_click_context_menu._nextId, artist.get("id", ""))
		left_click_context_menu.add_item(artist.get("name"), Callable(), false, null)

func _on_left_click_context_id_pressed(id: int):
	Global.artist_page.gather_and_display_infos(_context_menu_id_mapping.get(id, ""))



func _gui_input(event: InputEvent) -> void:
	super._gui_input(event)
	if event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event
		if artists_label:
			
			if _is_hovering_node(mm.position, artists_label) and hovered_idx >= 0:
				is_hovering_artists_label = true
				#mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			else:
				is_hovering_artists_label = false
				#mouse_default_cursor_shape = Control.CURSOR_ARROW
		
		if thumbnail:
			if _is_hovering_node(mm.position, thumbnail) and hovered_idx >= 0:
				is_hovering_thumbnail = true
			else:
				is_hovering_thumbnail = false
			#if is_hovering_thumbnail and hovered_idx >= 0:
				#mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			#else:
				#mouse_default_cursor_shape = Control.CURSOR_ARROW
		
		mouse_default_cursor_shape = Control.CURSOR_ARROW
		for hovering_variable in hovering_variables:
			if get(hovering_variable):
				mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
				break
		

## check if [param pos] (local) is in [param node]'s rect, independently of the scroll.
func _is_hovering_node(pos: Vector2, node: Control) -> bool:
	pos += Vector2(-get_grid_margin(), scroll)
	
	#pos.x -= global_position.x + node.global_position.x
	
	
	var item_size: Vector2 = get_item_size()
	if item_size.x <= 0 or item_size.y <= 0:
		return -1
	
	var cols: int = get_column_count()
	var width: float = item_size.x * cols
	var height: float = get_end_position()
	
	# Check if position is within bounds
	if not Rect2(Vector2.ZERO, Vector2(width, height)).has_point(pos):
		return -1
	
	
	var pos_in_item: Vector2 = Vector2(
		fposmod(pos.x, item_size.x),
		fposmod(pos.y, item_size.y)
	)
	var node_rect: Rect2 = node.get_rect()
	node_rect.position.x = node.global_position.x - global_position.x ## idk why artists_label.global_position - global_position does not work lol
	return node_rect.has_point(pos_in_item)
	

func _get_selected_idx() -> int:
	return selected_idx

func _set_header_text(text: String) -> void:
	if not context_menu.has_header:
		push_error("No header.")
		return
	context_menu._menu.set_item_text(0, text)
	#context_menu._menu.set_item_disabled(0, true)
	

func _set_item_text(index: int, text: String) -> void:
	context_menu._menu.set_item_text(index, text)

func _on_item_left_clicked(idx: int) -> void:
	super._on_item_left_clicked(idx)
	_set_header_text("Selected %s-th song" % idx)
	if is_hovering_selection_box:
		multiselecting = true
		
		if not idx in multiselection:
			multiselection.append(idx)
		else:
			multiselection.erase(idx)
	
	var base_song_item: Global.BaseSongItem = items.get(idx)
	if is_hovering_thumbnail:
		if base_song_item is Global.SongItem:
			_play_from_here()
		elif base_song_item is Global.ResultSongItem:
			if base_song_item.is_downloaded():
				var local_id: String = Global.downloaded_songs.get(base_song_item.id, "")
				if local_id:
					SongManager.add_to_current_playlist(local_id)
					SongManager.play_last_song_from_current_playlist()
			elif base_song_item.is_downloading() or Global.downloads_tab.downloading_queue.has(base_song_item.id):
				pass
			else: ## not downloaded nor downloading
				Global.downloads_tab.add_id_to_queue(base_song_item.id)
	
	if Input.is_action_pressed("ctrl"):
		var video_id: String
		if base_song_item is Global.SongItem:
			var song_info: Dictionary = Global.song_infos.get(base_song_item.id, {})
			video_id = song_info.get("video_id", "")
		elif base_song_item is Global.ResultSongItem:
			video_id = base_song_item.id
		if video_id:
			OS.shell_open(Tools.build_youtube_url(video_id))

	

func _on_item_right_clicked(idx: int) -> void:
	super._on_item_right_clicked(idx)
	#_set_header_text("Selected %s-th song" % idx)

func _on_context_menu_opened() -> void:
	selected_idx = hovered_idx
	if selected_idx != -1:
		for idx in context_menu._menu.item_count:
			if idx == 0 and context_menu.has_header: continue
			context_menu._menu.set_item_disabled(context_menu._menu.get_item_id(idx), false)
		_set_header_text("Selected %s-th song." % selected_idx)
	else:
		_set_header_text("No song hovered.")
		for idx in context_menu._menu.item_count:
			context_menu._menu.set_item_disabled(context_menu._menu.get_item_id(idx), true)
	
	sub_menu.clear_items()
	## TODO last 5 interacted playlist
	for playlist_name: String in Global.playlists:
		_sub_menu_id_mapping.set(sub_menu._nextId, playlist_name)
		sub_menu.add_item(playlist_name, Callable(), false, null)

	sub_menu.add_item("Other", func(): print("uwu"), false, null)

func _on_playlists_sub_menu_id_pressed(id: int):
	if hovered_idx < 0:
		push_error("hovered_idx < 0")
		return
	var song_item: Global.SongItem = items.get(hovered_idx)
	Global.playlists_tab.add_song_to_playlist(song_item.id, _sub_menu_id_mapping.get(id, ""))

func _preview_selected_song() -> void:
	var song_item: Global.SongItem = items.get(selected_idx)
	if song_item == null:
		if not items.has(selected_idx):
			Global.logs_display.write("_preview_selected_song, \"items\" does not contain selected ID: %s" % selected_idx, LogsDisplay.MESSAGE.ERROR)
		return
	SongManager.play_from_id(song_item.id)
	#SongManager.play_last_song_from_current_playlist()

func _add_selected_to_queue_end() -> void:
	var song_item: Global.SongItem = items.get(selected_idx)
	if song_item == null:
		if not items.has(selected_idx):
			Global.logs_display.write("_add_selected_to_queue_end, \"items\" does not contain selected ID: %s" % selected_idx, LogsDisplay.MESSAGE.ERROR)
		return
	SongManager.add_to_queue_end(song_item.id)

func _add_selected_song_to_current_playlist() -> void:
	var song_item: Global.SongItem = items.get(selected_idx)
	if song_item == null:
		if not items.has(selected_idx):
			Global.logs_display.write("_add_selected_song_to_current_playlist, \"items\" does not contain selected ID: %s" % selected_idx, LogsDisplay.MESSAGE.ERROR)
		return
	SongManager.add_to_current_playlist(song_item.id)
	#SongManager.play_last_song_from_current_playlist()

func _play_from_here() -> void: ## should only be called for a current_playlist song
	if location != Global.SONG_ITEMS_LOCATIONS.CURRENT_PLAYLIST:
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

func _redownload_thumbnail() -> void:
	var song_item: Global.SongItem = items.get(selected_idx)
	if song_item == null:
		if not items.has(selected_idx):
			Global.logs_display.write("_redownload_thumbnail, \"items\" does not contain selected ID: %s" % selected_idx, LogsDisplay.MESSAGE.ERROR)
		return
	var video_id: String = song_item.youtube_id
	if video_id == "":
		Global.logs_display.write("No \"video_id\" for ID %s, skipping thumbnail downloading." % song_item.id, LogsDisplay.MESSAGE.INFO)
		return
	var url: String = Tools.build_youtube_url(video_id)
	DownloadsManager.download_thumbnail_from_url(url, song_item.id)

func _delete() -> void:
	var song_item: Global.SongItem = items.get(selected_idx)
	var song_id: String = song_item.id
	var display_name: String = song_item.title
	
	var confirm: bool = await Global.confirmation_dialog.ask_for_confirmation(
		"Are ya sure to delete? (ID: %s)" % song_id,
		"Are you sure you want to permenantly delete %s?" % [display_name]
	)
	if not Global.can_delete_song(song_id):
		Global.confirmation_dialog.ask_for_confirmation(
			"I refuse.",
			"You can't delete this song, maybe it is currently playing?"
		)
		return
	if confirm:
		
		var file_paths = []
		var file_path: String = ""
		
		## cache
		var path_to_cach_dir: String = Global.get_downloads_path() + Global.CACHE_DIR_NAME + "/"
		file_path = path_to_cach_dir + song_id + ".res"
		file_paths.append(file_path)
		
		## thumbnail
		file_path = Global.get_downloads_path() + song_id + ".webp"
		file_paths.append(file_path)
		file_path = Global.get_downloads_path() + song_id + ".jpg"
		file_paths.append(file_path)
		
		## audio
		file_path = Global.get_downloads_path() + song_id + ".mp3"
		file_paths.append(file_path)
		file_path = Global.get_downloads_path() + song_id + ".wav"
		file_paths.append(file_path)
		
		for path in file_paths:
			Tools.delete_file(path)
		
		Global.delete_song_informations(song_id)
		items.remove_at(selected_idx)


func _download_song():
	var song_item: Global.ResultSongItem = items.get(selected_idx)
	if song_item.id != "":
		Global.downloads_tab.add_id_to_queue(song_item.id)













#
