extends SongVirtualScrollList
class_name BaseLocalSongVirtualScrollList

#@onready var is_selected_template: Label = %"+is_selected"




var content_ids: Array[String] = [] ## contains the ids of the songs

func _ready() -> void:
	super._ready()
	
	reload_song_items()

func _initialize() -> void:
	super._initialize()

func clear_items() -> void:
	content_ids.clear()
	super.clear_items()

func reload_song_items() -> void:
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	super._gui_input(event)
	if event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event
		#var template_box: Rect2 = template.get_rect()
		#if mm.position.x >= template_box.size.x - is_selected_template.size.x:
			#is_hovering_selection_box = true
		#else:
			#is_hovering_selection_box = false
		
		


#func clear_song_items() -> void:
	#for child in get_children():
		#child.queue_free()
	#content_ids = []
	


func _on_item_left_clicked(idx: int) -> void:
	super._on_item_left_clicked(idx)





#
