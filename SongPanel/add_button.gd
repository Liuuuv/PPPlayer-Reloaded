extends ButtonComponent



func _pressed() -> void:
	var song_path: String = await Global.select_song_dialog.ask_for_song()
	if song_path != "":
		SongManager.add_song_from_file(song_path)
