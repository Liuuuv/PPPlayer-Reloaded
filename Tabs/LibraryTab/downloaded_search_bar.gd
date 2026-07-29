extends LineEdit

func _ready() -> void:
	text_changed.connect(_on_text_changed)

func _on_text_changed(new_text: String):
	if new_text != "":
		var words: PackedStringArray = new_text.split(" ")
		var id_to_display: Array[String] = []
		
		var all_ids: Array[String] = []
		all_ids.assign(Global.song_infos.keys())
		
		## ID SEARCH
		if new_text.begins_with("id:"):
			var search_id: String = new_text.substr(3).strip_edges()
			if search_id != "":
				for id: String in Global.all_displayed_names.keys():
					if id.containsn(search_id):
						id_to_display.append(id)
		elif new_text.begins_with("art:"):
			var search_artist: String = new_text.trim_prefix("art:").strip_edges()
			if search_artist != "":
				
				var search_artist_words: PackedStringArray = search_artist.split(" ")
				for word: String in search_artist_words:
					var matching_ids: Array[String] = []
					for id: String in all_ids:
						var song_info: Dictionary = Global.song_infos.get(id, {})
						
						## new way
						if song_info.has("artists"):
							var artists: Array = song_info.get("artists")
							for artist: Dictionary in artists:
								if artist.get("name", "").containsn(word):
									matching_ids.append(id)
									break
						
						## old way
						if song_info.get("artist", "").containsn(word):
							matching_ids.append(id)
						
					all_ids = matching_ids
				id_to_display = all_ids
		else:
			## BASIC SEARCH
			#var all_ids: Array[String] = []
			#all_ids.assign(Global.all_displayed_names.keys())
			for word in words:
				if word == "":
					continue
				
				var matching_ids: Array[String] = []
				for id: String in all_ids:
					var display_name: String = Global.all_displayed_names.get(id, "")
					if display_name.containsn(word):
						matching_ids.append(id)
				
				all_ids = matching_ids
			
			id_to_display = all_ids
		
		Global.downloaded_tab.reload_song_list(id_to_display)
	else:
		Global.downloaded_tab.reload_song_list()
