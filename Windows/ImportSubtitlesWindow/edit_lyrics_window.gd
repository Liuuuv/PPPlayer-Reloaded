extends BaseWindow
class_name EditLyricsWindow

signal closing(song_id: String)

@onready var main_part: HBoxContainer = %MainPart
@onready var no_id: Label = %NoID

@onready var confirm_button: Button = %ConfirmButton
@onready var line_edit: LineEdit = %LineEdit
@onready var text_edit: TextEdit = %TextEdit
@onready var save_button: Button = %SaveButton
@onready var option_button: OptionButton = %OptionButton

var saved: bool = true
var song_id: String = ""

## can be changed by user (todo: put this in a json)
var lyrics_websites: Dictionary = {
	"Genius (genius.com)": {
		'icon': preload("res://Sprites/Logos/GeniusLogo.png"),
		'config': ProjectSettings.globalize_path("res://genius_scrap_config.json"),
	},
	"UtaNet": {
		'icon': null,
		'config': ProjectSettings.globalize_path("res://utanet_lyrics_scrap.json"),
	}
}

var idx_to_config: Dictionary = {}

func _ready() -> void:
	super._ready()
	Global.edit_lyrics_window = self
	
	var idx: int = 0
	for website_name in lyrics_websites.keys():
		option_button.add_icon_item(lyrics_websites.get(website_name).get('icon'), website_name)
		idx_to_config.set(idx, lyrics_websites.get(website_name).get('config', ""))
		idx +=1
	
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	text_edit.text_changed.connect(_on_lyrics_changed)

func display_lyrics(id: String) -> void:
	if id == "":
		main_part.hide()
		no_id.show()
	else:
		main_part.show()
		no_id.hide()
	song_id = id
	
	text_edit.text = Global.lyrics.get(song_id, "")
	
	open()

func _process_genius_result(result: Array):
	text_edit.text = ""
	for dict in result:
		text_edit.text += dict.get("lyrics")
	saved = false

func _on_confirm_button_pressed() -> void:
	if line_edit.text != "":
		var html_config_path: String = idx_to_config.get(option_button.selected)
		if html_config_path == "":
			push_error("no html_config_path provided :c")
			return
		Scrapper.set_scrap_config(html_config_path)
		Scrapper.process_generic(line_edit.text, _process_genius_result, true)
	else:
		push_error("At least enter something...")

func _on_save_button_pressed() -> void:
	Global.lyrics.set(song_id, text_edit.text)
	Global.save_lyrics()
	saved = true
	print("lyrics saved!")

func _on_close_requested():
	if not saved:
		var confirm: bool = await Global.confirmation_dialog.ask_for_confirmation("Changed  not saved", "Changed are NOT saved and will be DISCARDED")
		if not confirm:
			return
	
	closing.emit(song_id)
	song_id = ""
	super._on_close_requested()

func _on_lyrics_changed():
	saved = false





#
	
