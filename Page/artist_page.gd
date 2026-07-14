extends Control
class_name ArtistPage

@onready var default_position: Vector2 = position
@onready var close_button: Button = %CloseButton

@onready var scroll_container: ScrollContainer = %ScrollContainer

@onready var artist_cover: TextureRect = %ArtistCover
@onready var subscribers_count: Label = %SubscribersCount
@onready var artist_name: Label = %ArtistName
@onready var monthly_listeners_count: Label = %MonthlyListenersCount


var artist_cover_size: Vector2

func _ready() -> void:
	Global.artist_page = self
	close()
	
	clip_contents = true
	
	close_button.pressed.connect(_on_close_button_pressed)
	scroll_container.get_v_scroll_bar().scrolling.connect(_on_scroll_bar_scrolling)

func gather_and_display_infos(channel_id: String):
	var script = ProjectSettings.globalize_path("res://PythonFiles/ytmusic_get_artist_infos.py")
	UsePython.execute_python_script(
		[
			script,
			channel_id
		],
		print
	)

func display_infos(infos: Dictionary) -> void:
	artist_cover_size = artist_cover.size
	scroll_container.scroll_vertical = artist_cover_size.y / 2
	
	artist_name.text = infos.get("name", "")
	subscribers_count.text = infos.get("subscribers", "")
	monthly_listeners_count.text = infos.get("monthlyListeners", "")
	
	
	## finds the biggest thumbnail
	var max_width: float = 0.0
	var max_url: String = "" ## url for the biggest thumbnail
	for dict: Dictionary in infos.get("thumbnails", []):
		var dict_width: float = dict.get("width", 0.0)
		if dict_width > max_width:
			max_width = dict_width
			max_url = dict.get("url", "")
	
	Scrapper.process_func = Scrapper.process_image
	Scrapper.download_url(
		max_url,
		func(image:Image):
			artist_cover.texture = ImageTexture.create_from_image(image)
	)



func open():
	show()
	#display_infos()
	
	
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
	
	if scroll_container.scroll_vertical <= artist_cover_size.y / 2:
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	else:
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS




#
