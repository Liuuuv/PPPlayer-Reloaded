extends Node

# Ajoutez cette variable en haut de votre script (au niveau de la classe)
var _thumbnail_cache: Dictionary = {}
var _result_thumbnail_cache: Dictionary = {} ## {template: content}

#var alphabet: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" ## eg Pe and pe are considered the same
var alphabet: String = "abcdefghijklmnopqrstuvwxyz0123456789"
var alphabet_length: int = alphabet.length()
var alphabet_int_map: Dictionary = {} ## char: int
var alphabet_base: int = alphabet_length - 1

var youtube_id_alphabet: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"

func _ready() -> void:
	initialize_alphabet_int_map()

func initialize_alphabet_int_map():
	for i in range(alphabet_length):
		alphabet_int_map[alphabet[i]] = i

func write_json_file(data: Dictionary, full_file_path: String):
	var file = FileAccess.open(full_file_path, FileAccess.ModeFlags.WRITE_READ)
	
	if file:
		var json_text = JSON.stringify(data, "\t")
		
		file.store_string(json_text)
		file.close()


func load_json_file(full_file_path: String) -> Dictionary:
	var file = FileAccess.open(full_file_path, FileAccess.READ)
	
	if file == null:
		#push_error("load_json_file, file is null")
		return {}
	#assert (file.file_exists(full_file_path), "load_json_file, file doesn't exist")
	
	var json = JSON.new()
	
	var error = json.parse(file.get_as_text())
	if error == OK:
		return json.data
	else:
		#print("JSON Parse Error: ", json.get_error_message())
		Global.logs_display.write("JSON Parse Error: " + json.get_error_message(), LogsDisplay.MESSAGE.ERROR)
		return {}


func save_string(string: String, full_file_path: String) -> void:
	var file = FileAccess.open(full_file_path, FileAccess.ModeFlags.WRITE_READ)
	
	if file:
		
		var json_text = JSON.stringify(string, "\t")
		
		file.store_string(json_text)
		file.close()
	else:
		push_error("Can't open file %s" % full_file_path)


func load_string(full_file_path: String) -> String:
	var file = FileAccess.open(full_file_path, FileAccess.READ)
	
	if file == null:
		#push_error("load_json_file, file is null")
		return ""
	#assert (file.file_exists(full_file_path), "load_json_file, file doesn't exist")
	
	var json = JSON.new()
	
	var error = json.parse(file.get_as_text())
	if error == OK:
		return json.data
	else:
		print("JSON Parse Error: ", json.get_error_message())
		return ""


func save_array_json(array: Array, full_file_path: String) -> void:
	var file = FileAccess.open(full_file_path, FileAccess.ModeFlags.WRITE)
	
	if file:
		var json_text = JSON.stringify(array, "\t")
		
		file.store_string(json_text)
		file.close()

func load_array_json(file_path: String) -> Array:
	if not FileAccess.file_exists(file_path):
		push_warning("Fichier non trouvé : ", file_path)
		return []

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			return json.data
		else:
			push_error("Erreur de parsing JSON : ", json.get_error_message())
			return []
	else:
		push_error("Erreur lors de l'ouverture du fichier : ", file_path)
		return []

func filepath_to_global(path: String):
	return ProjectSettings.globalize_path(path)

func get_song_stream(global_path: String) -> AudioStreamMP3:
	var audio_stream = AudioStreamMP3.new()  # ou AudioStreamWAV, AudioStreamOggVorbis
	var file = FileAccess.open(global_path, FileAccess.READ)
	if not file:
		Global.logs_display.write("get_song_stream, Can't open the file at %s" % global_path, LogsDisplay.MESSAGE.ERROR)
		return audio_stream
	var bytes = file.get_buffer(file.get_length())
	audio_stream.data = bytes
	return audio_stream

func duplicate_file(source_path: String, destination_dir: String, new_filename: String = "") -> bool:
	# Vérifier si le fichier source existe
	if not FileAccess.file_exists(source_path):
		push_error("Fichier source introuvable: " + source_path)
		return false
	
	# Préparer le chemin de destination
	var extension = source_path.get_extension()
	var source_filename = source_path.get_file()
	var destination_filename = new_filename if not new_filename.is_empty() else source_filename
	var destination_path = destination_dir.path_join(destination_filename)
	
	if destination_path.get_extension() == "":
		destination_path += "." + extension
	
	# S'assurer que le dossier de destination existe
	if not DirAccess.dir_exists_absolute(destination_dir):
		push_error(destination_dir, " n'existe pas")
		return false
	
	# Copier le fichier
	var error = DirAccess.copy_absolute(source_path, destination_path)
	
	if error == OK:
		print("Fichier dupliqué avec succès:")
		print("Source: " + source_path)
		print("Destination: " + destination_path)
		return true
	else:
		push_error("Erreur lors de la duplication: " + str(error))
		return false

#func get_next_char_id(current_char: String) -> String: 	## a-z, A-Z, 0-9
	#if current_char.length() != 1:
		#return ""
	#
	#var code = current_char.unicode_at(0)
	#
	## Pour les lettres minuscules
	#if code >= ord("a") and code <= ord("z"):
		#if code == ord("z"):
			#return "A"
		#return char(code + 1)
	#
	## Pour les lettres majuscules
	#if code >= ord("A") and code <= ord("Z"):
		#if code == ord("Z"):
			#return "0"
		#return char(code + 1)
	#
	## Pour les chiffres
	#if code >= ord("0") and code <= ord("9"):
		#if code == ord("9"):
			#return "a"
		#return char(code + 1)
	#
	## Autres caractères : pas de boucle
	#return ""


func get_next_char(current_char: String) -> String: ## cf alphabet
	if current_char.length() != 1:
		return ""
	
	return alphabet[(alphabet_int_map.get(current_char) + 1) % alphabet_length]

func get_next_id(id: String):
	if id == "":
		return alphabet[0]
	
	var id_length: int = id.length()
	
	## convert to base alphabet_base
	var id_num: Array = []
	for i in range(id_length):
		id_num.append(alphabet_int_map.get(id[i]))
		
	## add 1
	var remain: bool = true
	for i in range(id_length):
		if not remain:
			break
		id_num[i] += 1
		if id_num[i] < alphabet_base:
			remain = false
		else:
			id_num[i] = 0
	
	# add a character if needed
	if remain:
		id_num.append(0)
	
	## convert 
	var next_id: String = ""
	for i in range(id_num.size()):
		next_id += alphabet[id_num[i]]
	
	return next_id
	
func is_id(id: String):
	for chara in id:
		if not chara in alphabet:
			return false
	return true

func is_youtube_id(id: String):
	if id.length() != 11:
		print("not 11 length")
		return false
	
	for chara in id:
		if not chara in youtube_id_alphabet:
			print("not chara in youtube_id_alphabet")
			return false
	
	return true

func load_html_file(file_path: String) -> String:
	print("loading ", file_path)
	if not FileAccess.file_exists(file_path):
		push_error("Le fichier n'existe pas : " + file_path)
		return ""
	
	print("exists")
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Impossible d'ouvrir le fichier : " + file_path)
		return ""
	
	print("getting content")
	var content = file.get_as_text()
	file.close()
	return content

func build_youtube_url(id: String):
	# https://www.youtube.com/watch?v=5nRC8ZpJpRg
	return "https://www.youtube.com/watch?v=" + id


func get_thumbnail(id: String) -> ImageTexture:
	var thumbnail_path: String = Global.get_thumbnail_path(id)
	if thumbnail_path == "":
		return null
	
	if not FileAccess.file_exists(thumbnail_path):
		#Global.logs_display.write("get_thumbnail, file not found: %s" % thumbnail_path, LogsDisplay.MESSAGE.INFO)
		return null
	
	var image := Image.new()
	image = image.load_from_file(thumbnail_path)
	#var error := image.load(thumbnail_path)
	#if error != OK:
		#Global.logs_display.write("get_thumbnail, failed to load image: %s, error: %s" % [thumbnail_path, error], LogsDisplay.MESSAGE.ERROR)
		#return null
	if image:
		return ImageTexture.create_from_image(image)
	else:
		return null

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
	var thumbnail: Texture2D = get_thumbnail(id)
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

## Eg:
## [br]
## {
## "category": "Songs", 
## "resultType": "song", 
## "title": "\u30ab\u30ef\u30ad\u30f2\u30a2\u30e1\u30af - Kawakiwoameku", 
## "album": {"name": "Kawakiwoameku", "id": "MPREb_r28EAcrLnXE"}, 
## "inLibrary": false, 
## "pinnedToListenAgain": false,
##  "videoId": "gxp3R7l1iSk", 
## "videoType": "MUSIC_VIDEO_TYPE_ATV", 
## "duration": "4:12", 
## "year": null, 
## "artists": 
## [{"name": "minami", "id": "UCEsOqBVe_DNEUAer9TYk6bw"}], 
## "duration_seconds": 252, 
## "views": "327M", 
## "isExplicit": false, 
## "thumbnails": [{"url": "https://yt3.googleusercontent.com/Gx74Mec9Pf3tVrtSI0siKdF6964s4Q1JEjsBLkcFaALQug_mc6Y96-scL17Sev66rBe43nH0pnRgjV_v=w60-h60-l90-rj", "width": 60, "height": 60}, {"url": "https://yt3.googleusercontent.com/Gx74Mec9Pf3tVrtSI0siKdF6964s4Q1JEjsBLkcFaALQug_mc6Y96-scL17Sev66rBe43nH0pnRgjV_v=w120-h120-l90-rj", "width": 120, "height": 120}]
## }
func save_youtube_video_infos_to_cache(track_infos: Dictionary) -> String:
	var song_id: String = track_infos.get("videoId")
	if not song_id:
		push_error("A YouTube videoId is missing, skipping this song.")
		return ""
	var song_cache_name: String = Global.RESULTS_CACHE_SONG_TEMPLATE % song_id
	
	var song_cache_res: SongCacheResource = SongCacheResource.new()
	song_cache_res.id = song_id
	song_cache_res.title = track_infos.get("title")
	song_cache_res.artists = track_infos.get("artists")
	Tools._save_to_cache(song_cache_res, Tools.get_results_cache_path() + Global.RESULTS_CACHE_SONG_TEMPLATE % song_id + ".res")
	
	var song_thumbnails: Array = track_infos.get("thumbnails", [])
	if song_thumbnails != []:
		download_biggest_thumbnail(
			song_thumbnails,
			func(song_thumbnail: Texture2D):
				Tools._save_to_cache.call_deferred(song_thumbnail, Tools.get_results_cache_path() + Global.RESULTS_CACHE_SONG_THUMBNAIL_TEMPLATE % song_id + ".res")
		)
	return song_id

func _save_to_cache(content: Resource, fullpath: String) -> void:
	var error: Error = ResourceSaver.save(content, fullpath)
	if error != OK:
		print("Erreur lors de la sauvegarde du cache: ", error)


## (ASYNC) Sets the biggest thumbnail to [param target].
## [br]
## [param callback] is called with argument [param target].
func download_biggest_thumbnail(thumbnails: Array, callback: Callable = Callable()) -> void:
	var max_url: String = get_biggest_thumbnail_url(thumbnails)
	if max_url != "":
		Scrapper.download_url(
			max_url,
			Scrapper.process_image,
			func(image:Image):
				callback.call(ImageTexture.create_from_image(image))
		)

func get_biggest_thumbnail_url(thumbnails: Array) -> String:
	var max_width: float = 0.0
	var max_url: String = "" ## url for the biggest thumbnail
	for dict: Dictionary in thumbnails:
		var dict_width: float = dict.get("width", 0.0)
		if dict_width > max_width:
			max_width = dict_width
			max_url = dict.get("url", "")
	return max_url

func from_dict_data_to_array(dict: Dictionary, attibutes: Array) -> Array[Array]:
	# {id: {name: value}} -> [[id, value]]
	var array: Array[Array] = []
	var sub_array: Array = []
	for key in dict:
		var values = dict.get(key, {})
		sub_array = [key]
		for attribute in attibutes:
			var value = values.get(attribute)
			if value != null:
				sub_array.append(value)
		array.append(sub_array)
	
	return array

func clear_directory_contents(path: String, remove_dir: bool = false) -> Error:
	var dir = DirAccess.open(path)
	if dir == null:
		return DirAccess.get_open_error()
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_item_path = path + "/" + file_name
			if dir.current_is_dir():
				var error = clear_directory_contents(full_item_path, remove_dir)
				if error != OK:
					return error
				error = dir.remove(full_item_path)
				if error != OK:
					return error
			else:
				var error = dir.remove(full_item_path)
				if error != OK:
					return error
		file_name = dir.get_next()
	dir.list_dir_end()
	
	if remove_dir:
		dir.remove(path)
	return OK

func delete_file(file_path: String) -> bool:
	if FileAccess.file_exists(file_path):
		var dir = DirAccess.open(file_path.get_base_dir())
		if dir:
			var error = dir.remove(file_path)
			if error == OK:
				Global.logs_display.write("Fichier supprimé avec succès", LogsDisplay.MESSAGE.INFO)
				return true
			else:
				Global.logs_display.write("Erreur lors de la suppression de %s: %d" % [file_path, error], LogsDisplay.MESSAGE.ERROR)
		else:
			Global.logs_display.write("Impossible d'accéder au dossier %s" % file_path, LogsDisplay.MESSAGE.ERROR)
	else:
		Global.logs_display.write("Le fichier n'existe pas (%s)" % file_path, LogsDisplay.MESSAGE.ERROR)
	return false

func is_mouse_in_box(node: Control):
	return Rect2(Vector2(), node.size).has_point(node.get_local_mouse_position())





##### TESTING
func get_dominant_colors(image: Image, color_count: int = 3) -> Array[Color]:
	var colors: Array[Color] = []
	var width = image.get_width()
	var height = image.get_height()
	
	# Échantillonner des pixels (pour performance)
	var samples: Array[Color] = []
	var step = max(1, int(sqrt(width * height) / 100))  # ~100 échantillons
	
	for y in range(0, height, step):
		for x in range(0, width, step):
			samples.append(image.get_pixel(x, y))
	
	if samples.is_empty():
		return [Color.BLACK]
	
	# Initialiser avec des couleurs aléatoires de l'échantillon
	var centroids: Array[Color] = []
	for i in range(color_count):
		centroids.append(samples[randi() % samples.size()])
	
	# K-means itératif (5 itérations suffisent généralement)
	for iteration in range(5):
		var clusters: Array[Array] = []
		for i in range(color_count):
			clusters.append([])
		
		# Assigner chaque échantillon au centroïde le plus proche
		for sample in samples:
			var min_dist = INF
			var best_cluster = 0
			for c in range(color_count):
				var dist = _color_distance(sample, centroids[c])
				if dist < min_dist:
					min_dist = dist
					best_cluster = c
			clusters[best_cluster].append(sample)
		
		# Mettre à jour les centroïdes
		for c in range(color_count):
			if clusters[c].size() > 0:
				var avg = Color(0, 0, 0, 1)
				for color in clusters[c]:
					avg += color
				centroids[c] = avg / clusters[c].size()
	
	return centroids


func _color_distance(a: Color, b: Color) -> float:
	# Distance euclidienne dans l'espace RGB
	return sqrt(pow(a.r - b.r, 2) + pow(a.g - b.g, 2) + pow(a.b - b.b, 2))




#
