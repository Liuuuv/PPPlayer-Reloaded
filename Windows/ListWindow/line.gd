extends PanelContainer

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
