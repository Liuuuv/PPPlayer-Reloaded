extends Label

var num_downloading_songs: int = 0
var tween: Tween

func _ready() -> void:
	update_count.call_deferred()
	
	Global.downloads_tab.queue_changed.connect(_on_downloads_tab_queue_changed)
#
func update_count():
	num_downloading_songs = Global.downloads_tab.downloading_queue.size()
	text = str(num_downloading_songs)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			update_count()
			
			if tween:
				tween.kill()
			tween = create_tween()
			self_modulate.v = 0.2
			tween.tween_property(self, "self_modulate:v" , 1.0, 0.5)

func _on_downloads_tab_queue_changed():
	update_count()
