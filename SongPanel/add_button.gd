extends ButtonComponent

func _ready():
	get_window().files_dropped.connect(on_files_dropped)

## [param files] example: ["C:\\Users\\YOURNAME\\Downloads\\This_is_a_song.mp3"]
func on_files_dropped(files):
	if files:
		for filepath: String in files:
			SongManager.add_song_from_file(filepath)

func _pressed() -> void:
	var song_path: String = await Global.select_song_dialog.ask_for_song()
	if song_path != "":
		SongManager.add_song_from_file(song_path)
