extends Control
class_name BasePage

signal info_requested()
signal info_displayed()

#@export var cache_template: Global.CACHE_TEMPLATES

@onready var close_button: Button = %CloseButton if has_node("%CloseButton") else null
@onready var reload_button: Button = %ReloadButton if has_node("%ReloadButton") else null

@onready var loading_overlay: Control = %LoadingOverlay
@onready var loading_logo: ColorRect = %LoadingLogo
@onready var loading_info: Label = %LoadingInfo

@onready var default_position: Vector2 = position

var current_display_id: String = ""

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	
	if reload_button:
		reload_button.pressed.connect(_on_reload_button_pressed)
		
	
	hide_loading_overlay()
	
	_initialize.call_deferred()

func _initialize() -> void:
	pass

func open():
	if Global.active_page and Global.active_page != self:
		Global.active_page.close()
	if Global.main_tab_container.current_tab != 0:
		Global.main_tab_container.current_tab = 0
		
	
	Global.active_page = self
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
	Global.active_page = null
	hide()
	var screen_size: Vector2i = DisplayServer.screen_get_size(DisplayServer.SCREEN_OF_MAIN_WINDOW)
	position.y = float(screen_size.y)


func _on_close_button_pressed() -> void:
	current_display_id = ""
	close()

func _on_reload_button_pressed() -> void:
	pass

func show_loading_overlay() -> void:
	loading_overlay.show()

func hide_loading_overlay() -> void:
	loading_overlay.hide()









#
