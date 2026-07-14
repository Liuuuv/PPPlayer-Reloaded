extends Control
class_name ArtistPage

@onready var default_position: Vector2 = position
@onready var close_button: Button = %CloseButton

@onready var scroll_container: ScrollContainer = %ScrollContainer

@onready var artist_cover: TextureRect = %ArtistCover


func _ready() -> void:
	Global.artist_page = self
	close()
	
	clip_contents = true
	
	close_button.pressed.connect(_on_close_button_pressed)

func display_infos() -> void:
	
	
	scroll_container.get_v_scroll_bar().scrolling.connect(_on_scroll_bar_scrolling)

func open():
	display_infos()
	show()
	
	var screen_size: Vector2i = DisplayServer.screen_get_size(DisplayServer.SCREEN_OF_MAIN_WINDOW)
	position.y = float(screen_size.y)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", default_position.y, 0.2)
	
	
	await tween.finished
	#await get_tree().create_timer(1.0).timeout
	#hide()

func close():
	hide()

func _on_close_button_pressed() -> void:
	close()

func _on_scroll_bar_scrolling() -> void:
	var artist_cover_size: Vector2 = artist_cover.size
	if scroll_container.scroll_vertical <= artist_cover_size.y / 2:
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	else:
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS




#
