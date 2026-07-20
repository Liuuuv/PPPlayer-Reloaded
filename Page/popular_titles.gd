extends SongVirtualScrollList
class_name ArtistPageContent




func _ready() -> void:
	super._ready()


func _initialize() -> void:
	super._initialize()
	if can_grab_scroll_focus:
		Global.song_panel.mouse_entered.connect(_on_song_panel_mouse_entered)


func _on_item_left_clicked(idx: int) -> void:
	super._on_item_left_clicked(idx)
	
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel()
	
	var margin: float = 50.0
	var target_scroll: float = global_position.y - Global.artist_page.scroll_container.get_child(0).global_position.y - margin
	tween.tween_property(Global.artist_page.scroll_container, "scroll_vertical", target_scroll, stretch_focus_duration)
	
	
	var extra_size: float = Global.song_panel.global_position.y - popular_titles_expand_margin
	tween.tween_property(self, "custom_minimum_size", initial_custom_minimum_size + Vector2(0, 1.0) * extra_size, stretch_focus_duration)



func _on_mouse_entered() -> void:
	super._on_mouse_entered()

func _on_mouse_exited() -> void:
	super._on_mouse_exited()


func _on_song_panel_mouse_entered() -> void:
	if Rect2(Vector2(), Global.song_panel.size).has_point(Global.song_panel.get_local_mouse_position()): ## check if it really entered (idk why but it doesnt work sometimes otherwise if you hold click and release the last item)
		_release_focus()
	
	
