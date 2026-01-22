extends Control
class_name LogsDisplay

func _ready() -> void:
	Global.logs_display = self

func open():
	show()
