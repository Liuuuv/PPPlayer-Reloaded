extends VBoxContainer
class_name SongsDownload

signal queue_changed()
#signal ready_to_dl()
signal try_dl()

var is_ready_to_dl: bool = false:
	set(on):
		is_ready_to_dl = on
		#if on:
			#ready_to_dl.emit()
var downloading_queue: Array[String] = []


func _ready() -> void:
	Global.songs_download = self
	is_ready_to_dl = true
	
	reload_queue_song_items()
	
	#ready_to_dl.connect(_on_ready_to_dl)
	try_dl.connect(_on_try_dl)
	queue_changed.connect(_on_queue_changed)

func add_id_to_queue(id: String):
	print("adding ", id, "to queue")
	downloading_queue.push_front(id)
	try_dl.emit()
	queue_changed.emit()

func add_multiple_ids_to_queue(ids: PackedStringArray):
	downloading_queue.append_array(ids)
	print("downloading_queue ", downloading_queue)
	try_dl.emit()
	#queue_changed.emit()

func remove_from_queue(id: String):
	if id in downloading_queue:
		downloading_queue.erase(id)
		queue_changed.emit()

func reload_queue_song_items() -> void:
	for child in get_children():
		child.queue_free()
	
	for index in range(downloading_queue.size()):
		var download_item: DownloadItem = Global.create_download_item(downloading_queue[index])
		#song_item.location = "current_playlist"
		#download_item.index = index
		print("download item", download_item)
		add_child(download_item)

func _on_try_dl():
	print("_on_try_dl")
	if not is_ready_to_dl or downloading_queue.size() == 0:
		return
	print("is_ready_to_dl")
	is_ready_to_dl = false
	var video_id: String = downloading_queue[0]
	var id: String = Global.generate_new_id()
	var url: String = Tools.build_youtube_url(video_id)
	var infos: Dictionary = await DownloadsManager.download_video_from_url(url, id, true, true)
	var extension: String = "mp3"
	var thumbnail_path: String = ""
	
	Global.create_song_infos(id, infos, extension, video_id, thumbnail_path)
	remove_from_queue(video_id)
	is_ready_to_dl = true
	try_dl.emit()

func _on_queue_changed():
	reload_queue_song_items()
