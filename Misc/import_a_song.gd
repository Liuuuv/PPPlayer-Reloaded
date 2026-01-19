extends ButtonComponent

func _pressed() -> void:
	var text: String = await Global.insert_text_dialog.ask_for_text("Past a Youtube URL here")
	var id: String = HtmlCleaner.get_video_id(text)
	var url: String = Tools.build_youtube_url(id)
	DownloadsManager.download_video_from_url(url, "feur")
	
