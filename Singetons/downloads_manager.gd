extends Node



func _ready() -> void:
	YtDlp.setup()
	await YtDlp.setup_completed
	print("YTDLP Setup Completed")
	
	#download_video_from_url("https://www.youtube.com/watch?v=5nRC8ZpJpRg", "nelke_test")


func download_video_from_url(url: String, file_name: String, write_thumbnail: bool = false, get_infos: bool = false):
	if not YtDlp.is_setup():
		Global.logs_display.write("Waiting for YTDLP to be setup.", LogsDisplay.MESSAGE.INFO, true)
		await YtDlp.setup_completed
	
	var time = Time.get_ticks_msec()
	
	var download := YtDlp.download(url)
	download.set_destination(Global.get_downloads_path())
	download.set_file_name(file_name)
	if get_infos:
		download.gather_infos()
	if write_thumbnail:
		download.write_thumbnail()
	download.convert_to_audio(Config.audio_format)
	download.start()
	
	Global.logs_display.write("Starting the download.", LogsDisplay.MESSAGE.INFO, true)
	print("Starting the download.")
	var output: Array = await Tools.await_or_timeout(download.download_completed, Config.timeout_duration, [])
	Global.logs_display.write("Download finished in %s ms, file_name: %s" % [Time.get_ticks_msec() - time, file_name], LogsDisplay.MESSAGE.INFO, true)
	print("Download finished.")
	
	if output == []:
		Global.logs_display.write("Download was interrupted because of a timeout.", LogsDisplay.MESSAGE.WARNING)
		print("Download stopped because of a timeout")
		return {"interrupt": "timeout"}
	
	# if interrupted (error or hand interrupted)
	if output.size() >= 1:
		if output[0] == "interrupt":
			Global.logs_display.write("Download was interrupted.", LogsDisplay.MESSAGE.WARNING)
			return {"interrupt": "No information"}
	
	# success
	Global.downloads_folder_changed.emit.call_deferred()
	
	if get_infos:
		var infos: Dictionary
		if output.size() >= 1:
			var parsed: Variant = JSON.parse_string(_remove_prefix_messages(_clean_output(output[0])))
			if parsed is Dictionary:
				infos = parsed
			else:
				Global.logs_display.write("Parsed output is not a dictionnary. Parsed: %s" % parsed)
				push_error("Parsed output is not a dictionnary.")
		else:
			infos = {"output size was 0": 0}
		
		print("Download infos complete")
		Global.logs_display.write("Download infos complete")
		#Tools.write_json_file(infos, "res://test.json")
		return infos
	return {"success": 0} ## sucess


func download_thumbnail_from_url(url: String, file_name: String) -> Dictionary:
	if not YtDlp.is_setup():
		await YtDlp.setup_completed
	
	var time = Time.get_ticks_msec()
	
	var download: YtDlp.Download = YtDlp.download(url)
	download.set_destination(Global.get_downloads_path())
	download.set_file_name(file_name)
	
	download.write_thumbnail()
	download.no_download()
	download.start()

	#var output: Array = await download.download_completed
	var output: Array = await Tools.await_or_timeout(download.download_completed, Config.timeout_duration, [])
	
	Global.logs_display.write("Thumbnail download complete in %s ms, file_name: %s" % [Time.get_ticks_msec() - time, file_name], LogsDisplay.MESSAGE.INFO)
	print("Thumbnail download complete")
	
	# if interrupted (error or hand interrupted)
	if output.size() >= 1:
		if output[0] == "interrupt":
			Global.logs_display.write("Download was interrupted", LogsDisplay.MESSAGE.WARNING)
			return {"interrupt": 0}
	return {}
	


func get_video_infos_from_url(url: String) -> Dictionary:
	print("Getting song informations...")
	if not YtDlp.is_setup():
		print("get_video_infos_from_url > Waiting yt-dlp to be setup")
		await YtDlp.setup_completed
	
	var time = Time.get_ticks_msec()

	var download := YtDlp.download(url) \
		.gather_infos() \
		#.no_download() \
		#.set_get_progression_function(func (progression): print("progression ", progression)) \
		.start()

	#var output: Array = await download.download_completed
	var output: Array = await Tools.await_or_timeout(download.download_completed, Config.timeout_duration, [])
	var infos: Dictionary = {}
	if output.size() >= 1:
		var parsed: Variant = JSON.parse_string(_remove_prefix_messages(_clean_output(output[0])))
		if parsed is Dictionary:
			infos = parsed
		else:
			Global.logs_display.write("Parsed output is not a dictionnary. Parsed: %s" % parsed)
			push_error("Parsed output is not a dictionnary.")
	
	print("Download infos complete")
	print("time passed ", Time.get_ticks_msec() - time)
	#Tools.write_json_file(infos, "res://test.json")
	return infos

	#var stream = AudioStreamMP3.new()
	#var audio_file = FileAccess.open("user://audio/ok_computer.mp3", FileAccess.READ)
#
	#stream.data = audio_file.get_buffer(audio_file.get_length())
	#audio_file.close()
#
	#$AudioStreamPlayer.stream = stream
	#$AudioStreamPlayer.play()


func get_playlist_informations(url: String) -> Dictionary:
	if not url.contains("playlist?list="):
		Global.logs_display.write("URL does not contain 'playlist?list=' (%s)" % url, LogsDisplay.MESSAGE.ERROR, true)
		push_error("URL does not contain 'playlist?list=' (%s)" % url)
	if not YtDlp.is_setup():
		Global.logs_display.write("Waiting for YTDLP to be setup.", LogsDisplay.MESSAGE.INFO, true)
		await YtDlp.setup_completed
	
	var time = Time.get_ticks_msec()
	
	var download := YtDlp.download(url)
	download.set_is_playlist()
	download.start()
	
	Global.logs_display.write("Getting playlist informations.", LogsDisplay.MESSAGE.INFO, true)
	print("Getting playlist informations.")
	var output: Array = await Tools.await_or_timeout(download.download_completed, Config.timeout_duration, [])
	Global.logs_display.write("Got playlist informations in %s ms" % [Time.get_ticks_msec()], LogsDisplay.MESSAGE.INFO, true)
	print("Got playlist informations in %s ms" % [Time.get_ticks_msec()])
	
	if output == []:
		Global.logs_display.write("Playlist gathering was interrupted because of a timeout.", LogsDisplay.MESSAGE.WARNING)
		print("Playlist gathering stopped because of a timeout")
		return {"interrupt": "timeout"}
	
	if output[0] == "interrupt":
		Global.logs_display.write("Playlist gathering was interrupted.", LogsDisplay.MESSAGE.WARNING)
		print("Playlist gathering was interrupted.")
	
	# if interrupted (error or hand interrupted)
	if output.size() >= 1:
		if output[0] == "interrupt":
			Global.logs_display.write("Playlist gathering was interrupted.", LogsDisplay.MESSAGE.WARNING)
			return {"interrupt": "No information"}
	
	
	var infos: Dictionary
	if output.size() >= 1:
		infos = JSON.parse_string(_remove_prefix_messages(output[0])) as Dictionary
	else:
		infos = {"output size was 0": 0}
	
	print("Playlist gathering infos complete")
	Global.logs_display.write("Playlist gathering infos complete")
	return infos


func _clean_output(text: String) -> String:
	var prefix_less: String = _remove_prefix_messages(text)
	var parts: PackedStringArray = prefix_less.split("\n")
	if parts.size() > 1:
		var lines_preview: String
		for part in parts:
			lines_preview += part.substr(0, 100) + "...\n"
		print("Multiple lines: %s" % lines_preview)
		Global.logs_display.write("Multiple lines: %s" % lines_preview, LogsDisplay.MESSAGE.WARNING)
	return parts[0]

## Sometimes you get
## [codeblock]
## "WARNING: [youtube:tab] YouTube said: INFO - 2 unavailable videos are hidden\n{\"id\": \"PLd-zJRILbNSAsC-wiJFfLD384gxxOBg1i\",[br]
## \"title\": \"test\", \"availability\": \"unlisted\", \"channel_follower_count\": null, \"description\": \"\", \"tags\": ... }
## [/codeblock]
func _remove_prefix_messages(raw_output: String) -> String:
	print("RAW OUTPUT ", raw_output.substr(0, 150))
	var json_start = raw_output.find("{")
	
	if json_start == -1:
		push_error("The raw output does not contain any '{'.")
		return "{}"
	
	# Warning message
	var warning_message: String = raw_output.substr(0, json_start).strip_edges()
	print("ytdlp warning: %s" % warning_message)
	Global.logs_display.write("ytdlp warning: %s" % warning_message, LogsDisplay.MESSAGE.WARNING)
	
	var json_str = raw_output.substr(json_start).strip_edges()
	return json_str
