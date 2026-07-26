extends Node

enum TEXT_TYPES {
	NOT_FOUND,
	YOUTUBE_ID,
	PLAYLIST,
	HTML,
}

enum API_CHOICES {
	YT_DLP,
	YTMUSIC,
}

var api_choice: API_CHOICES = API_CHOICES.YT_DLP

## (ASYNC FUNCTION) (because of playlists)[br]
## Calls the callback with a Dictionnary, for example:[br]
## [codeblock]
## {
## 		"type": TEXT_TYPES.PLAYLIST,
## 		"ids": PackedStringArray,
## 		"playlist_name": String ## ONLY if it is a playlist.
## }
## [/codeblock]
func find_ids(text: String, callback: Callable):
	print("Finding ids")
	
	var text_type: TEXT_TYPES = TEXT_TYPES.NOT_FOUND
	
	## search text type
	var is_youtube_id: bool = false
	if text.length() == 11:
		is_youtube_id = true
		for char: String in text:
			if not char in Tools.youtube_id_alphabet:
				is_youtube_id = false
	if is_youtube_id:
		text_type = TEXT_TYPES.YOUTUBE_ID
	
	var is_playlist: bool = false
	var playlist_id: String
	if text.contains("playlist?list="):
		playlist_id = text.get_slice("playlist?list=", 1)
		# Si l'URL contient d'autres paramètres après l'ID
		playlist_id = playlist_id.get_slice("&", 0)
		is_playlist = true
	if is_playlist:
		text_type = TEXT_TYPES.PLAYLIST
	
	if text_type == TEXT_TYPES.NOT_FOUND: ## default
		text_type = TEXT_TYPES.HTML
	##
	
	var ids_found: PackedStringArray
	match text_type:
		TEXT_TYPES.YOUTUBE_ID:
			ids_found = PackedStringArray([text])
		TEXT_TYPES.PLAYLIST: ## threaded part
			match api_choice:
				API_CHOICES.YTMUSIC:
					get_playlist_infos_ytmusic(
						playlist_id,
						func(data: Dictionary): ## data has way more infos than necessary
							callback.call({
								"type": text_type,
								"ids": data.get("tracks", []).map(func(dict: Dictionary): return dict.get("videoId", "")).filter(func(id): return id is String and not id.is_empty()),
								"playlist_name": data.get("title", "NO NAME FOUND"),
							}),
						UsePython.REQUEST_PRIORITY.HIGH
					)
					return
				API_CHOICES.YT_DLP:
					get_playlist_infos_yt(
						playlist_id,
						func(data: Dictionary): ## data has way more infos than necessary
							callback.call({
								"type": text_type,
								"ids": data.get("entries", []).map(func(dict: Dictionary): return dict.get("id", "")).filter(func(id): return id is String and not id.is_empty()),
								"playlist_name": data.get("title", "NO NAME FOUND"),
							}),
					)
					return
		TEXT_TYPES.HTML:
			ids_found = HtmlCleaner.extract_youtube_ids_from_html(text)
	
	callback.call({
		"type": text_type,
		"ids": ids_found
	})


## To try this one by yourself:[br]
## [codeblock]yt-dlp -J --flat-playlist "URL_PLAYLIST"[/codeblock]
func get_playlist_infos_yt(playlist_id: String, callback: Callable) -> void:
	print("Gathering playlist informations (yt-dlp)...")
	var infos: Dictionary = await DownloadsManager.get_playlist_informations(Tools.build_playlist_url(playlist_id))
	callback.call(infos)


func get_playlist_infos_ytmusic(playlist_id: String, callback: Callable, priority: UsePython.REQUEST_PRIORITY = UsePython.REQUEST_PRIORITY.MED) -> void:
	print("Gathering playlist informations... (ytmusicapi)")
	var script_path: String = Tools.get_python_script_fullpath("ytmusic_get_playlist_infos")
	UsePython.execute_python_script(
		[
			script_path,
			playlist_id,
		],
		func(dict: Dictionary): _process_playlist_infos(dict, callback),
		UsePython.REQUEST_PRIORITY.HIGH
	)

func _process_playlist_infos(data: Dictionary, callback: Callable) -> void:
	if data.get("success", false):
		var infos: Dictionary = data.get("result", {})
		callback.call(infos)
		
		## save to cache
		var new_info: Dictionary = {}
		new_info.set("videoId", infos.get("id"))
		new_info.set("title", infos.get("title"))
		new_info.set("artists", infos.get("artists"))
		CacheManager.save_youtube_video_infos_to_cache(new_info)
	else:
		callback.call({})
		push_error("Error in the Python execution: %s" % data.get("error", "No 'error' output."))
		Global.logs_display.write("Error in the Python execution: %s" % data.get("error", "No 'error' output."))







#
