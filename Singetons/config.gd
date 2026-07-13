extends Node

var disable_logs: bool = false
#var disable_logs: bool = true

var audio_format: YtDlp.Audio = YtDlp.Audio.MP3
var default_audio_format_string: String = ""

func _ready() -> void:
	match audio_format:
		YtDlp.Audio.MP3: default_audio_format_string = "mp3"
