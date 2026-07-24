extends Control
class_name DownloadedTab

signal song_item_clicked(id: String)


@onready var song_list: SongVirtualScrollList = %DownloadedSongList
@onready var shuffle_button: ButtonComponent = %ShuffleButton

var id_to_display: Array[String] = ["_all"] ## ["_all"] for displaying everything

## pooling
#var _available_song_items = []
#var _in_use_song_items = []
#var max_pool_size: int = 50

#var ids_to_add: Array[String] = [] 

func _ready() -> void:
	Global.downloaded_tab = self
	
	SongManager.song_deleted.connect(_on_song_deleted)
	initialize.call_deferred()
	
	shuffle_button.pressed.connect(_on_shuffle_button_pressed)
	#song_item_clicked.connect(_on_song_item_clicked)

func initialize():
	
	reload_list()
	
	#song_list.item_left_clicked.connect(_on_item_left_clicked)

func reload_list() -> void:
	song_list.reload_list()

func reload_song_list(new_id_to_display: Array[String] = ["_all"]) -> void:
	id_to_display = new_id_to_display
	reload_list()

func _on_shuffle_button_pressed() -> void:
	var shuffle_playlist: Array[String] = []
	shuffle_playlist.assign(Global.song_infos.keys())
	shuffle_playlist.shuffle()
	Global.current_playlist.clear_items()
	Global.current_playlist.content_ids = shuffle_playlist
	Global.current_playlist.reload_song_items()
	SongManager.play_from_index(0, true)

func _on_song_deleted(local_id: String) -> void:
	reload_list()

#
