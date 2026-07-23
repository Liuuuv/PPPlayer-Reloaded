extends Window
class_name InfoWindow


@onready var lines_container: VBoxContainer = %LinesContainer
@onready var title_template: String = title

var is_open: bool = false
var id_infos_displayed: String = ""

#var header: Array[String] = [
	#"id",
	#"has_song_info",
	#"has_artist",
	#"has_display_name",
	#"has_extension",
	#"has_release_date",
	#"has_thumbnail_path",
	#"has_video_id",
	#"is_duplicate_video_id",
#]


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
	
	for child: Control in lines_container.get_children():
		var edit_button: Button = child.get_node("EditButton")
		edit_button.toggled.connect(func(on: bool): _edit_line_toggled(child, on))
	
	close_requested.connect(_on_close_requested)

func display_info(id: String):
	
	var song_info: Dictionary = Global.song_infos.get(id, {})
	id_infos_displayed = id
	title = title_template % id
	if song_info:
		for child: Control in lines_container.get_children():
			var text_edit: TextEdit = child.get_node("TextEdit")
			text_edit.text = str(song_info.get(child.name, ""))
	else:
		push_error("No song_info for ID: %s" % id)
		for child: Control in lines_container.get_children():
			var text_edit: TextEdit = child.get_node("TextEdit")
			text_edit.text = "No song_info for this ID."
			
	
	open()

func _edit_line_toggled(line: Control, toggled_on: bool):
	var text_edit: TextEdit = line.get_node("TextEdit")
	text_edit.editable = toggled_on
	
	var edit_button: Button = line.get_node("EditButton")
	edit_button.text = "Done" if toggled_on else "Edit"
	
	## saves changes
	if not toggled_on:
		if id_infos_displayed != "":
			var song_info = Global.song_infos.get(id_infos_displayed)
			if song_info:
				song_info.set(line.name, text_edit.text)
				Global.logs_display.write("Changed song info for ID: %s. Property: %s, new value: %s" % [id_infos_displayed, line.name, text_edit.text])
				Global.save_song_infos()
			else:
				Global.logs_display.write("No song info found for ID: %s" % id_infos_displayed, LogsDisplay.MESSAGE.ERROR)
		else:
			Global.logs_display.write("Changes are discarded because the info window was closed", LogsDisplay.MESSAGE.ERROR)
		
	print(line.get_node("Label").text, " edited toggled ", toggled_on)

func open():
	show()
	is_open = true

func close():
	hide()
	is_open = false
	id_infos_displayed = ""

func _on_close_requested():
	close()
