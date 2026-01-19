extends Control

#@onready var polygon: Polygon2D = $Polygon2D

func _ready() -> void:
	pass
	#get_window().mouse_passthrough_polygon = polygon.polygon
	
	#var rect = get_rect() as Rect2
	#var texture_corners: PackedVector2Array = [
	#rect.position, # Top left corner
	#rect.position + Vector2(rect.size.x, 0), # Top right corner
	#rect.position + rect.size, # Bottom right corner
	#rect.position + Vector2(0, rect.size.y) # Bottom left corner
	#]
	#DisplayServer.window_set_mouse_passthrough(texture_corners)

#func _process_clickables() -> void:
	#var clickable_nodes = get_tree().get_nodes_in_group("Clickables")
	#for node in clickable_nodes:
		#if node is Control:
			#var rect = node.get_rect() as Rect2
			#var texture_corners: PackedVector2Array = [
			#rect.position, # Top left corner
			#rect.position + Vector2(rect.size.x, 0), # Top right corner
			#rect.position + rect.size, # Bottom right corner
			#rect.position + Vector2(0, rect.size.y) # Bottom left corner
			#]
			#DisplayServer.window_set_mouse_passthrough(texture_corners)
		#else:
			#printerr(node.name + " is not a Control")
