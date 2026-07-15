extends Control
class_name ArtistPage

signal info_requested()
signal info_displayed()

@onready var loading_overlay: Control = %LoadingOverlay
@onready var loading_info: Label = %LoadingInfo


@onready var default_position: Vector2 = position
@onready var close_button: Button = %CloseButton

@onready var scroll_container: ScrollContainer = %ScrollContainer

@onready var artist_cover: TextureRect = %ArtistCover
@onready var subscribers_count: Label = %SubscribersCount
@onready var artist_name: Label = %ArtistName
@onready var monthly_listeners_count: Label = %MonthlyListenersCount
@onready var channel_description: Label = %ChannelDescription
@onready var popular_titles: ArtistPageContent = %PopularTitles


var artist_cover_size: Vector2

func _ready() -> void:
	Global.artist_page = self
	#close()
	open()
	
	clip_contents = true
	
	close_button.pressed.connect(_on_close_button_pressed)
	scroll_container.get_v_scroll_bar().scrolling.connect(_on_scroll_bar_scrolling)
	info_requested.connect(_on_info_requested)
	info_displayed.connect(_on_info_displayed)
	

func _data_callback(data: Dictionary):
	if data.get("success"):
		display_infos(data.get("infos", {}))
	else:
		Global.logs_display.write("error: %s" % data.get("error"), LogsDisplay.MESSAGE.ERROR)
		push_error("error: %s" % data.get("error"), "")

func gather_and_display_infos(channel_id: String):
	info_requested.emit()
	loading_info.text = "Gathering infos"
	var script = ProjectSettings.globalize_path("res://PythonFiles/ytmusic_get_artist_infos.py")
	UsePython.execute_python_script(
		[
			script,
			channel_id
		],
		_data_callback
	)

func display_infos(infos: Dictionary) -> void:
	#print('display infos ', infos)
	
	print(infos.get("songs", ""))
	print(infos.get("albums", ""))
	
	artist_cover_size = artist_cover.size
	scroll_container.scroll_vertical = artist_cover_size.y / 2
	
	artist_name.text = infos.get("name", "")
	
	var subscribers: String = infos.get("subscribers", "")
	if subscribers != "":
		subscribers += " subscribers"
	subscribers_count.text = subscribers
	
	var monthly_listeners: String = infos.get("monthlyListeners", "")
	if monthly_listeners != "":
		monthly_listeners += " monthly listeners"
	monthly_listeners_count.text = monthly_listeners
	
	channel_description.text = infos.get("description", "") if infos.get("description", "") else ""
	
	## finds the biggest thumbnail
	var thumbnails: Array = infos.get("thumbnails", [])
	if thumbnails != []:
		var max_url: String = get_biggest_thumbnail_url(thumbnails)
		if max_url != "":
			Scrapper.process_func = Scrapper.process_image
			Scrapper.download_url(
				max_url,
				func(image:Image):
					artist_cover.texture = ImageTexture.create_from_image(image)
			)
		else:
			var image: Image = Image.new()
			image.fill(Color.BLACK)
			artist_cover.texture = ImageTexture.create_from_image(image)
			
	_display_popular_titles(infos.get("songs", {}))
	
	info_displayed.emit()

func get_biggest_thumbnail_url(thumbnails: Array) -> String:
	var max_width: float = 0.0
	var max_url: String = "" ## url for the biggest thumbnail
	for dict: Dictionary in thumbnails:
		var dict_width: float = dict.get("width", 0.0)
		if dict_width > max_width:
			max_width = dict_width
			max_url = dict.get("url", "")
	return max_url

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

func _display_popular_titles(popular_titles_dict: Dictionary) -> void:
	print("popular_titles_dict ", popular_titles_dict)
	if popular_titles_dict.get("success") == false:
		push_error("error %s" % popular_titles_dict.get("error"))
		return
	
	var songs: Dictionary = popular_titles_dict.get("result")
	for track in songs.get("tracks"):
		var video_id: String = track.get("videoId")
		if video_id == null:
			push_error("video id is null :c")
			continue
		var result_song_item: Global.ResultSongItem = Global.create_result_song_item(video_id)
		result_song_item.scroll_list_belong = popular_titles
		result_song_item.SongName = track.get("title", "")
		result_song_item.Artists = track.get("artists", []).map(func(item): return item["name"])
		popular_titles._add_item(result_song_item)

func _on_close_button_pressed() -> void:
	close()

func _on_scroll_bar_scrolling() -> void:
	
	if scroll_container.scroll_vertical <= artist_cover_size.y / 2:
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	else:
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS

func _on_info_requested() -> void:
	loading_overlay.show()

func _on_info_displayed() -> void:
	loading_overlay.hide()

#
