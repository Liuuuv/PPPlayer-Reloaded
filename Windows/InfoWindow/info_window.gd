extends Window
class_name InfoWindow


@export var lines_container: VBoxContainer

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
	
	Global.info_window = self
	
	close_requested.connect(_on_close_requested)

func display_info(id: String):
	
	var song_info: Dictionary = Global.song_infos.get(id)
	if song_info:
		for child: Control in lines_container.get_children():
			var text_edit: TextEdit = child.get_node("TextEdit")
			text_edit.text = str(song_info.get(child.name, ""))
	else:
		push_error("No song_info for id %s" % id)
	
	open()


func open():
	show()
	is_open = true

func close():
	hide()
	is_open = false

func _on_close_requested():
	close()
