extends Node

const APP_VERSION: String = "0.1"

var disable_logs: bool = false
#var disable_logs: bool = true

var audio_format: YtDlp.Audio = YtDlp.Audio.MP3
var default_audio_format_string: String = ""

var enable_memory_cache_for_results: bool = false
var enable_memory_cache_for_local: bool = true

func _ready() -> void:
	match audio_format:
		YtDlp.Audio.MP3: default_audio_format_string = "mp3"
