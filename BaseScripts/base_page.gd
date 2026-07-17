extends Control
class_name BasePage

signal info_requested()
signal info_displayed()

#@export var cache_template: Global.CACHE_TEMPLATES

@onready var close_button: Button = get_node_or_null("CloseButton")

@onready var default_position: Vector2 = position

var current_display_id: String = ""

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	#print(Global.get(Global.CACHE_TEMPLATES.keys()[cache_template]))

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


func _on_close_button_pressed() -> void:
	current_display_id = ""
	close()













#
