extends Node

signal song_paused()
signal song_unpaused()
signal has_stream_changed()
signal song_deleted(local_id: String)

var is_song_paused: bool = true
var has_stream: bool = false:
	set(on):
		if has_stream != on:
			has_stream = on
			has_stream_changed.emit()
var playing_song_index: int = -1 ## Should only be changed with [method play_from_index] with [member change_index] = [code]true[/code]

func _ready() -> void:
	initialize.call_deferred()

func initialize():
	Global.music_player.stream_changed.connect(_on_stream_changed)
	Global.music_player.finished.connect(_on_song_finished)
	
	WindowsOverlay.PlayPressed.connect(_on_play)
	WindowsOverlay.PausePressed.connect(_on_pause)
	WindowsOverlay.NextPressed.connect(_on_next_pressed)
	WindowsOverlay.PreviousPressed.connect(_on_previous_pressed)
	
	Global.downloads_folder_changed.connect(_on_downloads_folder_changed)
	
	has_stream_changed.emit()

func start_song(full_path: String): ## starts the song from the given path.
	print("starting song : ", full_path)
	Global.music_player.start_song(full_path)
	
	var id: String = Tools.fullpath_to_filename(full_path)
	var song_infos = Global.song_infos.get(id)
	if song_infos:
		Global.song_panel.song_label.text = song_infos.get("display_name", "[i]Untitled[/i]")

func pause_song() -> void:
	Global.music_player.pause_song()
	song_paused.emit()

func unpause_song():
	Global.music_player.unpause_song()
	song_unpaused.emit()

func play_next_song() -> void:
	if playing_song_index >= (Global.current_playlist.content_ids).size():
		Global.music_player.clear_stream()
		return
	play_from_index(playing_song_index + 1)

func play_previous_song() -> void:
	if playing_song_index == 0:
		print("This is already the first song!")
	play_from_index(playing_song_index - 1 if playing_song_index >= 1 else playing_song_index)

func change_song_progression(progression: float): ## 0-100
	if Global.music_player.stream:
		var target_time: float = Global.music_player.stream.get_length() * progression / 100
		Global.music_player.seek(target_time)

## Don't change [member playing_song_index] by yourself.
func play_from_index(index: int, change_index: bool = true) -> void:
	if index < 0 or index >= Global.current_playlist.content_ids.size():
		push_error("index out of range of current playlist size")
		return
	
	
	
	var id: String = Global.current_playlist.content_ids[index]
	if change_index:
		play_from_id(id, index)
	else:
		play_from_id(id)
	
	
	
	
	#var song_info = Global.song_infos.get(id)
	#if song_info:
		#var extension = song_info.get("extension")
		#if extension:
			#var full_path = Global.get_downloads_path() + id + "." + extension
			#start_song(full_path)
		#else:
			#push_error("no extension available for index ", index)
			#return
	#else:
		#push_error("no song info available for index ", index)
		#return

## Always used.
func play_from_id(id: String, new_index: int = -1) -> void:
	if new_index >= 0:
		## update queue
		if new_index < playing_song_index:
			Global.current_playlist.queue_size = 0
		else:
			Global.current_playlist.queue_size -= min(new_index - playing_song_index, Global.current_playlist.queue_size)
		
		playing_song_index = new_index
	
	if Global.current_playlist.queue_size != 0:
		Global.current_playlist.reload_list()
	
	var full_path: String = Tools.get_full_path_from_id(id)
	if full_path:
		start_song(full_path)
	

func add_song_from_file(path: String):
	if path.get_extension() not in Global.SUPPORTED_EXTENSIONS:
		push_error("Filepath %s does not has a supported extension (%s)" % [path, ", ".join(Global.SUPPORTED_EXTENSIONS)])
		return
	print("Adding song from file.. : ", path)
	var id: String = Global.generate_new_id() ## new filename
	Tools.duplicate_file(path, Global.get_downloads_path(), id)
	var extension: String = path.get_extension()
	var song_name: String = path.get_file().get_basename()
	
	Global.create_song_infos(
		id, ## local_id
		song_name, ## display_name
		extension, ## extension
		"", ## release date
		[], ## artists
		"", ## album
		"", ## youtube_id
		"", ## duration_string
	)
	Global.downloads_folder_changed.emit()


func add_to_current_playlist(id: String):
	print("Adding to current playlist: ", id)
	Global.current_playlist.content_ids.append(id)
	Global.current_playlist.reload_song_items()
	

func add_to_queue_end(id: String):
	print("Adding last to queue %s" % id)
	var new_content_ids: Array[String] = []
	for i in Global.current_playlist.content_ids.size():
		new_content_ids.append(Global.current_playlist.content_ids.get(i))
		if i == playing_song_index + Global.current_playlist.queue_size:
			new_content_ids.append(id)
			
	
	Global.current_playlist.content_ids = new_content_ids
	Global.current_playlist.queue_size += 1
	Global.current_playlist.reload_list()

func play_last_song_from_current_playlist() -> void: ## Plays the last song in the [member Global.current_playlist]
	if Global.current_playlist.content_ids.is_empty():
		push_error("Current playlist empty!")
		return
	
	var id: String = Global.current_playlist.content_ids[-1]
	play_from_id(id)


func clear_current_playlist(): ## clears the current_playlist
	Global.current_playlist.clear_items()
	Global.current_playlist.queue_size = 0
	playing_song_index = -1
	Global.music_player.clear_stream()

func update_infos(youtube_id: String, callback: Callable = Callable()) -> void:
	print("Updating infos for YouTube ID: %s" % youtube_id)
	if youtube_id == "":
		Global.logs_display.write("No YouTube ID provided.", LogsDisplay.MESSAGE.ERROR)
		return
	if not Global.downloaded_songs.has(youtube_id):
		push_error("Downloaded songs does not have YouTube ID: %s" % youtube_id)
		return
	var local_id: String = Global.downloaded_songs.get(youtube_id, "")
	var song_info: Dictionary = Global.song_infos.get(local_id, {})
	if song_info:
		var url: String = Tools.build_youtube_url(youtube_id)
		var infos: Dictionary = await DownloadsManager.get_video_infos_from_url(url)
		
		var release_date: String = infos.get("release_date", "") if infos.get("release_date", "") else ""
		if release_date == "":
			release_date = infos.get("upload_date", "") if infos.get("upload_date", "") else ""
		
		## from yt dlp: only get one artist
		var artist_name: String = infos.get("channel", "") if infos.get("channel", "") else ""
		var artist_id: String = infos.get("channel_id", "") if infos.get("channel_id", "") else ""
		
		Global.create_song_infos(
			local_id, ## local_id
			infos.get("title", "") if infos.get("title", "") else "", ## display_name
			song_info.get("extension", ""), ## extension
			release_date, ## release date
			[{"name": artist_name, "id": artist_id}], ## artists
			"", ## album
			youtube_id, ## youtube_id
			infos.get("duration_string", "") if infos.get("duration_string", "") else "",
		)
		
		if callback:
			callback.call()
	else:
		push_error("No song info found for ID: %s" % local_id)


func _on_stream_changed(fullpath: String): ## from the music player
	has_stream = Global.music_player.stream != null
	
	var local_id: String = Tools.fullpath_to_filename(fullpath)
	var song_info: Dictionary = Global.song_infos_get(local_id)
	if song_info:
		if not song_info.has("duration_string"):
			var duration: float = Global.music_player.stream.get_length()
			var duration_string: String = Tools.duration_to_string(duration)
			song_info.set("duration_string", duration_string)
			Global.save_song_infos()

func _on_song_finished():
	if playing_song_index < Global.current_playlist.content_ids.size():
		playing_song_index += 1
		play_from_index(playing_song_index)
	else:
		Global.music_player.clear_stream()
	

func _on_play():
	unpause_song()

func _on_pause():
	pause_song()

func _on_next_pressed() -> void:
	SongManager.play_next_song()

func _on_previous_pressed() -> void:
	SongManager.play_previous_song()

func _on_downloads_folder_changed() -> void:
	Global.logs_display.write("Downloads folder changed.")
	#update_downloaded_songs_from_song_infos()



#
