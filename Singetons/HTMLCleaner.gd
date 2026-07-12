extends Node

var regex_js_id = RegEx.new()

func _ready() -> void:
	regex_js_id.compile('id="([^"]+)"')

# Méthode principale pour extraire les URLs YouTube d'une page HTML
func extract_youtube_ids_from_html(html_content: String) -> PackedStringArray:
	var youtube_ids := PackedStringArray()
	
	# Patterns pour trouver les IDs de vidéo YouTube
	var patterns = [
		#'youtube\\.com/watch\\?v=([0-9A-Za-z_-]{11})',
		#'youtu\\.be/([0-9A-Za-z_-]{11})',
		'watch\\?v=([0-9A-Za-z_-]{11})' ## YTMusic PC 18.01.26
		#'youtube\\.com/shorts/([0-9A-Za-z_-]{11})'
	]
	
	for pattern in patterns:
		var regex = RegEx.new()
		var error = regex.compile(pattern)
		if error == OK:
			var results = regex.search_all(html_content)
			for result in results:
				if result.get_strings().size() > 1:
					var video_id = result.get_string(1)
					if not youtube_ids.has(video_id):
						youtube_ids.append(video_id)
	
	return youtube_ids

# Nettoyer une URL YouTube
func get_video_id(url: String) -> String:
	if url.is_empty():
		return url
	
	# Extraire l'ID de la vidéo depuis différents formats
	var video_id := ""
	
	# Format court youtu.be
	var short_pattern = "youtu\\.be/([0-9A-Za-z_-]{11})"
	var regex = RegEx.new()
	if regex.compile(short_pattern) == OK:
		var result = regex.search(url)
		if result:
			video_id = result.get_string(1)
	
	# Format long youtube.com/watch?v=
	if video_id.is_empty():
		var long_pattern = "youtube\\.com/watch\\?v=([0-9A-Za-z_-]{11})"
		if regex.compile(long_pattern) == OK:
			var result = regex.search(url)
			if result:
				video_id = result.get_string(1)
	
	# general case
	if video_id.is_empty():
		var shorts_pattern = "watch\\?v=([0-9A-Za-z_-]{11})"
		if regex.compile(shorts_pattern) == OK:
			var result = regex.search(url)
			if result:
				video_id = result.get_string(1)
	
	if not video_id.is_empty():
		return video_id
	
	return url
	
func extract_text_from_container(html: String, container_name: String="span") -> String:
	## <div>This is a div element.</div> -> This is a div element.
	var start: int= html.find(">") + 1
	var end: int = html.rfind("</%s>" % container_name)

	if start <= 0 or end == -1:
		return ""

	return html.substr(start, end - start)

func decode_js_id(html: String, element_id: String):
	var regex = RegEx.new()
	regex.compile("o\\('([^']+)'\\s*,\\s*'" + element_id + "'\\)")
	var match_ = regex.search(html)
	
	if match_:
		var encoded_text = match_.get_string(1)
		print("Texte encodé trouvé pour l'ID ", element_id, " : ", encoded_text)
		
		# 2. Décoder
		var decoded = _decode_obfuscated_text(encoded_text)
		print("Texte décodé : ", decoded)
		return decoded
	
	print("Aucun script trouvé pour l'ID : ", element_id)
	return ""

func _decode_obfuscated_text(encoded: String) -> String:
	# Étape 1 : Base64 decode
	var bytes = Marshalls.base64_to_raw(encoded)
	if bytes.size() == 0:
		return ""
	
	var text = bytes.get_string_from_utf8()
	
	# Étape 2 : URL decode si nécessaire
	if "%" in text:
		text = text.uri_decode()
	
	return text

func find_valid_span_id(html: String) -> String:
	for match_ in regex_js_id.search_all(html):
		var id = match_.get_string(1)
		if id != "":  # Ignorer les IDs vides
			return id
	
	return ""  # Aucun ID valide trouvé

























#
