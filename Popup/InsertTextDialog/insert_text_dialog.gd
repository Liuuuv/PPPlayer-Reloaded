extends Window
class_name InsertTextDialog

signal closing_window()

@onready var text_edit: TextEdit = %TextEdit
@onready var confirm_button: Button = %Confirm

var inserted_text: String = ""

func _ready() -> void:
	Global.insert_text_dialog = self
	
	close_requested.connect(_on_close_request)
	confirm_button.confirm.connect(_on_confirm)

#func _physics_process(delta: float) -> void:
	#print(text_edit.text)

func ask_for_text(placeholder_text: String = ""):
	inserted_text = ""
	text_edit.placeholder_text = placeholder_text
	show()
	await closing_window
	inserted_text = text_edit.text
	return inserted_text

func close_window() -> void:
	closing_window.emit()
	hide()
	text_edit.text = ""

func _on_confirm():
	close_window()

func _on_close_request():
	close_window()
