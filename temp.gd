extends Control

@export var scroll_list: VirtualScrollList
@export var scroll_grid: VirtualScrollList

var items: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if scroll_grid:
		scroll_grid.items = items
	if scroll_list:
		scroll_list.items = items

func add_item() -> void:
	#scroll_list.items.append(create_random_item())
	scroll_list.items.append(SongItem2.new())
	scroll_list.queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func create_random_item() -> ListItem:
	#var names: Array[String] = ["Apple", "Milk", "Beans", "Water"]
	#var rng := RandomNumberGenerator.new()
	#
	#var i := SongItem.new()
	#i.SongName = names[rng.randi_range(0, names.size() - 1)]
	#i.Price = rng.randi_range(10, 45) / 10.0
	#
	#return i


class SongItem2:
	var SongName: String = "SONG NAME"
	var Artist: String = "ARTIST"
	var DurationString: String = "XX:XX"
	
	func _init() -> void:
		pass
