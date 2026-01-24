extends Window
class_name LogsDisplay

@onready var logs: RichTextLabel = %Logs
@onready var clear_logs_button: ButtonComponent = %ClearLogsButton


enum MESSAGE {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
}

var is_open: bool = false


func _ready() -> void:
	Global.logs_display = self
	
	logs.text = Tools.load_string(Global.LOGS_PATH)
	var time_dict: Dictionary = Time.get_datetime_dict_from_system()
	logs.text += "\n [color=purple][START SESSION][/color] %s/%s/%s, %s:%s:%s %s DST \n" % [
		time_dict.get("year", ""),
		time_dict.get("month", ""),
		time_dict.get("day", ""),
		time_dict.get("hour", ""),
		time_dict.get("minute", ""),
		time_dict.get("second", ""),
		"" if time_dict.get("dst") else "no"
	]
	Tools.save_string(logs.text, Global.LOGS_PATH)
	
	clear_logs_button.clear_logs.connect(_on_clear_logs)
	close_requested.connect(_on_close_requested)


func open():
	is_open = true
	show()
	
func close():
	is_open = false
	hide()

func write(message, type: MESSAGE = MESSAGE.DEBUG):
	_write.call_deferred(message, type)
	
func _write(message, type: MESSAGE = MESSAGE.DEBUG):
	return ## TEMP
	var type_message: String = ""
	match type:
		MESSAGE.DEBUG:
			type_message = "[color=white][DEBUG][/color] "
		MESSAGE.INFO:
			type_message = "[color=cyan][INFO][/color] "
		MESSAGE.WARNING:
			type_message = "[color=yellow][WARNING][/color] "
		MESSAGE.ERROR:
			type_message = "[color=red][ERROR][/color] "
	logs.text += type_message + message + "\n"
	Tools.save_string(logs.text, Global.LOGS_PATH)

func _on_close_requested():
	close()

func _on_clear_logs():
	var confirm: bool =  await Global.confirmation_dialog.ask_for_confirmation("Confirm", "Are you sure to delete the logs?")
	if confirm:
		var time_dict: Dictionary = Time.get_datetime_dict_from_system()
		logs.text = "\n [color=purple][START SESSION (RESET)][/color] %s/%s/%s, %s:%s:%s %s DST \n" % [
			time_dict.get("year", ""),
			time_dict.get("month", ""),
			time_dict.get("day", ""),
			time_dict.get("hour", ""),
			time_dict.get("minute", ""),
			time_dict.get("second", ""),
			"" if time_dict.get("dst") else "no"
		]
		Tools.save_string(logs.text, Global.LOGS_PATH)

func _exit_tree() -> void:
	var time_dict: Dictionary = Time.get_datetime_dict_from_system()
	logs.text += "[color=purple][END SESSION][/color] %s/%s/%s, %s:%s:%s %s DST \n" % [
		time_dict.get("year", ""),
		time_dict.get("month", ""),
		time_dict.get("day", ""),
		time_dict.get("hour", ""),
		time_dict.get("minute", ""),
		time_dict.get("second", ""),
		"" if time_dict.get("dst") else "no"
	]
	Tools.save_string(logs.text, Global.LOGS_PATH)
