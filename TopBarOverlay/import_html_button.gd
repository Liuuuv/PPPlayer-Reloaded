extends ButtonComponent


func _pressed() -> void:
	#var html: String = await Global.insert_text_dialog.ask_for_text("Insert HTML body here.")
	#if html != "":
	
	var clipboard: String = DisplayServer.clipboard_get()
	_process_text(clipboard)
	
func _process_text(text: String):
	#print("clipboard ", clipboard)
	#var ids_found: PackedStringArray = 
	print("Processing text...")
	is_loading = true
	YoutubeIdFinder.find_ids(
		text,
		_on_ids_found
	)
	#_on_ids_found(ids_found)

func _on_ids_found(result: Dictionary):
	is_loading = false
	var ids_found: PackedStringArray = result.get("ids", PackedStringArray([]))
	var type_str: String
	var text_type: YoutubeIdFinder.TEXT_TYPES = result.get("type", YoutubeIdFinder.TEXT_TYPES.NOT_FOUND)
	match text_type:
		YoutubeIdFinder.TEXT_TYPES.NOT_FOUND: type_str = "Not found"
		YoutubeIdFinder.TEXT_TYPES.YOUTUBE_ID: type_str = "YouTube ID"
		YoutubeIdFinder.TEXT_TYPES.PLAYLIST: type_str = "YouTube playlist"
		YoutubeIdFinder.TEXT_TYPES.HTML: type_str = "HTML"
	
	var confirm: bool = await Global.confirmation_dialog.ask_for_confirmation(
		"(Type: %s) Are you sure to import from your clipboard? - (%s IDs)" % [type_str, str(ids_found.size())],
		"IDs detected: " + ", ".join(ids_found)
	)
	if confirm and ids_found:
		if text_type == YoutubeIdFinder.TEXT_TYPES.PLAYLIST:
			var proposed_playlist_name: String = result.get("playlist_name", "")
			if proposed_playlist_name and Global.playlists_tab.is_name_available(proposed_playlist_name):
				confirm = await Global.confirmation_dialog.ask_for_confirmation(
					"Create playlist?",
					"Create a playlist with the name '%s'?" % proposed_playlist_name
				)
				if confirm:
					Global.playlists_tab.create_playlist(proposed_playlist_name, false)
					Global.playlists_tab.add_multiple_youtube_ids_to_playlist(ids_found, proposed_playlist_name)
		#print("clipboard ", clipboard)
		Global.logs_display.write("IDs found: %s" % ids_found, LogsDisplay.MESSAGE.DEBUG)
		Global.downloads_tab.add_multiple_ids_to_queue(ids_found)
