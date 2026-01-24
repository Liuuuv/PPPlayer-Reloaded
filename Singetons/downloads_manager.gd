extends Node



func _ready() -> void:
	YtDlp.setup()
	await YtDlp.setup_completed
	print("YTDLP Setup Completed")
	
	#download_video_from_url("https://www.youtube.com/watch?v=5nRC8ZpJpRg", "nelke_test")

## TODO ERROR HANDLER
func download_video_from_url(url: String, file_name: String, write_thumbnail: bool = false, get_infos: bool = false):
	if not YtDlp.is_setup():
		await YtDlp.setup_completed
	
	var time = Time.get_ticks_msec()
	
	var download := YtDlp.download(url)
	download.set_destination(Global.get_downloads_path())
	download.set_file_name(file_name)
	if get_infos:
		download.gather_infos()
	if write_thumbnail:
		download.write_thumbnail()
	download.convert_to_audio(YtDlp.Audio.MP3)
	download.start()

	var output: Array = await download.download_completed
	Global.logs_display.write("Download complete in %s ms, file_name: %s" % [Time.get_ticks_msec() - time, file_name])
	print("Download complete")
	
	if get_infos:
		var infos: Dictionary
		if output.size() >= 1:
			if output[0] == "interrupt":
				Global.logs_display.write("Download was interrupted", LogsDisplay.MESSAGE.WARNING)
				return {"interrupt": 0}
			infos = JSON.parse_string(output[0])
		else:
			infos = {"output size was 0": 0}
		
		print("Download infos complete")
		Global.logs_display.write("Download infos complete")
		#Tools.write_json_file(infos, "res://test.json")
		return infos


func get_video_infos_from_url(url: String) -> Dictionary:
	if not YtDlp.is_setup():
		await YtDlp.setup_completed

	var time = Time.get_ticks_msec()

	var download := YtDlp.download(url) \
		.gather_infos() \
		#.no_download() \
		#.set_get_progression_function(func (progression): print("progression ", progression)) \
		.start()

	var output: Array = await download.download_completed
	var infos: Dictionary = {}
	if output.size() >= 1:
		infos = JSON.parse_string(output[0])
	
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
