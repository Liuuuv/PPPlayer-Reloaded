extends ButtonComponent

func _on_pressed() -> void:
	Global.current_playlist.reload_song_items()
