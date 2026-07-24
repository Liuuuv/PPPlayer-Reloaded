extends Control
class_name DownloadsTab

var min_wait_time: float = 0.5
var max_wait_time: float = 1.5

signal queue_changed()
#signal ready_to_dl()
signal try_dl()

@onready var songs_download: BaseVirtualScrollList = %SongsDownload
@onready var clear_button: ButtonComponent = %ClearButton
@onready var is_running_button: TextureButton = %IsRunningButton
@onready var add_interrupts_button: ButtonComponent = %AddInterruptsButton
@onready var reload_button: ButtonComponent = %ReloadButton

var is_ready_to_dl: bool = false:
	set(on):
		is_ready_to_dl = on
		#if on:
			#ready_to_dl.emit()
var downloading_queue: Array[String] = [] ## video_id s of the downloading queue. Has [member current_downloading_song].
var current_downloading_song: String = "" ## youtube_id of the currently downloading song.
var paused: bool = false

func _ready() -> void:
	Global.downloads_tab = self
	is_ready_to_dl = true
	
	reload_queue_song_items()
	_initialize.call_deferred()
	
	
	is_running_button.toggled.connect(_on_is_running_button_toggled)
	clear_button.pressed.connect(_on_clear_button_pressed)
	add_interrupts_button.pressed.connect(_on_add_interrupts_button_pressed)
	reload_button.pressed.connect(_on_reload_button_pressed)
	#ready_to_dl.connect(_on_ready_to_dl)
	try_dl.connect(_on_try_dl)
	queue_changed.connect(_on_queue_changed)

func _initialize() -> void:
	var stored_queue: Array[String]
	stored_queue.assign(Global.downloads_tracking.get("current_queue", []))
	if stored_queue:
		downloading_queue = stored_queue
		reload_queue_song_items()
		is_running_button.button_pressed = false
	
	Global.main_tab_container.tab_changed.connect(_on_main_tab_container_tab_changed)

func add_id_to_queue(video_id: String) -> void:
	if video_id == "":
		Global.logs_display.write("YouTube ID is empty, I can't download the song.", LogsDisplay.MESSAGE.ERROR)
		return
	#print("adding ", id, "to queue")
	Global.logs_display.write("Adding an ID to the download queue: %s" % video_id, LogsDisplay.MESSAGE.DEBUG)
	downloading_queue.push_front(video_id)
	try_dl.emit()
	queue_changed.emit()

func add_multiple_ids_to_queue(ids: PackedStringArray) -> void:
	Global.logs_display.write("Adding multiple IDs to the download queue: %s" % ids, LogsDisplay.MESSAGE.DEBUG)
	downloading_queue.append_array(ids)
	#print("downloading_queue ", downloading_queue)
	
	try_dl.emit()
	queue_changed.emit()

func remove_from_queue(id: String) -> void:
	if id in downloading_queue:
		downloading_queue.erase(id)
		queue_changed.emit()

func popback_queue() -> String:
	var new_id: String = downloading_queue.pop_front()
	queue_changed.emit()
	return new_id

func reload_queue_song_items() -> void:
	#reload_queue_song_itemsOLD()
	#return
	
	songs_download.items.clear()
	
	Global.logs_display.write("Reloading download items...", LogsDisplay.MESSAGE.DEBUG)
	
	#if current_downloading_song != "":
		#songs_download.items.append(Global.create_download_item(current_downloading_song))
	
	for index in range(downloading_queue.size()):
		songs_download.items.append(Global.create_download_item(downloading_queue[index]))
	
	songs_download.queue_redraw()

func reload_queue_song_itemsOLD() -> void:
	Global.logs_display.write("Reloading download items...", LogsDisplay.MESSAGE.DEBUG)
	for child in get_children():
		child.queue_free()
	
	for index in range(downloading_queue.size()):
		var download_item: DownloadItemOLD = Global.create_download_itemOLD(downloading_queue[index])
		add_child(download_item)

func clear_queue() -> void:
	downloading_queue = []
	queue_changed.emit()

func _on_try_dl():
	#print("_on_try_dl")
	Global.logs_display.write("Trying to download the next song..")
	await get_tree().create_timer(0.1).timeout
	if not is_ready_to_dl:
		Global.logs_display.write("Not ready to DL.", LogsDisplay.MESSAGE.WARNING)
		return
	if downloading_queue.size() == 0:
		Global.logs_display.write("No download left.", LogsDisplay.MESSAGE.INFO)
		return
	#print("is_ready_to_dl")
	
	is_ready_to_dl = false
	#var video_id: String = popback_queue()
	var video_id: String = downloading_queue[0]
	Global.logs_display.write("Downloading a new content, video ID: %s" % video_id)
	if Global.downloaded_songs.has(video_id):
		Global.logs_display.write("This video has already been downloaded, removing it from the queue: video ID: %s" % video_id)
		downloading_queue.erase(video_id)
		is_ready_to_dl = true
		try_dl.emit()
		return
		
	
	var local_id: String = Global.generate_new_id()
	var url: String = Tools.build_youtube_url(video_id)
	Global.logs_display.write("Starting the download, video ID %s" % video_id)
	current_downloading_song = video_id
	#reload_queue_song_items()
	var infos: Dictionary = await DownloadsManager.download_video_from_url(url, local_id, true, true)
	#current_downloading_song = ""
	#reload_queue_song_items()
	
	if "interrupt" in infos:
		var downloads_tracking_interrupt = Global.downloads_tracking.get("interrupt", [])
		downloads_tracking_interrupt.append(video_id)
		Global.downloads_tracking.set("interrupt", downloads_tracking_interrupt)
		Global.save_downloads_tracking()
		## sometimes it had already downloaded the thumbnail
		Tools.delete_thumbnail(local_id)
		Global.logs_display.write("Did not manage to download videoID: %s, ID: %s, reason: %s" % [video_id, local_id, infos.get("interrupt", "")], LogsDisplay.MESSAGE.ERROR)
	else: ## success
		var extension: String = Config.default_audio_format_string
		var thumbnail_path: String = ""
		
		Global.create_song_infos(local_id, infos, extension, video_id, thumbnail_path)
		Global.downloaded_tab.reload_list()
		Global.downloaded_song_add(video_id, local_id)
		Global.save_downloaded_songs()
	
	var wait_time: float = randf_range(min_wait_time, max_wait_time)
	print("Waiting %.2fs..." % wait_time)
	await get_tree().create_timer(wait_time).timeout
	print("Finished waiting...")
	
	remove_from_queue(video_id)
	current_downloading_song = ""
	if not paused:
		is_ready_to_dl = true
	try_dl.emit()

func _on_queue_changed():
	Global.downloads_tracking.set("current_queue", downloading_queue)
	#Global.logs_display.write("Downloading queue changed: " + str(downloading_queue))
	reload_queue_song_items()
	
	
	Global.save_downloads_tracking()

func _on_is_running_button_toggled(toggled_on: bool):
	paused = not toggled_on
	
	if paused:
		is_ready_to_dl = false
	else:
		if current_downloading_song == "":
			is_ready_to_dl = true
		try_dl.emit()

func _on_clear_button_pressed() -> void:
	clear_queue()
	var stored_queue: Array = Global.downloads_tracking.get("current_queue", [])
	stored_queue = []
	Global.save_downloads_tracking()

func _on_add_interrupts_button_pressed() -> void:
	var global_interrupt_queue: Array = Global.downloads_tracking.get("interrupt", [])
	if not global_interrupt_queue.is_empty():
		add_multiple_ids_to_queue(global_interrupt_queue)
		Global.downloads_tracking.set("interrupt", [])
		Global.save_downloads_tracking()
	print("Added %s songs to the download queue" % global_interrupt_queue.size())
	Global.logs_display.write("Added %s songs to the download queue" % global_interrupt_queue.size(), LogsDisplay.MESSAGE.INFO)

func _on_reload_button_pressed() -> void:
	reload_queue_song_items()


func _on_main_tab_container_tab_changed(tab: int) -> void:
	if is_visible_in_tree(): ## reliable
		reload_queue_song_items()

#
