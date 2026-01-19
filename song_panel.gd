extends VBoxContainer
class_name SongPanel

@onready var progress_slider: ProgressSlider = %ProgressSlider
@onready var progress_slider_bg: ProgressSlider = %ProgressSliderBG
@onready var song_label: RichTextLabel = %SongLabel

func _ready() -> void:
	Global.song_panel = self
	
	#$RichTextLabel.text = "[i]Untitled[/i]"
