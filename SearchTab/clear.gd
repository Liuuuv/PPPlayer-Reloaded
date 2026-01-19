extends ButtonComponent

func _on_pressed() -> void:
	SongManager.clear_current_playlist()
	
