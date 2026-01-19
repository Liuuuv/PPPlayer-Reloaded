extends Node

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

# Fonction utilitaire pour télécharger une page et extraire les URLs
func extract_urls_from_webpage(url: String) -> Array[String]:
	var http_request = HTTPRequest.new()
	var html_content := ""
	
	# Note: Dans la pratique, il faut ajouter HTTPRequest à la scène
	# et gérer la requête de manière asynchrone
	
	# Simulation d'extraction
	# En réalité, vous devriez :
	# 1. Créer un HTTPRequest
	# 2. Connecter le signal "request_completed"
	# 3. Faire la requête
	# 4. Dans le callback, appeler extract_youtube_urls_from_html
	
	return []

# Exemple d'utilisation dans un script Godot
#class_name WebScraper extends Node
#
#func _ready():
	## Exemple avec du contenu HTML
	#var html_example = """
	#<html>
		#<body>
			#<a href="https://www.youtube.com/watch?v=dQw4w9WgXcQ">Lien 1</a>
			#<a href="https://youtu.be/dQw4w9WgXcQ">Lien 2</a>
			#<div data-video-id="dQw4w9WgXcQ"></div>
			#<iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ"></iframe>
		#</body>
	#</html>
	#"""
	#
	#var urls = YouTubeURLExtractor.extract_youtube_urls_from_html(html_example)
	#print("URLs trouvées: ", urls)
