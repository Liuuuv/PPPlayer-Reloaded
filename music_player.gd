extends AudioStreamPlayer2D
class_name MusicPlayer

signal stream_changed(full_path: String)
signal playing_changed()

var progress_slider: HSlider
var time_label: Label

var current_stream_id: String = ""

func _ready() -> void:
	Global.music_player = self
	_initialize.call_deferred()

func _initialize() -> void:
	time_label = Global.song_panel.time_label
	progress_slider = Global.song_panel.progress_slider


func start_song(full_path: String):
	stream = Tools.get_song_stream(full_path)
	
	
	## Windows overlay
	WindowsOverlay.ShowOverlay()
	var id: String = full_path.get_file().get_basename()
	var thumbnail_path: String = Global.get_thumbnail_path(id)
	var song_info: Dictionary = Global.song_infos.get(id)
	if song_info:
		WindowsOverlay.SetMetadata(song_info.get('display_name', "no display_name provided"), song_info.get('artist', "no artist provided"), thumbnail_path)
	
	current_stream_id = id
	
	#if not Global.song_streams.has(id):
		#return
	#stream = Global.song_streams[id]
	play(0.0)
	stream_changed.emit(full_path)
	playing_changed.emit()

func pause_song() -> void:
	stream_paused = true
	
	WindowsOverlay.SetPlaybackStatus(false) # pause
	playing_changed.emit()

func unpause_song() -> void:
	WindowsOverlay.SetPlaybackStatus(true) # play
	stream_paused = false
	if not stream:
		SongManager.play_from_index(SongManager.playing_song_index)
	playing_changed.emit()

func clear_stream():
	stop()
	playing_changed.emit()
	stream = null
	current_stream_id = ""
	stream_changed.emit("")
	WindowsOverlay.HideOverlay()

func _physics_process(delta: float) -> void:
	if playing:
		var current_time = get_playback_position()
		var total_time = stream.get_length()
		
			
		var progress = (current_time / total_time) * 100 if total_time > 0 else 0
		Global.song_panel.progress_slider_bg.value = progress
		if not Global.song_panel.progress_slider.is_dragging:
			Global.song_panel.progress_slider.value = progress
		
		# Format mm:ss
		var current_min = int(current_time) / 60
		var current_sec = int(current_time) % 60
		var total_min = int(total_time) / 60
		var total_sec = int(total_time) % 60
		time_label.text = "%02d:%02d / %02d:%02d" % [current_min, current_sec, total_min, total_sec]
	
	var volume_multiplier: float = 1.2
	var main_volume_linear = (Global.song_panel.main_volume / 100.0) * volume_multiplier
	var volume_offset_linear = (Global.song_panel.volume_offset / 100.0)
	volume_linear = main_volume_linear * (1.0 + volume_offset_linear)







#
