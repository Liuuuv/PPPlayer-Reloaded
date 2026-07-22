extends Control
class_name DownloadedTab

signal song_item_clicked(id: String)



@onready var song_list: SongVirtualScrollList = %DownloadedSongList
@onready var shuffle_button: ButtonComponent = %ShuffleButton

## pooling
#var _available_song_items = []
#var _in_use_song_items = []
#var max_pool_size: int = 50

#var ids_to_add: Array[String] = [] 

func _ready() -> void:
	Global.downloaded_tab = self
	
	
	initialize.call_deferred()
	
	shuffle_button.pressed.connect(_on_shuffle_button_pressed)
	#song_item_clicked.connect(_on_song_item_clicked)

func initialize():
	
	reload_song_list()
	
	#song_list.item_left_clicked.connect(_on_item_left_clicked)

func reload_song_list(id_to_display: Array = ["all"]) -> void:
	#reload_song_listOLD()
	#return
	
	#print("reloading song list..")
	Global.logs_display.write("reloading song list..")
	
	song_list.items.clear()
	
	#var num: int = 0
	
	# if a filter is applied
	if id_to_display != ["all"]:
		for id in id_to_display:
			song_list._add_item(Global.create_song_item(id), false)
		song_list.queue_redraw()
		return
	
	## if no filter applied
	#var id: String
	#var dir = DirAccess.open(Global.get_downloads_path())
	#
	#var time = Time.get_ticks_msec()
	#print('start ', time)
	#var all_displayed_names: Dictionary = {}
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#while file_name != "":
			##if num > 5:
				##break
			#id = file_name.get_basename()
			#if not Tools.is_id(id) or not Global.song_infos.has(id):
				#file_name = dir.get_next()
				#continue
			#if not dir.current_is_dir():
				#var extension = file_name.get_extension()
				#if extension in ["mp3", "ogg", "wav"]:
					#var full_path = Global.get_downloads_path() + file_name
					##print("reload_song_list > fullpath ", full_path)
					##Global.logs_display.write("reload_song_list > fullpath " + full_path)
					#song_list.items.append(Global.create_song_item(id))
					#
					## for search queries
					#if Global.song_infos.has(id):
						#all_displayed_names.set(Global.song_infos.get(id).get("display_name"), id)
#
			#file_name = dir.get_next()
	#Global.all_displayed_names = all_displayed_names
	#print('end ', Time.get_ticks_msec())
	#print("elapsed time create ", Time.get_ticks_msec() - time)
	
	# from song_infos
	var all_displayed_names: Dictionary = {}
	for id in Global.song_infos:
		song_list._add_item(Global.create_song_item(id), false)
		all_displayed_names.set(
			id,
			Global.song_infos.get(id).get("display_name", "")
		)
	Global.all_displayed_names = all_displayed_names
	
	song_list.queue_redraw()

func _on_shuffle_button_pressed() -> void:
	var shuffle_playlist: Array[String] = []
	shuffle_playlist.assign(Global.song_infos.keys())
	shuffle_playlist.shuffle()
	Global.current_playlist.content_ids = shuffle_playlist
	Global.current_playlist.reload_song_items()
	SongManager.play_from_index(0, true)



#
