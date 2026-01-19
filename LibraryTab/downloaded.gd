extends Control
class_name DownloadedTab

@onready var song_list: VBoxContainer = %DownloadedSongList

func _ready() -> void:
	reload_song_list()
	
	Global.downloads_folder_changed.connect(_on_downloads_folder_changed)



func reload_song_list() -> void:
	print("reloading song list..")
	
	for child in song_list.get_children():
		child.queue_free()
	
	var song_item: SongItem
	var id: String
	var dir = DirAccess.open(Global.get_downloads_path())
	#var temp: int = 0
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			id = file_name.get_basename()
			if not Tools.is_id(id):
				file_name = dir.get_next()
				continue
			if not dir.current_is_dir():
				var extension = file_name.get_extension()
				if extension in ["mp3", "ogg", "wav"]:
					var full_path = Global.get_downloads_path() + file_name
					print("reload_song_list > fullpath ", full_path)
					song_item = Global.create_song_item(id)
					song_list.add_child(song_item)
			file_name = dir.get_next()

func _on_downloads_folder_changed():
	reload_song_list()
