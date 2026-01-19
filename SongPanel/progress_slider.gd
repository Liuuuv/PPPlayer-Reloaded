extends HSlider
class_name ProgressSlider

var is_dragging: bool = false

func _ready() -> void:
	value = 0.0
	
	drag_started.connect(_on_drag_started)
	drag_ended.connect(_on_drag_ended)
	
	SongManager.has_stream_changed.connect(_on_has_stream_changed)
	
func _on_drag_started():
	is_dragging = true

func _on_drag_ended(value_changed: bool):
	is_dragging = false
	if value_changed:
		SongManager.change_song_progression(value)

func _on_has_stream_changed():
	if SongManager.has_stream:
		editable = true
	else:
		editable = false
