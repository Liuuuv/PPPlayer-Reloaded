extends SongVirtualScrollList
class_name ArtistPageContent

@onready var initial_custom_minimum_size: Vector2 = custom_minimum_size

@export var stretch_focus_duration: float = 0.2

@export var popular_titles_expand_margin: float = 330.0


func _ready() -> void:
	super._ready()
	Tools.set_mouse_filter_stop_recursivly(template)
	
	_initialize.call_deferred()
	

func _initialize() -> void:
	Global.song_panel.mouse_entered.connect(_on_song_panel_mouse_entered)
	

func _on_item_left_clicked(idx: int) -> void:
	super._on_item_left_clicked(idx)
	mouse_force_pass_scroll_events = false
	can_scroll = true
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel()
	
	var margin: float = 50.0
	var target_scroll: float = global_position.y - Global.artist_page.scroll_container.get_child(0).global_position.y - margin
	#Global.artist_page.scroll_container.set_deferred("scroll_vertical", target_scroll)
	tween.tween_property(Global.artist_page.scroll_container, "scroll_vertical", target_scroll, stretch_focus_duration)
	
	
	
	var extra_size: float = Global.song_panel.global_position.y - popular_titles_expand_margin
	tween.tween_property(self, "custom_minimum_size", initial_custom_minimum_size + Vector2(0, 1.0) * extra_size, stretch_focus_duration)



func _on_mouse_entered() -> void:
	super._on_mouse_entered()

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		_release_focus()

func _release_focus():
	mouse_force_pass_scroll_events = true
	can_scroll = false
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "custom_minimum_size", initial_custom_minimum_size, stretch_focus_duration)


func _on_song_panel_mouse_entered() -> void:
	_release_focus()
	
