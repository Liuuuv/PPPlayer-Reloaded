extends Window
class_name LogsDisplay

@onready var logs: RichTextLabel = %Logs
@onready var clear_logs_button: ButtonComponent = %ClearLogsButton

const MAX_VISIBLE_LINES := 500


enum MESSAGE {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
}

var save_timer = Timer.new()
var is_open: bool = false
var must_be_saved: bool = false:
	set(on):
		must_be_saved = on
		save_timer.start()
		#if on != must_be_saved:
			#must_be_saved = on
			#if must_be_saved:
				#save.call_deferred()
var unsaved_lines: int = 0:
	set(new_num):
		unsaved_lines = new_num
		if unsaved_lines >= 15:
			save.call_deferred()
			save_timer.stop()
			
var num_errors: int = 0
var log_lines: Array[String] = []
var minimum_level := MESSAGE.DEBUG ## to not display some logs

func _ready() -> void:
	Global.logs_display = self
	
	
	
	save_timer.wait_time = 1.0
	save_timer.autostart = false
	save_timer.one_shot = true
	save_timer.timeout.connect(_on_save_timer_timeout)
	add_child(save_timer)
	
	
	if Config.disable_logs:
		#logs.text = "---------- LOGS DISABLED ----------"
		pass
	else:
		logs.text = _log_load_string(Global.LOGS_PATH)
		var time_dict: Dictionary = Time.get_datetime_dict_from_system()
		logs.text += "\n[color=purple][START SESSION][/color] %s/%s/%s, %s:%s:%s %s DST \n" % [
			time_dict.get("year", ""),
			time_dict.get("month", ""),
			time_dict.get("day", ""),
			time_dict.get("hour", ""),
			time_dict.get("minute", ""),
			time_dict.get("second", ""),
			"" if time_dict.get("dst") else "no"
		]
		#Tools.save_string(logs.text, Global.LOGS_PATH)
		save()
	
	clear_logs_button.clear_logs.connect(_on_clear_logs)
	close_requested.connect(_on_close_requested)


func open():
	is_open = true
	show()
	
func close():
	is_open = false
	hide()

func write(message: String, type: MESSAGE = MESSAGE.DEBUG, force_save: bool = false):
	if Config.disable_logs:
		return
	if type < minimum_level:
		return
	_write.call_deferred(message, type, force_save)
	#_write(message, type) # write the same frame for the benchmark
	

func save() -> void:
	_log_save_string(logs.get_parsed_text(), Global.LOGS_PATH)
	must_be_saved = false
	if num_errors > 0:
		title = "Logs (%s errors)" % num_errors
	else:
		title = "Logs"
	#update_num_errors()

func update_num_errors():
	var count: int = 0
	
	# Format court youtu.be
	var short_pattern = "\\[ERROR\\]"
	var regex = RegEx.new()
	if regex.compile(short_pattern) == OK:
		var results = regex.search_all(logs.text)
		for result in results:
			count += 1
		num_errors = count
	

func _write(message: String, type: MESSAGE = MESSAGE.DEBUG, force_save: bool = false):
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
			num_errors += 1
	#logs.text += type_message + message + "\n "
	var time_dict: Dictionary = Time.get_datetime_dict_from_system()
	var time_text: String = "[%s/%s/%s, %s:%s:%s] - " % [
		time_dict.get("year", ""),
		time_dict.get("month", ""),
		time_dict.get("day", ""),
		time_dict.get("hour", ""),
		time_dict.get("minute", ""),
		time_dict.get("second", ""),
		]
	logs.append_text(type_message + time_text + message + "\n")
	
	if force_save: save()
	else: must_be_saved = true
	
	#log_lines.append(type_message + message)
	#if log_lines.size() > MAX_VISIBLE_LINES:
		#log_lines.pop_front()
	#logs.text = "\n".join(log_lines)
	#must_be_saved = true

func _on_close_requested():
	close()

func _on_clear_logs():
	var confirm: bool =  await Global.confirmation_dialog.ask_for_confirmation("Confirm", "Are you sure to delete the logs?")
	if confirm:
		num_errors = 0
		if Config.disable_logs:
			logs.text = "---------- LOGS DISABLED [CLEARED] ----------"
		else:
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
			#Tools.save_string(logs.text, Global.LOGS_PATH)
			save()
		

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
	#Tools.save_string(logs.text, Global.LOGS_PATH)
	save()


func _log_save_string(string: String, full_file_path: String) -> void:
	var file = FileAccess.open(full_file_path, FileAccess.ModeFlags.WRITE_READ)
	
	if file:
		file.store_string(string)
		file.close()
	else:
		push_error("Can't open file %s" % full_file_path)

func _log_load_string(full_file_path: String) -> String:
	var file = FileAccess.open(full_file_path, FileAccess.READ)
	
	if file == null:
		return ""
	
	var content = file.get_as_text()
	file.close()
	return content

func _on_save_timer_timeout() -> void:
	save()
