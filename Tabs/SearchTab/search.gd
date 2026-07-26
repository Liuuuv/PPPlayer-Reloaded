extends Control
class_name SearchTab

@onready var waveform: ColorRect = %Waveform
@onready var big_thumbnail: TextureRect = %BigThumbnail
@onready var bpm_label: Label = %BPMLabel

@onready var default_thumbnail_tex: Texture2D = big_thumbnail.texture
@onready var content_tabs: TabContainer = %ContentTabs
@onready var search_bar: LineEdit = %SearchBar

#@onready var play_button: Button = %PlayButton
#@onready var add_button: Button = %AddButton


func _ready() -> void:
	
	Global.search_tab = self
	
	search_bar.text_submitted.connect(_on_search_bar_text_submitted)
	_initialize.call_deferred()
	#play_button.pressed.connect(_on_play_button_pressed)
	#add_button.pressed.connect(_on_add_button_pressed)


func _initialize():
	Global.music_player.playing_changed.connect(_on_playing_changed)
	Global.music_player.stream_changed.connect(_on_stream_changed)
	

func _on_playing_changed():
	if Global.music_player.playing:
		waveform.appear()
	else:
		waveform.disappear()

func _on_stream_changed(full_path):
	if full_path == "":
		big_thumbnail.texture = default_thumbnail_tex
	else:
		var id: String = full_path.get_file().get_basename()
		
		big_thumbnail.texture = CacheManager.get_cached_thumbnail(id)
		
		var song_info: Dictionary = Global.song_infos.get(id, {})
		if song_info.get("bpm", 0.0):
			bpm_label.text = "%s BPM" % song_info.get("bpm", 0.0)
		else:
			bpm_label.text = "No BPM calculated"



func _on_search_bar_text_submitted(new_text: String):
	pass

#func _on_tab_changed() -> void:
	#print(is_visible_in_tree())


#func _on_play_button_pressed():
	#
#
#func _on_add_button_pressed():
	##print(OS.shell_show_in_file_manager("/"))
	#pass
