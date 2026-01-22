extends ConfirmationDialog

@onready var extra_infos_label: RichTextLabel = %ExtraInfos

signal closing_window()

var ok: bool = false ## true if and only if user clicked "OK"

func _ready() -> void:
	Global.confirmation_dialog = self
	
	confirmed.connect(_on_confirmed)
	close_requested.connect(_on_close_request)
	#focus_exited.connect(_on_close_request)
	#canceled.connect(_on_close_request)

func ask_for_confirmation(custom_title: String = "Please confirm", extra_infos: String = ""):
	ok = false
	title = custom_title
	extra_infos_label.text = extra_infos
	show()
	await closing_window
	print("ok ", ok)
	return ok

func close_window() -> void:
	closing_window.emit()
	hide()

func _on_confirmed():
	print("_on_confirmed")
	ok = true
	closing_window.emit()

func _on_close_request():
	print("_on_close_request")
	close_window()
