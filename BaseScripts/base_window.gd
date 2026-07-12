extends Window
class_name BaseWindow



var is_open: bool = false

func _ready() -> void:
	if is_open:
		open()
	else:
		close()
	
	close_requested.connect(_on_close_requested)


func open():
	show()
	is_open = true

func close():
	hide()
	is_open = false

func _on_close_requested():
	close()
