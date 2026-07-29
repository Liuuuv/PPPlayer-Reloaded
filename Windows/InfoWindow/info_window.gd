extends BaseWindow
class_name InfoWindow


@onready var lines_container: VBoxContainer = %LinesContainer
@onready var title_template: String = title

@onready var bg_texture_rect: TextureRect = %BGTextureRect

@onready var thumbnail_from_clipboard_button: ButtonComponent = %ThumbnailFromClipboardButton
@onready var confirm_thumbnail_from_clipboard_button: ButtonComponent = %ConfirmThumbnailFromClipboardButton
@onready var clipboard_thumbnail_container: PanelContainer = %ClipboardThumbnailContainer
@onready var clipboard_thumbnail_rect: TextureRect = %ClipboardThumbnailRect




var id_infos_displayed: String = ""
var types_displayed: Dictionary = {} ## {property_name: TYPE_} # TYPE_NIL gets uneditable
var current_thumbnail_clipboard_image: Image

func _ready() -> void:
	super()
	Global.info_window = self
	
	for child: Control in lines_container.get_children():
		var edit_button: Button = child.get_node("EditButton")
		edit_button.toggled.connect(func(on: bool): _edit_line_toggled(child, on))
	
	thumbnail_from_clipboard_button.pressed.connect(_on_thumbnail_from_clipboard_button_pressed)
	confirm_thumbnail_from_clipboard_button.pressed.connect(_on_confirm_thumbnail_from_clipboard_button_pressed)

func display_info(id: String):
	types_displayed.clear()
	bg_texture_rect.texture = CacheManager.get_cached_thumbnail(id)
	
	var song_info: Dictionary = Global.song_infos.get(id, {})
	id_infos_displayed = id
	title = title_template % id
	
	if song_info:
		for child: Control in lines_container.get_children():
			var line_edit: LineEdit = child.get_node("LineEdit")
			var edit_button: Button = child.get_node("EditButton")
			edit_button.disabled = false
			
			var value: Variant = song_info.get(child.name)
			
			match typeof(value):
				TYPE_STRING:
					line_edit.text = value
					types_displayed.set(child.name, TYPE_STRING)
				TYPE_ARRAY:
					line_edit.text = str(value)
					types_displayed.set(child.name, TYPE_ARRAY)
				TYPE_NIL:
					line_edit.text = "Value is null"
					edit_button.disabled = true
				_:
					line_edit.text = str(value)
					types_displayed.set(child.name, TYPE_NIL)
	else:
		push_error("No song_info for ID: %s" % id)
		for child: Control in lines_container.get_children():
			var line_edit: LineEdit = child.get_node("LineEdit")
			line_edit.text = "No song_info for this ID."
			
	
	open()

func _edit_line_toggled(line: Control, toggled_on: bool):
	var line_edit: LineEdit = line.get_node("LineEdit")
	line_edit.editable = toggled_on
	
	var edit_button: Button = line.get_node("EditButton")
	edit_button.text = "Done" if toggled_on else "Edit"
	
	## saves changes
	if not toggled_on:
		if id_infos_displayed != "":
			var song_info = Global.song_infos.get(id_infos_displayed)
			if song_info:
				match types_displayed.get(line.name):
					TYPE_STRING:
						song_info.set(line.name, line_edit.text)
					TYPE_ARRAY:
						var new_value: Array = JSON.parse_string(line_edit.text)
						if new_value != null:
							print(new_value, " ", typeof(new_value))
							#song_info.set(line.name, line_edit.text)
						else:
							push_error("The new value is parsed as null instead of an Array.")
					TYPE_NIL:
						print("Type is null, can't save anything")
						return
				
				Global.logs_display.write("Changed song info for ID: %s. Property: %s, new value: %s" % [id_infos_displayed, line.name, line_edit.text])
				Global.save_song_infos()
			else:
				Global.logs_display.write("No song info found for ID: %s" % id_infos_displayed, LogsDisplay.MESSAGE.ERROR)
		else:
			Global.logs_display.write("Changes are discarded because the info window was closed", LogsDisplay.MESSAGE.ERROR)

func close():
	super()
	id_infos_displayed = ""
	confirm_thumbnail_from_clipboard_button.hide()
	clipboard_thumbnail_container.hide()
	current_thumbnail_clipboard_image = null

func _on_thumbnail_from_clipboard_button_pressed() -> void:
	if DisplayServer.clipboard_has_image():
		current_thumbnail_clipboard_image = DisplayServer.clipboard_get_image()
		if current_thumbnail_clipboard_image:
			confirm_thumbnail_from_clipboard_button.show()
			clipboard_thumbnail_container.show()
			clipboard_thumbnail_rect.texture = ImageTexture.create_from_image(current_thumbnail_clipboard_image)
		else:
			confirm_thumbnail_from_clipboard_button.hide()
			clipboard_thumbnail_container.hide()

func _on_confirm_thumbnail_from_clipboard_button_pressed() -> void:
	if current_thumbnail_clipboard_image:
		current_thumbnail_clipboard_image.save_webp(Global.get_downloads_path() + id_infos_displayed + ".webp")
		print("Saved the new thumbnail of local ID: %s" % id_infos_displayed)





#
