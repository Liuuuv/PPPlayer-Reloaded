extends ButtonComponent

func _pressed() -> void:
	print("Scanning downloaded songs (from song_infos.json)...")
	var downloaded_songs: Dictionary = {}
	for id in Global.song_infos:
		var song_info: Dictionary = Global.song_infos.get(id, {})
		if song_info.has("video_id"):
			downloaded_songs.set(song_info.get("video_id"), 0)
	print("Stored downloaded_songs (%s entries): " % Global.downloaded_songs.size(), Global.downloaded_songs)
	print("Scanned downloaded_songs (%s entries): " % downloaded_songs.size(), downloaded_songs)
	Global.downloaded_songs = downloaded_songs
	Global.save_downloaded_songs()
