extends Control

@onready var horizontal_bar_chart: BaseVirtualScrollList = %HorizontalBarChart


class BPMSong extends RefCounted:
	var display_name: String = ""
	var bpm: int = -1
	
	func _init(display_name_: String, bpm_: int) -> void:
		display_name = display_name_
		bpm = bpm_
	
	func get_size_x() -> float:
		return float(bpm)

func _ready() -> void:
	_initialize.call_deferred()

func _initialize() -> void:
	plot()


func plot() -> void:
	var data: Array = []
	for local_id in Global.song_infos:
		var song_info: Dictionary = Global.song_infos.get(local_id)
		if song_info.get("bpm", ""):
			var display_name: String = song_info.get("display_name", "ID:%s" % local_id)
			data.append([display_name, song_info.get("bpm", -1.0)])

	data.sort_custom(func(a, b): return a[1] < b[1])

	#var x: Array = [] ## music name
	#var y: Array = [] ## bpm
	#for item in data:
		#x.append(item[0])
		#y.append(item[1])
	
	for i in data.size():
		var bpm_song: BPMSong = BPMSong.new(data[i][0], data[i][1])
		horizontal_bar_chart._add_item(bpm_song)










#
