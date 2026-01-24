extends Panel
class_name DownloadItem


@onready var color_rect: ColorRect = $ColorRect

@onready var default_color: Color = color_rect.color
@onready var highlight_color: Color

@onready var default_modulate_v: float = modulate.v



@onready var song_name: Label = %SongName
#@onready var artist: Label = %Artist


var hovered: bool = false
var infos: Dictionary = {}
var id: String = "":
	set(new_id):
		id = new_id
		initialize.call_deferred()
var location: String = ""
var index: int = 0

func _ready() -> void:
	highlight_color = default_color
	highlight_color.v += 0.05
	
	
	#gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func initialize():
	#print("initializing song item.. : ", id)
	Global.logs_display.write("Initializing download item... videoID: %s" % id)
	tooltip_text = "videoID: " + id
	song_name.text = id
	#infos = Global.song_infos.get(id, {})
	#song_name.text = infos.get("name", "")

#func _on_gui_input(event: InputEvent):
	#if not visible or not hovered:
		#return
	#if event is InputEventMouseButton and event.pressed:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#match location:
				#"current_playlist":
					##_on_clicked_in_current_playlist()
					#SongManager.play_from_index(index)
				#_:
					#SongManager.add_to_current_playlist(id)
					

#func _on_clicked_in_current_playlist():
	#
	#
	#var song_info = Global.song_infos.get(id)
	#if song_info:
		#var extension = song_info.get("extension")
		#if extension:
			#var full_path = Global.get_downloads_path() + id + "." + extension
			##SongManager.start_song(full_path)
			#SongManager.add_to_current_playlist(id)

func _on_mouse_entered():
	self_modulate.v = default_modulate_v + 0.1
	hovered = true
	#color_rect.color = highlight_color

func _on_mouse_exited():
	self_modulate.v = default_modulate_v
	hovered = false
	#color_rect.color = default_color
