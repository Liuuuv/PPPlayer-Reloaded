extends VBoxContainer
class_name SongPanel



@onready var progress_slider: ProgressSlider = %ProgressSlider
@onready var progress_slider_bg: ProgressSlider = %ProgressSliderBG
@onready var song_label: RichTextLabel = %SongLabel

@onready var volume_slider: HSlider = %VolumeSlider
@onready var volume_offset_slider: HSlider = %VolumeOffsetSlider
@onready var time_label: Label = %TimeLabel
@onready var like_button: Button = %LikeButton

@onready var reset_volume_offset_button: Button = %ResetVolumeOffsetButton


var main_volume: float = 20.0 ## from 0.0 to 100.0
var volume_offset: float = 20.0 ## from -100.0 to 100.0

func _ready() -> void:
	Global.song_panel = self
	_initialize.call_deferred()
	
	#$RichTextLabel.text = "[i]Untitled[/i]"
	volume_slider.value = main_volume
	time_label.text = ""
	
	reset_volume_offset_button.pressed.connect(_on_reset_volume_offset_button_pressed)
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	volume_offset_slider.value_changed.connect(_on_volume_offset_slider_value_changed)
	volume_offset_slider.drag_ended.connect(_on_volume_offset_slider_drag_ended)
	
	like_button.toggled.connect(_on_like_button_toggled)

func _initialize() -> void:
	Global.music_player.stream_changed.connect(_on_stream_changed)

func _update_offset_song_preferences() -> void:
	var song_preference: Dictionary = Global.song_preferences.get(Global.music_player.current_stream_id, {})
	if song_preference == {}:
		Global.song_preferences.set(Global.music_player.current_stream_id, {})
		song_preference = Global.song_preferences.get(Global.music_player.current_stream_id, {})
	song_preference.set("volume_offset", volume_offset)
	Global.save_song_preferences()

func _on_volume_slider_value_changed(value: float):
	main_volume = value

func _on_volume_offset_slider_value_changed(value: float):
	volume_offset = value

func _on_volume_offset_slider_drag_ended(value_changed: bool) -> void:
	_update_offset_song_preferences()

func _on_reset_volume_offset_button_pressed() -> void:
	volume_offset_slider.value = 0.0
	_update_offset_song_preferences()

func _on_stream_changed(fullpath: String) -> void:
	if fullpath == "":
		volume_offset_slider.editable = false
		reset_volume_offset_button.disabled = true
		like_button.disabled = true
		return
	else:
		volume_offset_slider.editable = true
		reset_volume_offset_button.disabled = false
		like_button.disabled = false
	var song_preference: Dictionary = Global.song_preferences.get(Global.music_player.current_stream_id, {})
	volume_offset_slider.value = song_preference.get("volume_offset", 0.0)
	like_button.button_pressed = song_preference.get("like", false)

func _on_like_button_toggled(toggled_on: bool) -> void:
	if Global.music_player.current_stream_id != "":
		if not Global.song_preferences.has(Global.music_player.current_stream_id):
			Global.song_preferences.set(Global.music_player.current_stream_id, {})
		var song_preference: Dictionary = Global.song_preferences.get(Global.music_player.current_stream_id, {})
		song_preference.set("like", toggled_on)
		Global.save_song_preferences()
		



#
