extends Node

# Ajoutez cette variable en haut de votre script (au niveau de la classe)
var _thumbnail_cache: Dictionary = {}
var _result_thumbnail_cache: Dictionary = {} ## {filename: content}

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
		file.close()


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
	#var thumbnail: Texture2D = get_thumbnail(id)
	#return thumbnail
	#print("get_cached_thumbnail for id %s" % id)
	
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

func get_cached_results(cache_name: String) -> Resource: ## eg: returns a dict for artists' page, a Texture2D for video thumbnails
	
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

func _save_to_cache(content: Resource, cache_path: String) -> void:
	var error = ResourceSaver.save(content, cache_path)
	if error != OK:
		print("Erreur lors de la sauvegarde du cache: ", error)

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
				Global.logs_display.write("Erreur lors de la suppression: %d" % error, LogsDisplay.MESSAGE.ERROR)
		else:
			Global.logs_display.write("Impossible d'accéder au dossier", LogsDisplay.MESSAGE.ERROR)
	else:
		Global.logs_display.write("Le fichier n'existe pas", LogsDisplay.MESSAGE.ERROR)
	return false

func set_mouse_filter_stop_recursivly(node: Control): ## useless bc it exists in the inspector lol
	node.mouse_filter = Control.MOUSE_FILTER_STOP
	for child in node.get_children():
		set_mouse_filter_stop_recursivly(child)





#
