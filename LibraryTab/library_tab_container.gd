extends TabContainer

@onready var downloaded_tab: DownloadedTab = $Downloaded

func _ready() -> void:
	tab_clicked.connect(_on_tab_clicked)

func _on_tab_clicked(tab: int):
	if tab == 0:
		downloaded_tab.reload_song_list()
