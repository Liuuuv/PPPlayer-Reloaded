extends ButtonComponent

func _pressed() -> void:
	var text: String = await Global.insert_text_dialog.ask_for_text("Past a Youtube URL here")
	if text != "":
		var video_id: String = HtmlCleaner.get_video_id(text)
		if Tools.is_youtube_id(video_id):
			Global.songs_download.add_id_to_queue(video_id)
		#var url: String = Tools.build_youtube_url(id)
		#var infos: Dictionary = await DownloadsManager.download_video_from_url(url, "feur", true, true)
		#print(infos)
