extends Node

var log_func: Callable

#func execute_python_script(args: Array, callback: Callable) -> void:
	### UsePython.execute_python_script(
	### 	[
	### 		script,
	### 		html_file,
	### 		config
	### 	],
	### 	current_callback
	### )
	#var output := []
	#var python = "python"
#
	#var exit_code = OS.execute(
		#python,
		#args,
		#output,
		#true
	#)
	##print("execute_python_script output: ", output[0])
#
	#if exit_code == 0:
		#var data = JSON.parse_string(output[0])
		##print("data ", data)
		#callback.call(data)



var thread: Thread
var mutex: Mutex
var thread_output: Array = []
var thread_exit_code: int = -1
var busy: bool = false
var pending_requests: Array = []  # [{args: Array, callback: Callable}]

func _ready() -> void:
	mutex = Mutex.new()
	
	_initialize.call_deferred()

func _initialize() -> void:
	log_func = Global.logs_display.write

## [param callback] MUST be Dictionary -> X
func execute_python_script(args: Array, callback: Callable) -> void:
	if busy:
		# Ajoute à la file d'attente
		pending_requests.push_back({
			"args": args,
			"callback": callback
		})
		print("Ajouté à la queue (", pending_requests.size(), " en attente)")
		return
	
	_start_execution(args, callback)

func _start_execution(args: Array, callback: Callable) -> void:
	log_func.call("Starting the Python execution for args %s with callback %s" % [args, callback])
	
	if not args[0] is String:
		log_func.call("First argument is not a String.")
		push_error("First argument is not a String.")
		return
	if not args[0].is_absolute_path():
		log_func.call("First argument is not an absolute path.")
		push_error("First argument is not an absolute path.")
		return
	busy = true
	thread = Thread.new()
	thread.start(_execute_python_thread.bind(args, callback))

func _execute_python_thread(args: Array, callback: Callable) -> void:
	var output: Array = []
	var python = "python"
	
	
	var exit_code = OS.execute(python, args, output, true)
	
	mutex.lock()
	thread_output = output
	thread_exit_code = exit_code
	mutex.unlock()
	
	call_deferred("_on_thread_completed", callback)

func _on_thread_completed(callback: Callable) -> void:
	mutex.lock()
	var output = thread_output.duplicate()
	var exit_code = thread_exit_code
	mutex.unlock()
	
	if exit_code == 0 and output.size() > 0:
		var data = JSON.parse_string(output[0])
		callback.call(data)
		# Vérifier que data n'est PAS null
		if data == null:
			callback.call({
				"success": false,
				"error": "Failed to parse JSON output: " + output[0]
			})
		elif not data is Dictionary:
			# Si c'est un autre type, l'emballer dans un Dictionary
			callback.call({
				"success": true,
				"data": data
			})
		else:
			callback.call(data)
	else:
		var error_msg: String = "Exit code: %s, output size: %s." % [exit_code, output.size()]
		match exit_code:
			2: error_msg += "\nExit code 2 can signify that the Python file was not found. You should have put the Python scripts in the user folder."
		callback.call({
			"success": false,
			"error": error_msg
		})
	
	
	var thread_to_wait = thread
	if thread_to_wait and thread_to_wait.is_alive():
		thread_to_wait.wait_to_finish()
	thread = null
	
	
	
	# Passe à la requête suivante
	busy = false
	_check_queue()

func _check_queue() -> void:
	if not pending_requests.is_empty():
		var request = pending_requests.pop_front()
		_start_execution(request["args"], request["callback"])





#
