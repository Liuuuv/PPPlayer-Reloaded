extends ButtonComponent

func _pressed() -> void:
	#var html: String = await Global.insert_text_dialog.ask_for_text("Insert HTML body here.")
	#if html != "":
	
	var clipboard: String = DisplayServer.clipboard_get()
	#print("clipboard ", clipboard)
	var ids_found: PackedStringArray = HtmlCleaner.extract_youtube_ids_from_html(clipboard)
	var confirm: bool = await Global.confirmation_dialog.ask_for_confirmation(
		"Are you sure to import from your clipboard? (HTML page) - (%s IDs)" % str(ids_found.size()),
		"IDs detected: " + ", ".join(ids_found)
	)
	if confirm:
		#print("clipboard ", clipboard)
		Global.logs_display.write("IDs found: %s" % ids_found, LogsDisplay.MESSAGE.DEBUG)
		Global.downloads_tab.add_multiple_ids_to_queue(ids_found)
