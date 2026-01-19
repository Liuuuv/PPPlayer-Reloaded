extends Node2D

#func _ready() -> void:
	#YtDlp.setup()
	#await YtDlp.setup_completed
	#print("YTDLP Setup Completed")
	#
	##download_video_from_url("https://www.youtube.com/watch?v=5nRC8ZpJpRg", "nelke_test")
	#
#func download_video_from_url(url: String, file_name: String):
	#if not YtDlp.is_setup():
		#await YtDlp.setup_completed
	#
#
	#var download := YtDlp.download(url) \
		##.set_destination("user://audio/") \
		#.set_destination(Global.get_downloads_path()) \
		#.set_file_name(file_name) \
		#.convert_to_audio(YtDlp.Audio.MP3) \
		#.start()
#
	#await download.download_completed
	#print("Download complete")
#
	##var stream = AudioStreamMP3.new()
	##var audio_file = FileAccess.open("user://audio/ok_computer.mp3", FileAccess.READ)
##
	##stream.data = audio_file.get_buffer(audio_file.get_length())
	##audio_file.close()
##
	##$AudioStreamPlayer.stream = stream
	##$AudioStreamPlayer.play()
