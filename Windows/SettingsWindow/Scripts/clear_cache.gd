extends ButtonComponent

func _pressed() -> void:
	Global.logs_display.write("Deleting cache...", LogsDisplay.MESSAGE.DEBUG)
	var full_path: String = Global.get_downloads_path() + Global.CACHE_DIR_NAME
	if DirAccess.dir_exists_absolute(full_path):
		
		var error: Error = DirAccess.remove_absolute(full_path)
		if error != OK:
			Global.logs_display.write("Error when deleting cache: %s" % error, LogsDisplay.MESSAGE.ERROR)
		else:
			Global.logs_display.write("Cache deleted successfully", LogsDisplay.MESSAGE.INFO)
	else:
		Global.logs_display.write("Cache didn't exist", LogsDisplay.MESSAGE.INFO)
