extends AudioStreamPlayer2D
class_name MusicPlayer

signal stream_changed()
signal playing_changed()

@onready var progress_slider: HSlider = %ProgressSlider
@onready var time_label: Label = %TimeLabel



func _ready() -> void:
	Global.music_player = self


func start_song(full_path: String):
	stream = Tools.get_song_stream(full_path)
	stream_changed.emit()
	
	#if not Global.song_streams.has(id):
		#return
	#stream = Global.song_streams[id]
	play(0.0)
	playing_changed.emit()

func pause_song() -> void:
	stream_paused = true
	playing_changed.emit()

func unpause_song() -> void:
	stream_paused = false
	if not stream:
		SongManager.play_from_index(SongManager.playing_song_index)
	playing_changed.emit()

func clear_stream():
	stop()
	playing_changed.emit()
	stream = null
	stream_changed.emit()

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
