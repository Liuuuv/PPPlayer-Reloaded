extends ButtonComponent

func _ready() -> void:
	super._ready()
	
	Global.music_player.stream_changed.connect(_on_stream_changed)

func _on_pressed() -> void:
	pass

func _on_stream_changed(_fullpath: String):
	if button_pressed:
		Global.current_playlist.scroll_to_index(SongManager.playing_song_index)







#
