extends Node

var alphabet: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123455789"
var alphabet_length: int = alphabet.length()
var alphabet_int_map: Dictionary = {} ## char: int
var alphabet_base: int = alphabet_length - 1

var youtube_id_alphabet: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123455789-_"

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
		return false
	
	for chara in id:
		if not chara in youtube_id_alphabet:
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
