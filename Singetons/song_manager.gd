extends Node

signal song_paused()
signal song_unpaused()
signal has_stream_changed()

var is_song_paused: bool = true
var has_stream: bool = false:
	set(on):
		if has_stream != on:
			has_stream = on
			has_stream_changed.emit()
var playing_song_index: int = 0

func _ready() -> void:
	initialize.call_deferred()

func initialize():
	Global.music_player.stream_changed.connect(_on_stream_changed)
	Global.music_player.finished.connect(_on_song_finished)
	
	has_stream_changed.emit()

func start_song(full_path: String):
	print("starting song : ", full_path)
	Global.music_player.start_song(full_path)
	
	var id: String = full_path.get_file().get_basename()
	var song_infos = Global.song_infos.get(id)
	if song_infos:
		Global.song_panel.song_label.text = song_infos.get("name", "[i]Untitled[/i]")

func pause_song() -> void:
	print("pausing song")
	Global.music_player.pause_song()
	song_paused.emit()

func unpause_song():
	print("unpausing song")
	Global.music_player.unpause_song()
	song_unpaused.emit()

func change_song_progression(progression: float): ## 0-100
	if Global.music_player.stream:
		var target_time: float = Global.music_player.stream.get_length() * progression / 100
		Global.music_player.seek(target_time)

func play_from_index(index: int) -> void:
	if index < 0 or index >= Global.current_playlist.content_ids.size():
		push_error("index out of range of current playlist size")
		return
		
	var id: String = Global.current_playlist.content_ids[index]
	var song_info = Global.song_infos.get(id)
	if song_info:
		var extension = song_info.get("extension")
		if extension:
			var full_path = Global.get_downloads_path() + id + "." + extension
			start_song(full_path)
		else:
			push_error("no extension available for index ", index)
			return
	else:
		push_error("no song info available for index ", index)
		return

func add_song_from_file(path: String):
	print("adding song from file.. : ", path)
	var id: String = Global.generate_new_id() ## new filename
	Tools.duplicate_file(path, Global.get_downloads_path(), id)
	var extension: String = path.get_extension()
	var song_name: String = path.get_file().get_basename()
	
	var infos = {"title": song_name}
	Global.create_song_infos(id, infos, extension)
	Global.downloads_folder_changed.emit()


func add_to_current_playlist(id: String):
	print("adding to current playlist: ", id)
	Global.current_playlist.content_ids.append(id)
	Global.current_playlist.reload_song_items()

func clear_current_playlist():
	Global.current_playlist.clear_song_items()
	playing_song_index = 0
	Global.music_player.clear_stream()


func _on_stream_changed(): ## from the music player
	has_stream = Global.music_player.stream != null

func _on_song_finished():
	if playing_song_index < Global.current_playlist.content_ids.size():
		playing_song_index += 1
		play_from_index(playing_song_index)
	else:
		Global.music_player.clear_stream()
	
	
