extends Control
class_name BPMBarChart

@onready var chart: Chart = %BPMChart

var functions: Array[Function]
var selected_functions: Array[Function]

var is_secondary_function_visible := true
var secondary_function: Function



var cp: ChartProperties

func _ready():
	# Let's customize the chart properties, which specify how the chart
	# should look, plus some additional elements like labels, the scale, etc...
	cp = ChartProperties.new()
	cp.y_scale = 10
	cp.draw_origin = true
	cp.draw_bounding_box = false
	cp.draw_vertical_grid = true
	cp.interactive = true # false by default, it allows the chart to create a tooltip to show point values
	cp.show_legend = false
	cp.y_offset_x_labels = true
	# and interecept clicks on the plot

	
	_initialize.call_deferred()

func _initialize() -> void:
	Global.downloads_tab.new_song_downloaded.connect(_on_new_song_downloaded)
	update_chart()

func _plot():
	chart.plot(selected_functions, cp)

func update_chart() -> void:
	print("Updating chart")
	
	
	#####################
	## all songs
	#var data: Array = []
	#for local_id in Global.song_infos:
		#var song_info: Dictionary = Global.song_infos.get(local_id)
		#if song_info.get("bpm", ""):
			#var display_name: String = song_info.get("display_name", "ID:%s" % local_id)
			#data.append([display_name, song_info.get("bpm", -1.0)])
#
	#data.sort_custom(func(a, b): return a[1] < b[1])
#
	#var x: Array = []
	#var y: Array = []
	#for item in data:
		#x.append(item[0])
		#y.append(item[1])
	#####################
	
	#####################
	var regroup_size: int = 5
	
	# Compter les musiques par tranche de 20 BPM
	var bpm_groups: Dictionary = {}  ## {tranche_min: count}
	
	for local_id in Global.song_infos:
		var song_info: Dictionary = Global.song_infos.get(local_id)
		var bpm = song_info.get("bpm", null)
		if bpm != null and typeof(bpm) in [TYPE_FLOAT, TYPE_INT]:
			# Calculer la tranche (0-19, 20-39, 40-59, etc.)
			var tranche = int(bpm / regroup_size) * regroup_size
			bpm_groups[tranche] = bpm_groups.get(tranche, 0) + 1
	
	# Créer les arrays triés
	var data: Array = []
	for tranche in bpm_groups:
		data.append([tranche, bpm_groups[tranche]])
	
	# Trier par BPM croissant
	data.sort_custom(func(a, b): return a[0] < b[0])
	
	# Préparer les labels et valeurs
	var x: Array = []
	var y: Array = []
	for item in data:
		var bpm_min = item[0]
		var count = item[1]
		x.append("\n%d-%d" % [bpm_min, bpm_min + regroup_size - 1])
		y.append(count)
	#####################
	
	
	var f1 = Function.new(
		x, y, "Number of songs",
		{
			type = Function.Type.BAR,
			bar_size = 5,
			color = Color.SEA_GREEN,
		}
	)
	
	
	selected_functions = [f1]
	_plot()

func wrap_text(text: String, max_chars: int) -> String:
	var words = text.split(" ")
	var current_line = ""
	var result = ""
	
	for word in words:
		if current_line.length() + word.length() + 1 > max_chars:
			result += current_line + "\n"
			current_line = word
		else:
			current_line += (" " if current_line != "" else "") + word
	
	result += current_line
	return result

## Calculates the BPM of the given song. The BPM is calculate via the Python library librosa. Its type is [code]int[/code].
func calculate_bpm(local_id: String, reload_callback: bool = true) -> void:
	print("Computing bpm for local ID %s" % local_id)
	var script_fullpath = Tools.get_python_script_fullpath("get_bpm")
	var song_info: Dictionary = Global.song_infos.get(local_id, {})
	var song_fullpath: String = Tools.get_full_path_from_id(local_id)
	if song_fullpath:
		if song_info:
			UsePython.execute_python_script(
				[
					script_fullpath,
					song_fullpath
				],
				func(result: Dictionary): _process_bpm_result(result, local_id, reload_callback)
			)
		else:
			push_error("No song info for local ID: %s" % local_id)
	else:
		push_error("No path found for local ID: %s" % local_id)

## Re-computes the BPM if it has not been already done. [br]
## Use [method calculate_bpm] for re-computing (or computing) a BPM.
func update_bpm(local_id: String, reload_callback: bool = true) -> void:
	print("Updating bpm for local ID %s" % local_id)
	var song_info: Dictionary = Global.song_infos.get(local_id, {})
	if song_info:
		if song_info.get("bpm", 0):
			print("BPM was already calculated for ID: %s" % local_id)
			return
		else:
			calculate_bpm(local_id, reload_callback)
	else:
		push_error("No song info for local ID: %s" % local_id)
	

func _process_bpm_result(data: Dictionary, local_id: String, reload_callback: bool = true) -> void:
	if data.get("success", false):
		var song_info: Dictionary = Global.song_infos.get(local_id)
		if song_info:
			var result: Dictionary = data.get("result", {})
			song_info.set("bpm", roundi(result.get("bpm", -1)))
		Global.save_song_infos()
		if reload_callback:
			update_chart()
	else:
		push_error("Error processing the BPM result (from Python script). Error: %s" % data.get("error", ""))
		return

func _on_new_song_downloaded(local_id: String) -> void:
	update_bpm(local_id)
	update_chart()




#
