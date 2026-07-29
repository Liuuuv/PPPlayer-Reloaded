extends SongVirtualScrollList
class_name DownloadedSongs


func _gui_input(event: InputEvent) -> void:
	super._gui_input(event)
	#print(hovered_idx)


func reload_list() -> void:
	#print("reloading song list..")
	Global.logs_display.write("reloading song list..")
	
	items.clear()
	
	var id_to_display: Array[String] = Global.downloaded_tab.id_to_display as Array[String]
	if not id_to_display:
		queue_redraw()
		return
	# if a filter is applied
	if id_to_display != ["_all"]:
		for id in id_to_display:
			_add_item(Global.create_song_item(id), false)
		queue_redraw()
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
			#id = file_name.get_basename()
			#if not Tools.is_id(id) or not Global.song_infos.has(id):
				#file_name = dir.get_next()
				#continue
			#if not dir.current_is_dir():
				#var extension = file_name.get_extension()
				#if extension in Global.SUPPORTED_EXTENSIONS:
					#var full_path = Global.get_downloads_path() + file_name
					##print("reload_list > fullpath ", full_path)
					##Global.logs_display.write("reload_list > fullpath " + full_path)
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
		_add_item(Global.create_song_item(id), false)
		all_displayed_names.set(
			id,
			Global.song_infos.get(id).get("display_name", "")
		)
	Global.all_displayed_names = all_displayed_names
	
	queue_redraw()
	super.reload_list()


#
