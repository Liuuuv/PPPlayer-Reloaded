extends Control

@onready var subtitles: Label = %Subtitles

var context_menu: ContextMenu


func _ready() -> void:
	subtitles.text = ""
	_initialize_context_menu()
	
	_initialize.call_deferred()

func _initialize():
	Global.music_player.stream_changed.connect(_on_stream_changed)
	Global.edit_lyrics_window.closing.connect(_on_edit_lyrics_window_closing)

func _initialize_context_menu():
	context_menu = ContextMenu.new()
	
	context_menu.MenuOpened.connect(_on_context_menu_opened)
	
	context_menu.attach_to(self)
	context_menu.set_minimum_size(Vector2i(400, 0))
	#context_menu.add_placeholder_item("%s" % _get_selected_idx(), true, null)
	context_menu.add_header_item("ayo those are lyrics", null)
	context_menu.add_item("Edit", _edit_lyrics, false, null)
	#context_menu.add_checkbox_item("Enable third Button", Callable(self, "_enableThirdButton"), false, false, null)
	
	context_menu.add_seperator()
	
	context_menu.connect_to(self)

func update_display(id: String):
	subtitles.text = Global.lyrics.get(id, "")

func _set_item_text(index: int, text: String) -> void:
	context_menu._menu.set_item_text(index, text)

func _set_header_text(text: String) -> void:
	if not context_menu.has_header:
		push_error("No header.")
		return
	context_menu._menu.set_item_text(0, text)

func _edit_lyrics() -> void:
	Global.edit_lyrics_window.display_lyrics(Global.music_player.current_stream_id)

func _on_context_menu_opened() -> void:
	pass

func _on_stream_changed(_fullpath: String) -> void:
	update_display(Global.music_player.current_stream_id)

func _on_edit_lyrics_window_closing(song_id: String):
	update_display(song_id)



#
