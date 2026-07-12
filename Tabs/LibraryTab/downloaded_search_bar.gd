extends LineEdit

func _ready() -> void:
	text_changed.connect(_on_text_changed)

func _on_text_changed(new_text: String):
	if new_text != "":
		var words: PackedStringArray = new_text.split(" ")
		var id_to_display: Array = []
		
		## ID SEARCH
		if new_text.begins_with("id:"):
			var search_id: String = new_text.substr(3).strip_edges()
			if search_id != "":
				for id: String in Global.all_displayed_names.values():
					if id.containsn(search_id):
						id_to_display.append(id)
		else:
			## BASIC SEARCH
			for word in words:
				for display_name: String in Global.all_displayed_names.keys():
					if display_name.containsn(word):
						id_to_display.append(Global.all_displayed_names.get(display_name))
		
		Global.downloaded_tab.reload_song_list(id_to_display)
	else:
		Global.downloaded_tab.reload_song_list()
