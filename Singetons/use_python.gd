extends Node

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
var semaphore: Semaphore
var thread_output: Array = []
var thread_exit_code: int = -1
var thread_finished: bool = false

func _ready() -> void:
	mutex = Mutex.new()
	semaphore = Semaphore.new()

func execute_python_script(args: Array, callback: Callable) -> void:
	thread = Thread.new()
	thread.start(_execute_python_thread.bind(args, callback))

func _execute_python_thread(args: Array, callback: Callable) -> void:
	var output := []
	var python = "python"
	
	var exit_code = OS.execute(
		python,
		args,
		output,
		true
	)
	
	# Thread-safe : stocke les résultats
	mutex.lock()
	thread_output = output
	thread_exit_code = exit_code
	thread_finished = true
	mutex.unlock()
	
	# Appelle le callback sur le thread principal
	call_deferred("_on_thread_completed", callback)

func _on_thread_completed(callback: Callable) -> void:
	mutex.lock()
	var output = thread_output.duplicate()
	var exit_code = thread_exit_code
	thread_finished = false
	mutex.unlock()
	
	if exit_code == 0 and output.size() > 0:
		var data = JSON.parse_string(output[0])
		callback.call(data)
	else:
		callback.call(null)
	
	thread.wait_to_finish()





#
