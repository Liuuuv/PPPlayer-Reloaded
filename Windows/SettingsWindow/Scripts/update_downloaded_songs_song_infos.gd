extends ButtonComponent

func _pressed() -> void:
	SongManager.update_downloaded_songs_from_song_infos()
