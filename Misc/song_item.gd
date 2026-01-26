extends Panel
class_name SongItemOLD


#@onready var color_rect: ColorRect = $ColorRect

#@onready var default_color: Color = color_rect.color
@onready var highlight_color: Color

@onready var default_modulate_v: float = modulate.v



@onready var song_name: Label = %SongName
@onready var artist: Label = %Artist
@onready var thumbnail: TextureRect = %Thumbnail


var hovered: bool = false
var infos: Dictionary = {}
var id: String = "":
	set(new_id):
		id = new_id
		initialize.call_deferred()
var location: String = ""
var index: int = 0

var context_menu: ContextMenu


var _loading_thumbnail: String = ""


func _ready() -> void:
	#highlight_color = default_color
	highlight_color.v += 0.05
	
	#initialize_context_menu()
	
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	
func initialize():
	print("initializing song item.. : ", id)
	
	Global.logs_display.write("initializing song item... ID: %s " % id)
	tooltip_text = "ID: " + id
	infos = Global.song_infos.get(id, {})
	song_name.text = infos.get("display_name", "") + "          " + id
	
	load_thumbnail()
	

func initialize_context_menu():
	context_menu = ContextMenu.new()
	context_menu.attach_to(self)
	context_menu.set_minimum_size(Vector2i(400, 0))
	context_menu.add_item("Infos", Callable(self, "_show_infos"), false, null)
	context_menu.add_item("Delete", Callable(self, "_delete"), false, null)
	#context_menu.add_checkbox_item("Enable third Button", Callable(self, "_enableThirdButton"), false, false, null)
	context_menu.add_placeholder_item("Disabled", true, null)
	context_menu.add_seperator()
	var subMenu : ContextMenu = context_menu.add_submenu("Submenu")
	subMenu.add_item("Run the Submenu Test", Callable(self, "_runTest"), false, null)
	
	context_menu.connect_to(self)

func _show_infos() -> void:
	print("show infos")

func _delete() -> void:
	Global.delete_song(id)
	
	match location:
		"current_playlist":
			#_on_clicked_in_current_playlist()
			Global.current_playlist.reload_song_items()
		"downloads":
			Global.downloads_tab.reload_song_items()
		_:
			pass

func load_thumbnail() -> void:
	#request_thumbnail_later()
	#return
	
	var thumbnail_path: String = Global.get_thumbnail_path(id)
	if thumbnail_path == "":
		return
	
	if not FileAccess.file_exists(thumbnail_path):
		#print("song_item > load_thumbnail, no thumbnail path provided and this path doesn't work neither: ", full_path)
		Global.logs_display.write("song_item > load_thumbnail, no thumbnail path provided and this path doesn't work neither: %s" % thumbnail_path, LogsDisplay.MESSAGE.ERROR)
		return
	
	var image := Image.new()
	var error = image.load(thumbnail_path)
	# TODO W 0:02:39:139   song_item.gd:89 @ load_thumbnail(): Loaded resource as image file, this will not work on export: 'res://downloads/z.webp'. Instead, import the image file as an Image resource and load it normally as a resource.

	if error != OK:
		#push_error("song_item > load_thumbnail, error when loading the thumbnail. Full path: %s, Error: %s" % [full_path, error])
		Global.logs_display.write("song_item > load_thumbnail, error when loading the thumbnail. Full path: %s, Error: %s" % [thumbnail_path, error], LogsDisplay.MESSAGE.ERROR)
		return
	
	var texture := ImageTexture.create_from_image(image)
	thumbnail.texture = texture

#func request_thumbnail_later() -> void:
	## Marquer qu'on veut un thumbnail
	#var thumbnail_path: String = Global.get_thumbnail_path(id)
	#if thumbnail_path == "":
		#return
	## Si le fichier existe probablement
	#if ResourceLoader.exists(thumbnail_path):
		## Charger asynchrone
		#_loading_thumbnail = thumbnail_path
		#ResourceLoader.load_threaded_request(thumbnail_path)
		

#func _process(delta: float) -> void:
	#if _loading_thumbnail == "":
		#return
	#var status = ResourceLoader.load_threaded_get_status(_loading_thumbnail)
	#if status == ResourceLoader.THREAD_LOAD_LOADED:
		#var image := Image.new()
		#var error = image.load(_loading_thumbnail)
		## TODO W 0:02:39:139   song_item.gd:89 @ load_thumbnail(): Loaded resource as image file, this will not work on export: 'res://downloads/z.webp'. Instead, import the image file as an Image resource and load it normally as a resource.
#
		#if error != OK:
			##push_error("song_item > load_thumbnail, error when loading the thumbnail. Full path: %s, Error: %s" % [full_path, error])
			#Global.logs_display.write("song_item > load_thumbnail, error when loading the thumbnail. Full path: %s, Error: %s" % [_loading_thumbnail, error], LogsDisplay.MESSAGE.ERROR)
			#return
		#
		#var texture := ImageTexture.create_from_image(image)
		#thumbnail.texture = texture

func _on_gui_input(event: InputEvent):
	#if not visible:
		#print("not visible")
	#if not hovered:
		#print("not hovered")
	#if not visible or not hovered:
		#return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			match location:
				"current_playlist":
					#_on_clicked_in_current_playlist()
					SongManager.play_from_index(index)
				_:
					SongManager.add_to_current_playlist(id)

func _on_mouse_entered():
	self_modulate.v = default_modulate_v + 0.1
	hovered = true
	#color_rect.color = highlight_color

func _on_mouse_exited():
	self_modulate.v = default_modulate_v
	hovered = false
	#color_rect.color = default_color
