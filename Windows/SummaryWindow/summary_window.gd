extends BaseWindow
class_name SummaryWindow


var summary: Dictionary = {}

var already_downloaded_video_ids = {} ## {youtube_id: 0}


@onready var table: Table = %Table

var context_menu: ContextMenu
var last_clicked_local_id: String = ""

var header: Array[String] = [
	"id",
	"has_song_info",
	"has_artist",
	"has_display_name",
	"has_extension",
	"has_release_date",
	"has_thumbnail_path",
	"has_video_id",
	"is_duplicate_video_id",
	"file_exists",
]


func _ready() -> void:
	super()
	
	Global.summary_window = self
	table.header_row = header
	

	_initialize_context_menu()
	table.CLICK_ROW.connect(_on_table_click_row)

func _initialize_context_menu():
	context_menu = ContextMenu.new()
	
	
	context_menu.attach_to(self)
	context_menu.set_minimum_size(Vector2i(400, 0))
	#context_menu.add_placeholder_item("%s" % _get_selected_idx(), true, null)
	context_menu.add_header_item("HEADER", null)
	context_menu.add_item("Update infos", _update_info_selected, false, null)

	#context_menu.connect_to(self)


func do_checkup() -> void:
	summary = {}
	already_downloaded_video_ids = {}
	var dir = DirAccess.open(Global.get_downloads_path())
	var id: String = ""
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
					#var full_path = Global.get_downloads_path() + file_name
					#print("reload_song_list > fullpath ", full_path)
					
					process_from_folder(id)

			file_name = dir.get_next()
	
	for local_id in Global.song_infos.keys():
		if not summary.has(local_id):
			process_from_song_info(local_id)
	
	Tools.write_json_file(summary, "user://summary.json")
	print("%s songs analyzed." % summary.size())
	Global.summary_window.display_data(summary)
	#print("already_downloaded_video_ids ", already_downloaded_video_ids)

func process_from_folder(id: String):
	#print("processing %s" % id)
	var info: Dictionary = {}
	var song_info: Dictionary = Global.song_infos.get(id)
	if song_info:
		info.set("has_song_info", true)
	else:
		info.set("has_song_info", false)
	info.set("has_artist", true if song_info.get("artist", "") != "" else false)
	#info.set("has_artist", false)
	info.set("has_display_name", true if song_info.get("display_name", "") != "" else false)
	info.set("has_extension", true if song_info.get("extension", "") != "" else false)
	info.set("has_release_date", true if song_info.get("release_date", "") != "" else false)
	info.set("has_thumbnail_path", true if song_info.get("thumbnail_path", "") != "" else false)
	var video_id = song_info.get("video_id", "")
	info.set("has_video_id", true if video_id != "" else false)
	
	if video_id != "":
		info.set("is_duplicate_video_id", video_id in already_downloaded_video_ids) ## if two are the same, only flag the second one. CHANGE DOWNLOADED_SONGS video_id : id TO STORE AND FIX
		if not already_downloaded_video_ids.has(video_id):
			already_downloaded_video_ids.set(video_id, 0)
	else:
		info.set("is_duplicate_video_id", false)
	info.set("file_exists", true)
	
	if summary.has(id):
		print("ID %s already processed" % id)
		Global.logs_display.write("ID: %s 's song file is duplicated. Ignoring this one as it has already been treated" % id, LogsDisplay.MESSAGE.ERROR)
	summary.set(id, info)
	#print("process finished")

func process_from_song_info(id: String):
	#print("processing %s" % id)
	var info: Dictionary = {}
	var song_info: Dictionary = Global.song_infos.get(id)
	if song_info:
		info.set("has_song_info", true)
	else:
		info.set("has_song_info", false)
	info.set("has_artist", true if song_info.get("artist", "") != "" else false)
	#info.set("has_artist", false)
	info.set("has_display_name", true if song_info.get("display_name", "") != "" else false)
	info.set("has_extension", true if song_info.get("extension", "") != "" else false)
	info.set("has_release_date", true if song_info.get("release_date", "") != "" else false)
	info.set("has_thumbnail_path", true if song_info.get("thumbnail_path", "") != "" else false)
	var video_id = song_info.get("video_id", "")
	info.set("has_video_id", true if video_id != "" else false)
	
	if video_id != "":
		info.set("is_duplicate_video_id", video_id in already_downloaded_video_ids) ## if two are the same, only flag the second one. CHANGE DOWNLOADED_SONGS video_id : id TO STORE AND FIX
		if not already_downloaded_video_ids.has(video_id):
			already_downloaded_video_ids.set(video_id, 0)
	else:
		info.set("is_duplicate_video_id", false)
	
	info.set("file_exists", FileAccess.file_exists(Tools.get_full_path_from_id(id)))
	
	
	summary.set(id, info)
	#print("process finished")


func display_data(data: Dictionary):
	if not is_open:
		open()
	
	last_clicked_local_id = ""
	
	# adds missing headers if necessary:
	if data.values() == []:
		push_error("data.values() == [], no display")
		return
	for key in data.values()[0].keys():
		if not key in header:
			push_error(key, " was missing in the header")
			header.append(key)
	
	var data_array: Array[Array] = Tools.from_dict_data_to_array(data, header)
	#var row: Array = []
	
	#var infos = data.values()
	#for info in infos:
		#row = []
		#for info_name in header:
			#row.append(info.get(info_name))
		#data_array.append(row)
	
	
	#print(data_array)
	#data_array = [
		#[1, 2, 3, 4, 5, 6, 7, 8, 9],
		#[1, 8, 3, 4, 4, 5, 7, 7, 9]
	#]
	table.set_table(data_array)


func _update_info_selected() -> void:
	if last_clicked_local_id == "":
		print("No row selected.")
		return
	var song_info: Dictionary = Global.song_infos.get(last_clicked_local_id, {})
	if song_info:
		var youtube_id: String = song_info.get("video_id", "")
		if youtube_id:
			SongManager.update_infos(youtube_id, do_checkup) ## TODO CHANGE ONLY THE SELECTED LINE (also bc it changed where we were looking)

func _on_table_click_row(row: Array) -> void:
	print(table.get_local_mouse_position())
	last_clicked_local_id = row[0]
	context_menu.force_show_item(table)





#
