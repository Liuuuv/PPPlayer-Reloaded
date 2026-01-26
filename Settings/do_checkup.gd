extends ButtonComponent

var summary: Dictionary = {}

var already_downloaded_video_ids = {}

func _pressed() -> void:
	summary = {}
	already_downloaded_video_ids = {}
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
					
					process_from_folder(id)

			file_name = dir.get_next()
	
	Tools.write_json_file(summary, "res://summary.json")
	Global.summary_window.display_data(summary)
	print("already_downloaded_video_ids ", already_downloaded_video_ids)

func process_from_folder(id: String):
	print("processing %s" % id)
	var info: Dictionary = {}
	var song_info: Dictionary = Global.song_infos.get(id)
	if song_info:
		info.set("has_song_info", true)
	else:
		info.set("has_song_info", false)
	info.set("has_artist", true if song_info.get("artist", "") != "" else false)
	#info.set("has_artist", false)
	info.set("has_display_name", true if song_info.get("display_name", "") != "" else false)
	info.set("has_extension", true if song_info.get("extension", "") != "" else false)
	info.set("has_release_date", true if song_info.get("release_date", "") != "" else false)
	info.set("has_thumbnail_path", true if song_info.get("thumbnail_path", "") != "" else false)
	var video_id = song_info.get("video_id", "")
	info.set("has_video_id", true if video_id != "" else false)
	
	if video_id != "":
		info.set("is_duplicate_video_id", video_id in already_downloaded_video_ids) ## if two are the same, only flag the second one. CHANGE DOWNLOADED_SONGS video_id : id TO STORE AND FIX
		if not already_downloaded_video_ids.has(video_id):
			already_downloaded_video_ids.set(video_id, 0)
	else:
		info.set("is_duplicate_video_id", false)
	
	if summary.has(id):
		Global.logs_display.write("ID: %s 's song file is is duplicated. Ignoring this one as it has already been treated" % id, LogsDisplay.MESSAGE.ERROR)
	summary.set(id, info)
	print("process finished")
