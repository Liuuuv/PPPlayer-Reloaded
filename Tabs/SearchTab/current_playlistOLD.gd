extends VBoxContainer
class_name CurrentPlaylistOLD

var content_ids: Array[String] = [] ## contains the ids of the songs
var queue_ids: Array[String] = [] ## contains the ids of the queue

func _ready() -> void:
	#Global.current_playlist = self ## TEMP
	reload_song_items()

func reload_song_items() -> void:
	for child in get_children():
		child.queue_free()
	
	for index in range(content_ids.size()):
		var song_item: SongItemOLD = Global.create_song_itemOLD(content_ids[index])
		song_item.location = Global.SONG_IDS_LOCATIONS.CURRENT_PLAYLIST
		song_item.index = index
		add_child(song_item)

func clear_song_items() -> void:
	for child in get_children():
		child.queue_free()
	
	content_ids = []
	
