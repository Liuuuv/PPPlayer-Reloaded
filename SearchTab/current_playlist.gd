extends VBoxContainer
class_name CurrentPlaylist

var content_ids: Array[String] = []

func _ready() -> void:
	Global.current_playlist = self
	reload_song_items()

func reload_song_items() -> void:
	for child in get_children():
		child.queue_free()
	
	for index in range(content_ids.size()):
		var song_item = Global.create_song_item(content_ids[index])
		song_item.location = "current_playlist"
		song_item.index = index
		add_child(song_item)
		# FAIRE QUE LE LOAD SE FAIT A UN ENDROIT AVEC UNE LISTE ET ASYNC

func clear_song_items() -> void:
	for child in get_children():
		child.queue_free()
	
	content_ids = []
	
