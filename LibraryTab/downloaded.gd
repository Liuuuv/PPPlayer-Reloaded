extends Control
class_name DownloadedTab

# TODO manage files that are not treated in song infos/downlaoded songs

@onready var song_listOLD: VBoxContainer = %DownloadedSongListOLD
@onready var song_list: Control = %DownloadedSongList

## pooling
var _available_song_items = []
var _in_use_song_items = []
var max_pool_size: int = 50

var ids_to_add: Array[String] = []

func _ready() -> void:
	Global.downloaded_tab = self
	
	initialize.call_deferred()
	

func initialize():
	
	for child in song_listOLD.get_children():
		child.queue_free()
	
	reload_song_list()
	
func reload_song_list() -> void:
	#reload_song_listOLD()
	#return
	
	#print("reloading song list..")
	Global.logs_display.write("reloading song list..")
	
	song_list.items.clear()
	
	var id: String
	var dir = DirAccess.open(Global.get_downloads_path())

	var time = Time.get_ticks_msec()
	print('start ', time)
	var num: int = 0
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			#if num > 5:
				#break
			id = file_name.get_basename()
			if not Tools.is_id(id) or not Global.song_infos.has(id):
				file_name = dir.get_next()
				continue
			if not dir.current_is_dir():
				var extension = file_name.get_extension()
				if extension in ["mp3", "ogg", "wav"]:
					var full_path = Global.get_downloads_path() + file_name
					#print("reload_song_list > fullpath ", full_path)
					Global.logs_display.write("reload_song_list > fullpath " + full_path)
					song_list.items.append(Global.create_song_item(id))
					
					#num += 1
					#ids_to_add.append(id)
					
					#song_item = get_object(id)
					
					
			file_name = dir.get_next()
	
	song_list.queue_redraw()
	print('end ', Time.get_ticks_msec())
	print("elapsed time create ", Time.get_ticks_msec() - time)
	

func reload_song_listOLD() -> void: ## OLD, LAGGY
	
	#print("reloading song list..")
	Global.logs_display.write("reloading song list..")
	
	var time = Time.get_ticks_msec()
	for child in song_listOLD.get_children():
		child.queue_free()
	print("elapsed time freeing ", Time.get_ticks_msec() - time)
	
	var song_item: SongItemOLD
	var id: String
	var dir = DirAccess.open(Global.get_downloads_path())

	time = Time.get_ticks_msec()
	print('start ', time)
	var num: int = 0
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			#if num > 5:
				#break
			id = file_name.get_basename()
			if not Tools.is_id(id) or not Global.song_infos.has(id):
				file_name = dir.get_next()
				continue
			if not dir.current_is_dir():
				var extension = file_name.get_extension()
				if extension in ["mp3", "ogg", "wav"]:
					var full_path = Global.get_downloads_path() + file_name
					#print("reload_song_list > fullpath ", full_path)
					Global.logs_display.write("reload_song_list > fullpath " + full_path)
					song_item = Global.create_song_itemOLD(id)
					song_listOLD.add_child(song_item)
					#num += 1
					#ids_to_add.append(id)
					
					#song_item = get_object(id)
					
					
			file_name = dir.get_next()
			
	print('end ', Time.get_ticks_msec())
	print("elapsed time create ", Time.get_ticks_msec() - time)

#func _physics_process(delta: float) -> void:
	#if ids_to_add != []:
		#var id = ids_to_add.pop_back()
		##get_object(id)
		#var song_item = Global.create_song_item(id)
		#song_list.add_child(song_item)
#
#func create_song_item_pool(id: String) -> SongItem:
	#if _available_song_items.size() + _in_use_song_items.size() >= max_pool_size:
		#return
	#
	#var song_item: SongItem = Global.create_song_item(id)
	#song_list.add_child(song_item)
	#
	#song_item.hide()
	#_available_song_items.append(song_item)
	#
	#return song_item
#
#func get_object(id: String) -> SongItem:
	#if _available_song_items.is_empty():
		#var song_item = create_song_item_pool(id)
		#if song_item:
			#song_item.show()
			#return song_item
		#else:
			## Recycle oldest object if max size reached
			#if not _in_use_song_items.is_empty():
				#return recycle_oldest_object(id)
			#return null
			#
	#var obj = _available_song_items.pop_front()
	#obj.id = id
	#return obj
#
#func recycle_oldest_object(id) -> Node:
	#if _in_use_song_items.is_empty():
		#return null
		#
	#var oldest = _in_use_song_items[0]
	#release_object(oldest)
	#oldest.show()
	#return get_object(id)
#
#func release_object(obj: Node):
	#obj.hide()
