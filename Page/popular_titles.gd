extends SongVirtualScrollList
class_name ArtistPageContent

var has_focus: bool = false

func _on_item_left_clicked(idx: int) -> void:
	super._on_item_left_clicked(idx)
	has_focus = true
	Global.artist_page.scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

func _on_mouse_entered() -> void:
	super._on_mouse_entered()

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	has_focus = false
	Global.artist_page.scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
