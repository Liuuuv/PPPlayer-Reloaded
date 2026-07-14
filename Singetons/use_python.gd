extends Node

func _ready() -> void:
	pass

func execute_python_script(args: Array, callback: Callable) -> void:
	## UsePython.execute_python_script(
	## 	[
	## 		script,
	## 		html_file,
	## 		config
	## 	],
	## 	current_callback
	## )
	var output := []
	var python = "python"

	var exit_code = OS.execute(
		python,
		args,
		output,
		true
	)
	print("execute_python_script output: ", output[0])

	if exit_code == 0:
		var data = JSON.parse_string(output[0])

		callback.call(data)






#
