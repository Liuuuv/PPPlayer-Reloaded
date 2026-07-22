extends BasePage
class_name ArtistPage







@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var artist_cover: TextureRect = %ArtistCover
@onready var subscribers_count: Label = %SubscribersCount
@onready var artist_name: Label = %ArtistName
@onready var monthly_listeners_count: Label = %MonthlyListenersCount
@onready var channel_description: Label = %ChannelDescription
@onready var popular_titles: ArtistPageContent = %PopularTitles



var artist_cover_size: Vector2

func _ready() -> void:
	super._ready()
	
	Global.artist_page = self
	close()
	#open()
	
	clip_contents = true
	
	
	scroll_container.get_v_scroll_bar().scrolling.connect(_on_scroll_bar_scrolling)
	info_requested.connect(_on_info_requested)
	info_displayed.connect(_on_info_displayed)


func gather_and_display_infos(channel_id: String) -> void:
	if channel_id == "":
		push_error("No channel ID provided")
		return
	Global.logs_display.write("Gathering and displaying infos for channel ID: %s" % channel_id, LogsDisplay.MESSAGE.INFO)
	open()
	show_loading_overlay()
	current_display_id = channel_id
	var cache_name: String = Global.RESULTS_CACHE_ARTIST_TEMPLATE % channel_id
	var cache_result: Resource = Tools.get_cached_results(cache_name)
	if cache_result:
		Global.logs_display.write("Artist's infos found in cache for channel ID: %s" % channel_id, LogsDisplay.MESSAGE.DEBUG)
		_display_infos(cache_result)
		return
	
	## if no cache
	info_requested.emit()
	loading_info.text = "Gathering infos"
	var script = ProjectSettings.globalize_path(Global.PYTHON_SCRIPTS_PATH.path_join("ytmusic_get_artist_infos.py"))
	UsePython.execute_python_script(
		[
			script,
			channel_id
		],
		func(data: Dictionary): _data_callback(data, channel_id)
	)


## Displays and saves infos
func _data_callback(data: Dictionary, channel_id: String):
	if data.get("success"):
		loading_info.text = "Sucess"
		Global.logs_display.write("Successfully gathered artist informations for channel ID %s" % channel_id, LogsDisplay.MESSAGE.DEBUG)
		
		_save_infos_to_cache(data.get("infos", {}), channel_id)
		await get_tree().process_frame ## some are call deferred
		var cache_name: String = Global.RESULTS_CACHE_ARTIST_TEMPLATE % channel_id
		var cache_result: ArtistCacheResource = Tools.get_cached_results(cache_name)
		if cache_result:
			_display_infos(cache_result)
		else:
			loading_info.text = "No cache result to display."
			loading_logo.hide()
			#push_error("no cache result to display")
	else:
		Global.logs_display.write("error: %s" % data.get("error", ""), LogsDisplay.MESSAGE.ERROR)
		loading_info.text = "Error: %s" % data.get("error", "")
		loading_logo.hide()
		push_error("error: %s" % data.get("error", ""))



func _save_infos_to_cache(infos: Dictionary, channel_id: String) -> void:
	var cached_infos: ArtistCacheResource = ArtistCacheResource.new()
	
	cached_infos.name = infos.get("name", "") if infos.get("name", "") else ""
	cached_infos.subscribers = infos.get("subscribers", "") if infos.get("subscribers", "") else ""
	cached_infos.monthlyListeners = infos.get("monthlyListeners", "") if infos.get("monthlyListeners", "") else ""
	cached_infos.description = infos.get("description", "") if infos.get("description", "") else ""
	cached_infos.channel_id = channel_id
	
	
	var thumbnails: Array = infos.get("thumbnails", [])
	if thumbnails != []:
		Tools.download_biggest_thumbnail(
			thumbnails,
			func(artist_thumbnail: Texture2D):
				Tools._save_to_cache.call_deferred(artist_thumbnail, Tools.get_results_cache_path() + Global.RESULTS_CACHE_ARTIST_THUMBNAIL_TEMPLATE % channel_id + ".res")
				if self.get("current_display_id") == channel_id:
					artist_cover.texture = artist_thumbnail
		)
	
	
	var songs: Dictionary = infos.get("songs", {})
	if songs.get("success") == false:
		push_error("error %s" % songs.get("error"))
		if infos.get("channelId", channel_id) != channel_id:
			gather_and_display_infos(infos.get("channelId", ""))
			return
	else:
		for track in songs.get("result", {}).get("tracks", []):
			var song_id: String = Tools.save_youtube_video_infos_to_cache(track)
			cached_infos.songs.append(song_id)
	
	## save to memory cache
	var cache_name: String = Global.RESULTS_CACHE_ARTIST_TEMPLATE % channel_id
	Tools._result_thumbnail_cache[cache_name] = cached_infos
	
	## save to cache
	var path_to_cach_dir: String = Global.get_downloads_path() + Global.CACHE_DIR_NAME + "/"
	var path_to_results_cach_dir: String = path_to_cach_dir + Global.RESULTS_CACHE_DIR_NAME + "/"
	var full_path: String = path_to_results_cach_dir + cache_name + ".res"
	Tools._save_to_cache(cached_infos, full_path)

func _display_infos(infos: ArtistCacheResource) -> void:
	#print('display infos ', infos)
	
	artist_cover_size = artist_cover.size
	scroll_container.scroll_vertical = 3.0 * artist_cover_size.y / 4.0
	
	artist_name.text = infos.get("name")
	
	var subscribers: String = infos.get("subscribers")
	if subscribers != "":
		subscribers += " subscribers"
	subscribers_count.text = subscribers
	
	var monthly_listeners: String = infos.get("monthlyListeners")
	if monthly_listeners != "":
		monthly_listeners += " monthly listeners"
	monthly_listeners_count.text = monthly_listeners
	
	channel_description.text = infos.get("description")
	
	
	var artist_thumbnail: Texture2D = Tools.get_cached_results(Global.RESULTS_CACHE_ARTIST_THUMBNAIL_TEMPLATE % infos.channel_id)
	if artist_thumbnail:
		artist_cover.texture = artist_thumbnail
	else:
		var image: Image = Image.create(256, 256, false, Image.FORMAT_RGBA8)
		image.fill(Color.BLACK)
		artist_cover.texture = ImageTexture.create_from_image(image)
	
	var songs_cache_results: Array[String] = infos.songs
	_display_popular_titles(songs_cache_results)
	
	
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





func _display_popular_titles(songs: Array[String]) -> void:
	popular_titles.clear_items()
	for song_id in songs:
		var song_cache_name: String = Global.RESULTS_CACHE_SONG_TEMPLATE % song_id
		var song_result_res: SongCacheResource = Tools.get_cached_results(song_cache_name)
		if song_result_res:
			var result_song_item: Global.ResultSongItem = Global.create_result_song_item(song_id)
			result_song_item.scroll_list_belong = popular_titles
			result_song_item.title = song_result_res.title
			result_song_item.artists = song_result_res.artists
			popular_titles._add_item(result_song_item)
		else:
			push_error("No cache for YouTube ID: %s" % song_id)



func _on_scroll_bar_scrolling() -> void:
	
	if scroll_container.scroll_vertical <= artist_cover_size.y / 2:
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	else:
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS

func _on_info_requested() -> void:
	loading_overlay.show()

func _on_info_displayed() -> void:
	loading_overlay.hide()

func _on_reload_button_pressed() -> void:
	gather_and_display_infos(current_display_id)



#
