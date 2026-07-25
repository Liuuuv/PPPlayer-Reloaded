extends ButtonComponent

func _pressed() -> void:
	for id in Global.song_infos.keys():
		Global.stats_tab.bpm_bar_chart.update_bpm(id)
