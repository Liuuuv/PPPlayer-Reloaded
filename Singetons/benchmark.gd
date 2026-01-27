extends Node

var start_time: float = 0.0 # Time.get_ticks_msec()
var end_time : float = 0.0

func benchmark(function: Callable, pre_func: Callable = Callable(), post_func: Callable = Callable()) -> Array:
	var num_iteration: int = 20
	
	var time_array: Array = []
	for iteration_index in range(num_iteration):
		if pre_func:
			pre_func.call()
		start_time = Time.get_ticks_msec()
		function.call()
		end_time = Time.get_ticks_msec()
		if post_func:
			post_func.call()
		time_array.append(end_time - start_time)
	
	print(time_array)
	DisplayServer.clipboard_set(str(time_array))
	
	return time_array
