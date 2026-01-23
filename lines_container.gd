extends VBoxContainer

func _ready() -> void:
	clear()

func clear() -> void:
	for child in get_children():
		child.queue_free()
