extends SongVirtualScrollList
class_name CurrentPlaylist

@onready var is_selected_template: Label = %"+is_selected"




var content_ids: Array[String] = [] ## contains the ids of the songs
var queue_ids: Array[String] = [] ## contains the ids of the queue

func _ready() -> void:
	super._ready()
	Global.current_playlist = self
	
	reload_song_items()

func _initialize() -> void:
	super._initialize()
	Global.music_player.stream_changed.connect(_on_stream_changed)

func clear_song_items() -> void:
	content_ids.clear()
	queue_ids.clear()
	super.clear_song_items()

func reload_song_items() -> void:
	_update_items_from_content_and_queue()
	queue_redraw()
	
	
#func _physics_process(delta: float) -> void:
	##print("current_playlist items ", items)
	#if Input.is_action_just_pressed("debug"):
		#_update_items_from_content_and_queue()

func _gui_input(event: InputEvent) -> void:
	super._gui_input(event)
	if event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event
		var template_box: Rect2 = template.get_rect()
		if mm.position.x >= template_box.size.x - is_selected_template.size.x:
			is_hovering_selection_box = true
		else:
			is_hovering_selection_box = false
		
		#var thumbnail_rect: Rect2 = thumbnail.get_global_rect()
		#is_hovering_thumbnail = thumbnail_rect.has_point(mm.position)
		

func _remove_selected() -> void:
	if selected_idx <= SongManager.playing_song_index:
		content_ids.remove_at(selected_idx)
		if selected_idx == SongManager.playing_song_index:
			SongManager.play_next_song()
	elif selected_idx <= SongManager.playing_song_index + queue_ids.size() - 1:
		queue_ids.remove_at(selected_idx - SongManager.playing_song_index)
	else:
		content_ids.remove_at(selected_idx)
	
	super._remove_selected()

#func clear_song_items() -> void:
	#for child in get_children():
		#child.queue_free()
	#content_ids = []
	
func _update_items_from_content_and_queue() -> void:
	if content_ids.is_empty() and queue_ids.is_empty():
		return
	
	items.clear()
	var playing_index: int = SongManager.playing_song_index
	
	var song_item: Global.SongItem
	if not content_ids.is_empty():
		for idx in range(playing_index + 1):
			add_song_item(content_ids.get(idx))
	for idx in range(len(queue_ids)):
		song_item = add_song_item(queue_ids.get(idx))
		song_item.IsInQueue = true
	for idx in range(playing_index + 1, len(content_ids)):
		add_song_item(content_ids.get(idx))

func _add_selected_to_queue_end() -> void:
	super._add_selected_to_queue_end()

func _on_item_left_clicked(idx: int) -> void:
	super._on_item_left_clicked(idx)

func _on_stream_changed(filepath: String):
	if shader_bg:
		queue_redraw()
		if filepath == "":
			shader_bg.hide()
		else:
			shader_bg.show()

#
