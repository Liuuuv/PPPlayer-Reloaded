extends Control
class_name BasePage

signal info_requested()
signal info_displayed()

@onready var default_position: Vector2 = position

func _ready() -> void:
	pass

func open():
	show()
	
	
	var screen_size: Vector2i = DisplayServer.screen_get_size(DisplayServer.SCREEN_OF_MAIN_WINDOW)
	position.y = float(screen_size.y)
	
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", default_position.y, 0.2)
	
	
	await tween.finished
	#await get_tree().create_timer(1.0).timeout
	#hide()

func close():
	hide()

#
