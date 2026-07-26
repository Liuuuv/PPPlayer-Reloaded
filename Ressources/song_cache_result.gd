extends Resource
class_name SongCacheResource

@export var id: String = ""
@export var title: String = ""
@export var artists: Array = [] ## [{"name": String, "id": String}]

func _init(id_: String, title_: String, artists_: Array) -> void:
	id = id_
	title = title_
	artists = artists_
	
	if title == "":
		push_error("Missing title for song cache result. Check if the 'title' key exists.")
	
	if artists.is_empty():
		push_error("Missing artists for song cache result. Check if the 'artists' key exists.")
