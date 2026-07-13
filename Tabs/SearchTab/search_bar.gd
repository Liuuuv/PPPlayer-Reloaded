extends LineEdit

func _ready() -> void:
	text_submitted.connect(_on_text_submitted)

func _on_text_submitted(new_text: String) -> void:
	print("new_text ", new_text)
