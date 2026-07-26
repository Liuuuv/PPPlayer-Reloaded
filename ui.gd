extends Control
class_name RootUI

@onready var debug_ver_label: Label = %DebugVerLabel

## Loading overlay
@onready var loading_overlay: Control = %LoadingOverlay
@onready var loading_logo: ColorRect = %LoadingLogo
@onready var loading_info: Label = %LoadingInfo

func _ready() -> void:
	Global.root_ui = self
	loading_overlay.hide()
	_initialize.call_deferred()

func _initialize():
	if Global.is_in_editor:
		debug_ver_label.show()
	else:
		debug_ver_label.hide()
