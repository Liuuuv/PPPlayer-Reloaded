extends Resource
class_name SongCacheResource

@export var id: String = ""
@export var title: String = ""
@export var artists: Array = [] ## [{"name": String, "id": String}]


static func create(id_: String, title_: String, artists_: Array) -> SongCacheResource:
	var resource = SongCacheResource.new()
	resource.id = id_
	resource.title = title_
	resource.artists = artists_
	
	if resource.title == "":
		print("Missing title for song cache result. Check if the 'title' key exists.")
	if resource.artists.is_empty():
		push_error("Missing artists for song cache result. Check if the 'artists' key exists.")
	
	return resource
