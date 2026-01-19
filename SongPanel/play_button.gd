extends TextureButtonComponent

func _ready() -> void:
	super._ready()
	
	SongManager.has_stream_changed.connect(_on_has_stream_changed)
	Global.music_player.playing_changed.connect(_on_playing_changed)

func _on_toggled(on: bool) -> void:
	if on:
		SongManager.unpause_song()
	else:
		SongManager.pause_song()
	#Global.add_to_current_playlist(Global.song_streams.keys()["a"])

func _on_has_stream_changed():
	if not SongManager.has_stream:
		disabled = true
		#button_pressed = false
	else:
		disabled = false
		#if Global.music_player.playing:
			#button_pressed = true
		#else:
			#button_pressed = false

func _on_playing_changed():
	if Global.music_player.playing:
		button_pressed = true
	else:
		button_pressed = false
