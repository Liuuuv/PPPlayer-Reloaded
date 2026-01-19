extends ProgressSlider


func _ready() -> void:
	value = 0.0
	SongManager.has_stream_changed.connect(_on_has_stream_changed)

func _on_has_stream_changed():
	if SongManager.has_stream:
		editable = true
	else:
		editable = false
