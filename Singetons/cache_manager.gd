extends Node

var _thumbnail_cache: Dictionary = {}
var _result_thumbnail_cache: Dictionary = {} ## {youtube_id: Resource}

func get_cache_path() -> String:
	return Global.get_downloads_path() + Global.CACHE_DIR_NAME + "/"
	
func get_results_cache_path() -> String:
	return get_cache_path() + Global.RESULTS_CACHE_DIR_NAME + "/"

func get_cached_thumbnail(id: String) -> Texture2D:
	# check if already in memory cache
	if id in _thumbnail_cache:
		var cached_texture: Texture2D = _thumbnail_cache[id]
		# Vérifier que la texture n'est pas null et est valide
		if cached_texture != null and cached_texture.get_width() > 0:
			return cached_texture
	
	# check if cache folder exists
	var path_to_cach_dir: String = Global.get_downloads_path() + Global.CACHE_DIR_NAME + "/"
	if not DirAccess.dir_exists_absolute(path_to_cach_dir):
		var dir = DirAccess.open(Global.get_downloads_path())
		if dir:
			var error = dir.make_dir(Global.CACHE_DIR_NAME)
			if error != OK:
				push_warning("Unable to create cache folder: %s" % error)
	
	# loads the .res file if it exists
	var full_path: String = path_to_cach_dir + id + ".res"
	if ResourceLoader.exists(full_path):
		var texture: Texture2D = ResourceLoader.load(full_path)
		if texture != null:
			_thumbnail_cache[id] = texture
			return texture
	
	# .res does not exists and the id is not in the memory cache, so create the .res and save into the memory cache
	var thumbnail: Texture2D = Tools.get_thumbnail(id)
	if thumbnail != null:
		_thumbnail_cache[id] = thumbnail
		_save_to_cache.call_deferred(thumbnail, full_path)
	
	return thumbnail

## Eg: returns the associated resource
## [br]
## [param cache_name] should NOT end with '.res'.
func get_cached_results(cache_name: String) -> Resource:
	if cache_name.ends_with(".res"):
		push_error("cache_name must not finish with '.res'.")
		cache_name = cache_name.get_basename()
	
	
	# already in memory cache?
	if cache_name in _result_thumbnail_cache:
		var cached_content: Variant = _result_thumbnail_cache[cache_name]
		# Vérifier que la texture n'est pas null et est valide
		if cached_content is Texture2D:
			if cached_content != null and cached_content.get_width() > 0:
				return cached_content
		else:
			if cached_content:
				return cached_content
	
	# check if cache folder exists
	var path_to_cach_dir: String = Global.get_downloads_path() + Global.CACHE_DIR_NAME + "/"
	if not DirAccess.dir_exists_absolute(path_to_cach_dir):
		var dir = DirAccess.open(Global.get_downloads_path())
		if dir:
			var error = dir.make_dir(Global.CACHE_DIR_NAME)
			if error != OK:
				push_warning("Unable to create cache folder: %s" % error)
	
	# check if results cache folder exists
	var path_to_results_cach_dir: String = path_to_cach_dir + Global.RESULTS_CACHE_DIR_NAME + "/"
	if not DirAccess.dir_exists_absolute(path_to_results_cach_dir):
		var dir = DirAccess.open(path_to_cach_dir)
		if dir:
			var error = dir.make_dir(Global.RESULTS_CACHE_DIR_NAME)
			if error != OK:
				push_warning("Unable to create results cache folder: %s" % error)
	
	var full_path: String = path_to_results_cach_dir + cache_name + ".res"
	
	
	# loads the .res file if it exists
	if ResourceLoader.exists(full_path):
		var cached_content: Resource = ResourceLoader.load(full_path)
		if cached_content != null:
			_result_thumbnail_cache[cache_name] = cached_content
			return cached_content
	
	return null

## Supported:[br]
## [codeblock]
## {
## "category": "Songs", 
## "resultType": "song", 
## 			"title": "\u30ab\u30ef\u30ad\u30f2\u30a2\u30e1\u30af - Kawakiwoameku", 
## "album": {"name": "Kawakiwoameku", "id": "MPREb_r28EAcrLnXE"}, 
## "inLibrary": false, 
## "pinnedToListenAgain": false,
## 			"videoId": "gxp3R7l1iSk", 
## "videoType": "MUSIC_VIDEO_TYPE_ATV", 
## "duration": "4:12", 
## "year": null, 
## 			"artists": [
## 				{"name": "minami", "id": "UCEsOqBVe_DNEUAer9TYk6bw"}
## 			], 
## "duration_seconds": 252, 
## "views": "327M", 
## "isExplicit": false, 
## "thumbnails": [{"url": "https://yt3.googleusercontent.com/Gx74Mec9Pf3tVrtSI0siKdF6964s4Q1JEjsBLkcFaALQug_mc6Y96-scL17Sev66rBe43nH0pnRgjV_v=w60-h60-l90-rj", "width": 60, "height": 60}, {"url": "https://yt3.googleusercontent.com/Gx74Mec9Pf3tVrtSI0siKdF6964s4Q1JEjsBLkcFaALQug_mc6Y96-scL17Sev66rBe43nH0pnRgjV_v=w120-h120-l90-rj", "width": 120, "height": 120}]
## }
## [/codeblock]
func save_youtube_video_infos_to_cache(track_infos: Dictionary) -> String:
	var song_id: String = track_infos.get("videoId", "")
	if not song_id:
		push_error("A YouTube videoId is missing, skipping this song.")
		return ""
	var song_cache_name: String = Global.RESULTS_CACHE_SONG_TEMPLATE % song_id
	
	var song_cache_res: SongCacheResource = SongCacheResource.create(
		song_id,
		track_infos.get("title", ""),
		track_infos.get("artists", "")
	)
	_save_to_cache(song_cache_res, get_results_cache_path() + Global.RESULTS_CACHE_SONG_TEMPLATE % song_id + ".res")
	
	var song_thumbnails: Array = track_infos.get("thumbnails", [])
	if song_thumbnails != []:
		Tools.download_biggest_thumbnail(
			song_thumbnails,
			func(song_thumbnail: Texture2D):
				_save_to_cache.call_deferred(song_thumbnail, get_results_cache_path() + Global.RESULTS_CACHE_SONG_THUMBNAIL_TEMPLATE % song_id + ".res")
		)
	return song_id

func _save_to_cache(content: Resource, fullpath: String) -> void:
	var error: Error = ResourceSaver.save(content, fullpath)
	if error != OK:
		print("Erreur lors de la sauvegarde du cache: ", error)
