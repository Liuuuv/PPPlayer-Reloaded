extends Window
class_name ListWindow

const line_scene = preload("res://Windows/ListWindow/line.tscn")

@onready var lines_container: VBoxContainer = %LinesContainer

var is_open: bool = false


func _ready() -> void:
	if is_open:
		open()
	else:
		close()
	
	Global.list_window = self
	
	for child in lines_container.get_children():
		child.queue_free()
	
	close_requested.connect(_on_close_requested)

func display_lines(lines: Array, window_title: String, exclude_keys: Array[String]) -> void: # lines: [{title: title},]
	title = window_title
	for line in lines:
		var line_scene = line_scene.instantiate()
		lines_container.add_child(line_scene)
		line_scene.display(line, exclude_keys)
	
	open()

func open():
	show()
	is_open = true

func close():
	hide()
	is_open = false

func _on_close_requested():
	close()





#
