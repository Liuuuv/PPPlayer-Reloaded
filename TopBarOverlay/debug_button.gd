extends ButtonComponent

func _pressed() -> void:
	pass
	#Global.downloads_tab.add_id_to_queue("IqO8HFbfxVo")
	
	#MusicRecommendation.get_recommendations("HrkFQAQyFGc")
	#Scrapper.search_anison("glassy sky", print)
	
	#Scrapper.search_utanet("Beautiful Soldier", Global.list_window.display_lines)
	#Scrapper.utanet_lyrics("235048", print)
	#Scrapper.process_genius("Genius-romanizations-minami-kawaki-wo-ameku-romanized-lyrics", print)
	#print(MusicRecommendation.get_recommendations("vvvvcpwFw5o"))
	
	#Global.artist_page.gather_and_display_infos("UCgwteC3ja-6FkDDHiK8diQw")
	#Global.artist_page.gather_and_display_infos("UCMluca6I7VG2G0lFAZnTThw")
	print("debug pressed")
	
	print("UPDATE ALL BPMS DISABLED BECAUSE OF MEMORY")
	#for id in Global.song_infos.keys():
		#var song_info: Dictionary = Global.song_infos.get(id, {})
		#if song_info.get("bpm", 0):
			#song_info.set("bpm", roundi(song_info.get("bpm", 0)))
			#Global.save_song_infos()
			#
		#else:
			#Global.stats_tab.bpm_bar_chart.calculate_bpm(id)
