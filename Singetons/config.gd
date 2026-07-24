extends Node

const APP_VERSION: String = "0.1"

var disable_logs: bool = false ## changed in UI
#var disable_logs: bool = true

var audio_format: YtDlp.Audio = YtDlp.Audio.MP3
var default_audio_format_string: String = ""

var enable_memory_cache_for_results: bool = false
var enable_memory_cache_for_local: bool = true

var timeout_duration: float = 20.0 ## changed in UI

func _ready() -> void:
	match audio_format:
		YtDlp.Audio.MP3: default_audio_format_string = "mp3"
