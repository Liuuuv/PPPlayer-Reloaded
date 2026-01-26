extends Control
class_name DownloadsTab


signal queue_changed()
#signal ready_to_dl()
signal try_dl()

@onready var songs_downloads: Control = %SongsDownload

var is_ready_to_dl: bool = false:
	set(on):
		is_ready_to_dl = on
		#if on:
			#ready_to_dl.emit()
var downloading_queue: Array[String] = []
var current_downloading_song: String = ""


func _ready() -> void:
	Global.downloads_tab = self
	is_ready_to_dl = true
	
	reload_queue_song_items()
	
	#ready_to_dl.connect(_on_ready_to_dl)
	try_dl.connect(_on_try_dl)
	queue_changed.connect(_on_queue_changed)

func add_id_to_queue(video_id: String):
	#print("adding ", id, "to queue")
	Global.logs_display.write("Adding an ID to the download queue: %s" % video_id, LogsDisplay.MESSAGE.DEBUG)
	downloading_queue.push_front(video_id)
	try_dl.emit()
	queue_changed.emit()

func add_multiple_ids_to_queue(ids: PackedStringArray):
	Global.logs_display.write("Adding multiple IDs to the download queue: %s" % ids, LogsDisplay.MESSAGE.DEBUG)
	downloading_queue.append_array(ids)
	#print("downloading_queue ", downloading_queue)
	
	try_dl.emit()
	queue_changed.emit()

func remove_from_queue(id: String):
	if id in downloading_queue:
		downloading_queue.erase(id)
		queue_changed.emit()

func reload_queue_song_items() -> void:
	#reload_queue_song_itemsOLD()
	#return
	
	songs_downloads.items.clear()
	
	Global.logs_display.write("Reloading download items...", LogsDisplay.MESSAGE.DEBUG)
	for index in range(downloading_queue.size()):
		songs_downloads.items.append(Global.create_download_item(downloading_queue[index]))
	
	songs_downloads.queue_redraw()

func reload_queue_song_itemsOLD() -> void:
	Global.logs_display.write("Reloading download items...", LogsDisplay.MESSAGE.DEBUG)
	for child in get_children():
		child.queue_free()
	
	for index in range(downloading_queue.size()):
		var download_item: DownloadItemOLD = Global.create_download_itemOLD(downloading_queue[index])
		add_child(download_item)

func _on_try_dl():
	#print("_on_try_dl")
	Global.logs_display.write("Trying to download next song..")
	if not is_ready_to_dl or downloading_queue.size() == 0:
		return
	#print("is_ready_to_dl")
	
	is_ready_to_dl = false
	var video_id: String = downloading_queue[0]
	Global.logs_display.write("Downloading a new content, video ID: %s" % video_id)
	if Global.downloaded_songs.has(video_id):
		Global.logs_display.write("This video has already been downloaded, removing it from the queue: video ID: %s" % video_id)
		remove_from_queue(video_id)
		is_ready_to_dl = true
		try_dl.emit()
		return
		
	
	var id: String = Global.generate_new_id()
	var url: String = Tools.build_youtube_url(video_id)
	Global.logs_display.write("Starting the download, video ID %s" % video_id)
	current_downloading_song = video_id
	var infos: Dictionary = await DownloadsManager.download_video_from_url(url, id, true, true)
	current_downloading_song = ""
	if "interrupt" in infos:
		Global.logs_display.write("Did not manage to download videoID: %s, ID: %s" % [video_id, id], LogsDisplay.MESSAGE.ERROR)
	
	var extension: String = "mp3"
	var thumbnail_path: String = ""
	
	Global.create_song_infos(id, infos, extension, video_id, thumbnail_path)
	remove_from_queue(video_id)
	is_ready_to_dl = true
	try_dl.emit()

func _on_queue_changed():
	reload_queue_song_items()
	Global.logs_display.write("Downloading queue changed " + str(downloading_queue))
