extends ButtonComponent



func _pressed() -> void:
	SongManager.play_next_song()
