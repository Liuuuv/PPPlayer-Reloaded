extends Control
class_name StatsTab

#@onready var bpm_bar_chart: BPMBarChartOLD = %BPMBarChartOLD
@onready var bpm_bar_chart: BPMBarChart = %BPMBarChart

func _ready() -> void:
	Global.stats_tab = self
	
	_initialize.call_deferred()

func _initialize() -> void:
	pass
