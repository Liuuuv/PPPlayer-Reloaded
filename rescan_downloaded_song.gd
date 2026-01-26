extends ButtonComponent

func _pressed() -> void:
	update_downloaded_songs_from_song_infos()
	update_song_infos_from_folder()
	

func update_downloaded_songs_from_song_infos():
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

func update_song_infos_from_folder(): ## creates song infos if necessary
	var dir = DirAccess.open(Global.get_downloads_path())
	var id: String = ""
	var time = Time.get_ticks_msec()
	print('start ', time)
	var num: int = 0
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			#if num > 5:
				#break
			id = file_name.get_basename()
			if not Tools.is_id(id) or not Global.song_infos.has(id):
				file_name = dir.get_next()
				continue
			if not dir.current_is_dir():
				var extension = file_name.get_extension()
				if extension in ["mp3", "ogg", "wav"]:
					#var full_path = Global.get_downloads_path() + file_name
					#print("reload_song_list > fullpath ", full_path)
					
					if not Global.song_infos.has(id):
						Global.create_song_infos(id, {}, extension)
						Global.logs_display.write("Missing (ID:) %s in song infos" % id)

			file_name = dir.get_next()
