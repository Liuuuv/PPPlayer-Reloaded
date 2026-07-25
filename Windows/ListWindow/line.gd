@tool
extends PanelContainer

enum TYPE {
	LABEL_CHOOSE,
	LABEL_INFO,
}

@export var type: TYPE = TYPE.LABEL_CHOOSE:
	set(new_type):
		type = new_type
		for child in get_children():
			if child.name == TYPE.keys().get(type):
				child.show()
			else:
				child.hide()
		_setup()

@onready var label: Label = %Label
@onready var choose_button: Button = %ChooseButton

func _ready() -> void:
	pass

func display(line: Dictionary, exclude_keys: Array[String]) -> void:
	label.text = ""
	for key in line.keys():
		if key in exclude_keys:
			continue
		label.text += "%s: %s" % [key, line.get(key)]
		label.text += "\n"

#func display(property_name: String, property_value: String = "") -> void:
	#if property_value == "":
		#label.text = property_name + "\\n"
	#else:
		#label.text = "%s: %s" % [property_name, property_value] + "\\n"

func _setup() -> void:
	match type:
		TYPE.LABEL_CHOOSE:
			pass
		TYPE.LABEL_INFO:
			pass
