extends Window
class_name SummaryWindow

@onready var table: Table = $Table

var is_open: bool = false

var header: Array[String] = ["id", "has_song_info", "has_artist", "has_display_name", "has_extension", "has_release_date", "has_thumbnail_path", "has_video_id", "is_duplicate_video_id"]




var data: Dictionary = {
	"0": {
		"test": "oui",
		"mais": 1,
		"omg": false,
		"oui par contRE": true
	},
	"1": {
		"test": "NAH",
		"mais": 5,
		"omg": true,
		"oui par contRE": true
	}
}

func _ready() -> void:
	if is_open:
		open()
	else:
		close()
	
	Global.summary_window = self
	table.header_row = header
	
	close_requested.connect(_on_close_requested)

func display_data(data: Dictionary):
	if not is_open:
		open()
	
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
	#table.reload_table()

func open():
	show()
	is_open = true

func close():
	hide()
	is_open = false

func _on_close_requested():
	close()
