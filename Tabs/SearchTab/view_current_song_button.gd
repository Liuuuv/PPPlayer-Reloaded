extends ButtonComponent



func _on_pressed() -> void:
	Global.current_playlist.scroll_to_index(SongManager.playing_song_index)








#
