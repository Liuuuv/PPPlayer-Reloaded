extends Node



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
	if full_file_path == "":
		return {}
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
		print("JSON Parse Error: for file %s" %  full_file_path, json.get_error_message())
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

func build_youtube_url(id: String) -> String:
	# https://www.youtube.com/watch?v=5nRC8ZpJpRg
	return "https://www.youtube.com/watch?v=" + id

func build_playlist_url(playlist_id: String) -> String:
	# https://www.youtube.com/playlist?list=PLd-zJRILbNSAsC-wiJFfLD384gxxOBg1i
	return "https://www.youtube.com/playlist?list=" + playlist_id


func get_thumbnail(id: String) -> ImageTexture:
	var image: Image = get_thumbnail_image(id)
	if image:
		return ImageTexture.create_from_image(image)
	else:
		return null

func get_thumbnail_image(id: String) -> Image:
	for extension in ["webp", "jpg"]:
		var thumbnail_path: String = Global.get_thumbnail_path(id, extension)
		if thumbnail_path == "":
			continue
		
		if not FileAccess.file_exists(thumbnail_path):
			#Global.logs_display.write("get_thumbnail, file not found: %s" % thumbnail_path, LogsDisplay.MESSAGE.INFO)
			continue
		
		var image := Image.new()
		image = image.load_from_file(thumbnail_path)
		if image:
			return image
		else:
			continue
	return null



## (ASYNC) Calls [param callback] with the downloaded [Image] as single argument.
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

## Used for summary.[br]
## {id: {key1: value1}, {key2: value2}} -> [[id, value1, value2]][br]
## The order of the values is dicted by [param attributes].
func from_dict_data_to_array(dict: Dictionary, attibutes: Array) -> Array[Array]:
	var array: Array[Array] = []
	var sub_array: Array = []
	for key in dict:
		var values = dict.get(key, {})
		sub_array = [key]
		for attribute in attibutes:
			var value = values.get(attribute)
			if value != null:
				sub_array.append(value)
				#sub_array.append(str(value))
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

func delete_file(file_path: String, raise_error_if_doesnt_exists: bool = false) -> bool:
	if FileAccess.file_exists(file_path):
		var dir = DirAccess.open(file_path.get_base_dir())
		if dir:
			var error = dir.remove(file_path)
			if error == OK:
				Global.logs_display.write("File successfully deleted.", LogsDisplay.MESSAGE.INFO)
				return true
			else:
				Global.logs_display.write("Error when deleting %s: %d" % [file_path, error], LogsDisplay.MESSAGE.ERROR)
		else:
			Global.logs_display.write("Can't access the file %s" % file_path, LogsDisplay.MESSAGE.ERROR)
	else:
		if raise_error_if_doesnt_exists:
			Global.logs_display.write("The file does not exists (%s)." % file_path, LogsDisplay.MESSAGE.ERROR)
		Global.logs_display.write("The file does not exists (%s)." % file_path, LogsDisplay.MESSAGE.DEBUG)
	return false

static func delete_thumbnail(local_id: String):
	var file_paths = []
	var file_path: String = ""
	
	file_path = Global.get_downloads_path() + local_id + ".webp"
	file_paths.append(file_path)
	file_path = Global.get_downloads_path() + local_id + ".jpg"
	file_paths.append(file_path)
	
	for path in file_paths:
		Tools.delete_file(path, false)

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

## [param script_name] example: [code]"ytmusic_get_artist_infos"[/code].
func get_python_script_fullpath(script_name: String) -> String:
	var script = ProjectSettings.globalize_path(Global.PYTHON_SCRIPTS_PATH.path_join(script_name + ".py"))
	return script

class SignalRelay:
	extends RefCounted

	signal finished(value)

## [param signal1] must return something. [br]
## [br]
## Returns the value of signal1 or null depending on which one finishes first.
func await_or_timeout(signal1: Signal, timeout := 15.0, timeout_output = null):
	var relay := SignalRelay.new()
	var done := false
	
	var timer := get_tree().create_timer(timeout)

	signal1.connect(func(value = timeout_output):
		if done:
			return
		done = true
		relay.finished.emit(value)
	, CONNECT_ONE_SHOT)

	timer.timeout.connect(func():
		if done:
			return
		done = true
		relay.finished.emit(timeout_output)
	, CONNECT_ONE_SHOT)

	return await relay.finished


func clear_file_cache() -> void:
	Global.logs_display.write("Deleting file cache...", LogsDisplay.MESSAGE.DEBUG)
	var full_path: String = Global.get_downloads_path() + Global.CACHE_DIR_NAME
	if DirAccess.dir_exists_absolute(full_path):
		
		var error: Error = Tools.clear_directory_contents(full_path)
		if error != OK:
			Global.logs_display.write("Error when deleting cache: %s" % error, LogsDisplay.MESSAGE.ERROR)
		else:
			Global.logs_display.write("Cache deleted successfully", LogsDisplay.MESSAGE.INFO)
	else:
		Global.logs_display.write("Cache didn't exist", LogsDisplay.MESSAGE.INFO)

func get_full_path_from_id(id: String) -> String:
	var song_info = Global.song_infos.get(id)
	if song_info:
		var extension = song_info.get("extension")
		if extension:
			var full_path = Global.get_downloads_path() + id + "." + extension
			return full_path
		else:
			push_error("no extension available for id %s" % id)
			return ""
	else:
		push_error("no song info available for id  %s" % id)
		return ""

func contains_japanese_character(text: String) -> bool:
	for character in text:
		var code: int = character.unicode_at(0)
		
		# Hiragana (3040-309F)
		if code >= 0x3040 and code <= 0x309F:
			return true
		
		# Katakana (30A0-30FF)
		if code >= 0x30A0 and code <= 0x30FF:
			return true
		
		# Kanji (4E00-9FFF) - CJK Unified Ideographs
		if code >= 0x4E00 and code <= 0x9FFF:
			return true
		
		# Katakana Phonetic Extensions (31F0-31FF)
		if code >= 0x31F0 and code <= 0x31FF:
			return true
		
		# CJK Radicals Supplement (2E80-2EFF)
		if code >= 0x2E80 and code <= 0x2EFF:
			return true
	
	return false

func duration_to_string(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

func fullpath_to_filename(full_path: String) -> String:
	return full_path.get_file().get_basename()

## Calculates recursively and returns the size (in bytes) of the given folder.
func get_directory_size(path: String) -> int:
	var total_size: int = 0
	
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Unable to open the folder: %s" % path)
		return 0
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir():
			total_size += get_directory_size(full_path)
		else:
			var file = FileAccess.open(full_path, FileAccess.READ)
			if file:
				total_size += file.get_length()
				file.close()
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return total_size


func get_byte_string(bytes: int) -> String:
	if bytes < 1024:
		return "%d o" % bytes
	elif bytes < 1024 * 1024:
		return "%.1f Ko" % (bytes / 1024.0)
	elif bytes < 1024 * 1024 * 1024:
		return "%.1f Mo" % (bytes / (1024.0 * 1024.0))
	else:
		return "%.2f Go" % (bytes / (1024.0 * 1024.0 * 1024.0))


#
