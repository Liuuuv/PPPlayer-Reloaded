extends ButtonComponent

func _pressed() -> void:
	#var html: String = await Global.insert_text_dialog.ask_for_text("Insert HTML body here.")
	#if html != "":
	
	var clipboard: String = DisplayServer.clipboard_get()
	#print("clipboard ", clipboard)
	
	var is_youtube_id: bool = false
	if clipboard.length() == 11:
		is_youtube_id = true
		for char: String in clipboard:
			if not char in Tools.youtube_id_alphabet:
				is_youtube_id = false
	
	
	var ids_found: PackedStringArray
	if is_youtube_id:
		ids_found = PackedStringArray([clipboard])
	else:
		ids_found = HtmlCleaner.extract_youtube_ids_from_html(clipboard)
	var confirm: bool = await Global.confirmation_dialog.ask_for_confirmation(
		"Are you sure to import from your clipboard? (HTML page) - (%s IDs)" % str(ids_found.size()),
		"IDs detected: " + ", ".join(ids_found)
	)
	if confirm and ids_found:
		#print("clipboard ", clipboard)
		Global.logs_display.write("IDs found: %s" % ids_found, LogsDisplay.MESSAGE.DEBUG)
		Global.downloads_tab.add_multiple_ids_to_queue(ids_found)
