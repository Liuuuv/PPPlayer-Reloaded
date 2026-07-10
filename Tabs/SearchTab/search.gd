extends Control

@onready var waveform: ColorRect = %Waveform


#@onready var play_button: Button = %PlayButton
#@onready var add_button: Button = %AddButton


func _ready() -> void:
	_initialize.call_deferred()
	#play_button.pressed.connect(_on_play_button_pressed)
	#add_button.pressed.connect(_on_add_button_pressed)


func _initialize():
	Global.music_player.playing_changed.connect(_on_playing_changed)

func _on_playing_changed():
	if Global.music_player.playing:
		waveform.appear()
	else:
		waveform.disappear()







#func _on_play_button_pressed():
	#
#
#func _on_add_button_pressed():
	##print(OS.shell_show_in_file_manager("/"))
	#pass
