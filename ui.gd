extends Control

@onready var debug_ver_label: Label = %DebugVerLabel

func _ready() -> void:
	_initialize.call_deferred()

func _initialize():
	if Global.is_in_editor:
		debug_ver_label.show()
	else:
		debug_ver_label.hide()
