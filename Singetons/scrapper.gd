extends Node

var http_request: HTTPRequest
var current_callback: Callable
var current_process_func: Callable = Callable()
var current_scrap_json_path: String = ""

var busy: bool = false
var pending_requests: Array = [] ## [{"search_url": String, "callback": Callable}]

var explicit_url: bool = false ## if the user gives the full url. If true, then the query is the full url

func _ready():
	http_request = HTTPRequest.new()
	http_request.use_threads = true
	http_request.timeout = 10.0
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

## Don't forget to set [member process_func] before calling this function.
## Order: [method download_url] > [method process_func] > [method callback]
func download_url(search_url: String, process_func: Callable, callback: Callable) -> void:
	
	
	if busy:
		pending_requests.push_back({
			"search_url": search_url,
			"process_func": process_func,
			"callback": callback
		})
		#push_error("A request is already on going, I'm busy.")
		return
	current_callback = callback
	current_process_func = process_func
	var headers = [
		"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
	]
	#var headers = [
		#"User-Agent: python-requests/2.28.0"
	#]
	
	busy = true
	var error = http_request.request(search_url, headers)
	if error != OK:
		push_error("Erreur de requête: ", error)
		callback.callv([])
		_reset()

############ BEGIN anison ############
#func search_anison(query: String, callback: Callable) -> void: ## unused bc of the python script
	#var encoded_query = query.uri_encode()
	#var search_url = "https://anison.online/en/song?search_text=" + encoded_query + "&section=0&category_id=0&tags=&bpm=0"
	#process_func = process_anison_html
	#download_url(search_url, callback)

#func process_anison_html(body: PackedByteArray) -> void: ## unused bc of the python script
	#var html: String = body.get_string_from_utf8()
	#var results = []
	#
	#var container = find_all_elements_by_class(html, "song-box", "div")
	##print("container ", container)
	#var found: bool = false
	#for song_box_html in container:
		#var result = {}
		#
		## SONG NAME
		#var song_name_divs = find_all_elements_by_class(song_box_html, "song-name", "div")
		#for song_name_div in song_name_divs:
			#var song_name_spans: Array = find_all_elements_by_class(song_name_div, "select-none", "span")
			#for span_html: String in song_name_spans:
				#var potential_song_name: String = HtmlCleaner.extract_text_from_container(span_html, "span").strip_edges()
				#if potential_song_name != "" and potential_song_name != "　": ## japanese white space
					#result.set('song_name', potential_song_name)
					#found = true
					#break
			#if not found: ## if this name was not written yet
				#for span_html: String in song_name_spans:
					#var js_id: String = HtmlCleaner.find_valid_span_id(span_html)
					#if js_id != "":
						#var potential_song_name: String = HtmlCleaner.decode_js_id(html, js_id)
						#if potential_song_name != "":
							#result.set('song_name', potential_song_name)
							#found = true
		#
		## ARTIST
		#var artist_name_as = find_all_elements_by_class(html, "block truncate", "a")
		#for artist_name_a in artist_name_as:
			#var artist: String = HtmlCleaner.extract_text_from_container(artist_name_a, "a").strip_edges()
			#if artist != "":
				#result.set('artist', artist)
				#break
	#
	#current_callback.call(results)
	##print(Marshalls.base64_to_utf8("R0xBU1NZJTIwU0tZ"))
	##text.uri_decode()




#func search_utanet(query: String, callback: Callable, given_explicit_url: bool = false) -> void:
	#current_scrap_json_path = ProjectSettings.globalize_path("res://utanet_song_list.json")
	#explicit_url = given_explicit_url
	#scrap(query, callback)

#func utanet_lyrics(query: String, callback: Callable, given_explicit_url: bool = false) -> void:
	#current_scrap_json_path = ProjectSettings.globalize_path("res://utanet_lyrics_scrap.json")
	#explicit_url = given_explicit_url
	#scrap(query, callback)
	#
#func process_genius(query: String, callback: Callable, given_explicit_url: bool = false) -> void:
	#current_scrap_json_path = ProjectSettings.globalize_path("res://genius_scrap_config.json")
	#explicit_url = given_explicit_url
	#scrap(query, callback)


func process_generic(query: String, callback: Callable, given_explicit_url: bool = false) -> void:
	explicit_url = given_explicit_url
	scrap(query, callback)

func set_scrap_config(fullpath: String):
	current_scrap_json_path = fullpath


func scrap(query: String, callback: Callable): ## gets the html page by Godot, and then sends it to a python scrip via a temp file
	var scrap_json = Tools.load_json_file(current_scrap_json_path)
	var search_url: String = ""
	if explicit_url:
		search_url = query
	else:
		var encoded_query = query.uri_encode()
		search_url = scrap_json["url"].replace(
			"{query}",
			encoded_query
		)
	print("search_url ", search_url)
	download_url(search_url, process_html, callback)

func process_html(body: PackedByteArray) -> void:
	var html: String = body.get_string_from_utf8()
	
	
	var script = ProjectSettings.globalize_path("res://PythonFiles/generic_scrapper.py")
	var temp_path: String = _save_temp_html(html)
	var html_file = ProjectSettings.globalize_path(temp_path)
	var config = current_scrap_json_path
	
	UsePython.execute_python_script(
		[
			script,
			html_file,
			config
		],
		current_callback
	)

func process_image(body: PackedByteArray) -> void:
	var image: Image = Image.new()
	var error = image.load_jpg_from_buffer(body)
	if error != OK:
		error = image.load_png_from_buffer(body)
		current_callback.call(null)
	current_callback.call(image)



func _save_temp_html(html: String) -> String: ## returns globalized path
	var temp_path = "user://temp_page.html"

	var file = FileAccess.open(temp_path, FileAccess.WRITE)
	file.store_string(html)
	file.close()
	print('file stored')
	
	return ProjectSettings.globalize_path(temp_path)
	

func _on_request_completed(result, response_code, headers, body):
	if not current_callback.is_valid() or current_callback.is_null():
		_reset()
		check_for_request_queue()
		push_error("current_callback is not valid or is null")
		return
	if not current_process_func.is_valid() or current_process_func.is_null():
		_reset()
		check_for_request_queue()
		push_error("process_func is not valid or is null")
		return
	
	
	if response_code == 200:
		current_process_func.call(body) ## !!!!! returns body !!!!!
	else:
		push_error("Erreur HTTP: ", response_code)
		Global.logs_display.write("Erreur HTTP: " + response_code, LogsDisplay.MESSAGE.ERROR)
		current_process_func.call("")
	
	_reset()
	check_for_request_queue()
	

func _reset():
	current_callback = Callable()
	current_process_func = Callable()
	current_scrap_json_path = ""
	busy = false
	
func check_for_request_queue():
	if not pending_requests.is_empty():
		var request: Dictionary = pending_requests.pop_front()
		download_url(
			request.get("search_url", ""),
			request.get("process_func", Callable()),
			request.get("callback", Callable()),
		)

#func extract_song_data(html: String) -> Dictionary:
	#var data = {}
	#
	## Extraire le titre
	#var title_regex = RegEx.new()
	#title_regex.compile('<h3[^>]*>(.*?)</h3>')
	#var title_match = title_regex.search(html)
	#if title_match:
		#data["title"] = strip_html_tags(title_match.get_string(1))
	#
	## Extraire l'artiste
	#var artist_regex = RegEx.new()
	#artist_regex.compile('<p class="artist"[^>]*>(.*?)</p>')
	#var artist_match = artist_regex.search(html)
	#if artist_match:
		#data["artist"] = strip_html_tags(artist_match.get_string(1))
	#
	## Extraire l'URL - CORRIGÉ: utiliser \\ pour échapper le point
	#var url_regex = RegEx.new()
	#url_regex.compile('<a href="(https://anison\\.online/en/song/[^"]+)"')
	#var url_match = url_regex.search(html)
	#if url_match:
		#data["url"] = url_match.get_string(1)
	#
	#return data

#func strip_html_tags(text: String) -> String:
	#var regex = RegEx.new()
	#regex.compile('<[^>]*>')
	#return regex.sub(text, "", true).strip_edges()
#
#func find_all_elements_by_class(html: String, name_class: String, tag: String = "") -> Array:
	#var results = []
	#var pattern = "<" + tag + '[^>]*class="[^"]*' + name_class + '[^"]*"[^>]*>(.*?)</' + tag + ">"
		#
	#var regex = RegEx.new()
	#if regex.compile(pattern) != OK:
		#return results
	#
	#for match_ in regex.search_all(html):
		#results.append(match_.get_string())
	#
	#return results
#
#func find_all_elements_by_ref(html: String, href_pattern: String, tag: String) -> Array:
	#var regex = RegEx.new()
	#regex.compile('<' + tag + '[^>]*href="' + href_pattern + '"[^>]*>([\\s\\S]*?)</' + tag + '>')
	#
	#var results = []
	#for match_ in regex.search_all(html):
		#results.append(match_.get_string())
	#
	#return results
