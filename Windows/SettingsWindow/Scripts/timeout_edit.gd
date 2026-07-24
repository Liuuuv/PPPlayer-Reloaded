extends HBoxContainer

@onready var timeout_slider: HSlider = %TimeoutSlider
@onready var timeout_seconds: Label = %TimeoutSeconds


func _ready() -> void:
	timeout_slider.value_changed.connect(_on_timeout_slider_value_changed)
	
	_initialize.call_deferred()

func _initialize() -> void:
	timeout_slider.value = Global.settings.get("timeout_duration", 80.0)

func _on_timeout_slider_value_changed(value: float):
	Config.timeout_duration = value
	timeout_seconds.text = "%ds" % int(value)
	Global.change_settings("timeout_duration", value)
