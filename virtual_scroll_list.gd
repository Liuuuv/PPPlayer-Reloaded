extends Control
class_name VirtualScrollList


signal on_item_selected(idx: int)

enum GridAlignment {LEFT, RIGHT, CENTER}

@export var template_viewport: SubViewport
@export var grid_alignment: GridAlignment = GridAlignment.LEFT
@export var scroll_tick_amount: float = 10.0
@export var row_width: int = -1

@onready var template = $Template
var items: Array = []
var scroll: float = 0.0
var selected_idx: int = -1

var _pressed: bool = false
var _debug_draw: bool = true

func _ready() -> void:
	#template = get_node_or_null("Template")
	
	if not Engine.is_editor_hint():
		if template == null:
			#push_error("Virtual Scroll List template '" + get_path() + "/Template' not found")
			return
		
		remove_child(template)
		template_viewport.add_child(template)
	
	if template:
		template.tree_exiting.connect(_on_template_exiting)

func _on_template_exiting() -> void:
	print("nuuul")
	template = null

func add_item(item: Variant) -> void:
	items.append(item)
	queue_redraw()

func _process(delta: float) -> void:
	#if not template:
		#return
	
	template.position = Vector2.ZERO
	template.size = get_item_size()
	
	if Engine.is_editor_hint():
		template.position += Vector2(get_grid_margin(), 0)
		return
	
	if items.is_empty():
		return
	
	# Handle scrolling with rubber band effect
	if scroll < 0:
		scroll = lerpf(scroll, 0.0, delta * 10.0)
		queue_redraw()
	else:
		var end_position: float = get_end_position()
		if end_position > size.y:
			if scroll + size.y > end_position:
				scroll = lerpf(scroll, end_position - size.y, delta * 10.0)
				queue_redraw()
		elif scroll > 0:
			scroll = lerpf(scroll, 0.0, delta * 10.0)
			queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not template or items.is_empty():
		return
	
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_pressed = mb.pressed
			if mb.pressed:
				selected_idx = get_index_at_position(mb.position)
			queue_redraw()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll += scroll_tick_amount
			queue_redraw()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll -= scroll_tick_amount
			queue_redraw()
	
	elif event is InputEventMouseMotion and _pressed:
		var mm: InputEventMouseMotion = event
		selected_idx = get_index_at_position(mm.position)
		queue_redraw()

func get_item_size() -> Vector2:
	if not template:
		return Vector2.ZERO
	
	if row_width <= 0:
		return Vector2(size.x, template.size.y)
	else:
		return Vector2(row_width, template.size.y)

func get_column_count() -> int:
	var item_size: Vector2 = get_item_size()
	if item_size.x <= 0:
		return 1
	return floori(size.x / item_size.x)

func get_index_at_position(pos: Vector2) -> int:
	pos += Vector2(-get_grid_margin(), scroll)
	
	var item_size: Vector2 = get_item_size()
	if item_size.x <= 0 or item_size.y <= 0:
		return -1
	
	var cols: int = get_column_count()
	var width: float = item_size.x * cols
	var height: float = get_end_position()
	
	# Check if position is within bounds
	if not Rect2(Vector2.ZERO, Vector2(width, height)).has_point(pos):
		return -1
	
	var col: int = floori(pos.x / item_size.x)
	var row: int = floori(pos.y / item_size.y)
	
	return (row * cols) + col

func select_item(idx: int) -> void:
	selected_idx = idx
	on_item_selected.emit(idx)

func get_end_position() -> float:
	if not template or items.is_empty():
		return 0.0
	
	var cols: int = get_column_count()
	if cols <= 0:
		return 0.0
	
	return (items.size() * template.size.y) / cols

func get_grid_margin() -> float:
	if grid_alignment == GridAlignment.LEFT:
		return 0.0
	
	var item_size: Vector2 = get_item_size()
	var cols: int = get_column_count()
	var total_width: float = item_size.x * cols
	
	match grid_alignment:
		GridAlignment.RIGHT:
			return size.x - total_width
		GridAlignment.CENTER:
			return (size.x - total_width) / 2.0
		_:
			return 0.0

func _draw() -> void:
	if not template or items.is_empty():
		return
	
	var template_box: Rect2 = template.get_rect()
	var cols: int = get_column_count()
	if cols <= 0:
		return
	
	var start_index: int = max(0, floori(scroll / template_box.size.y) * cols)
	var end_index: int = min(items.size(), start_index + (ceili(size.y / template_box.size.y) * cols))
	
	if start_index > end_index:
		return
	
	var margin: float = get_grid_margin()
	
	for i in range(start_index, end_index):
		var col: int = i % cols
		var row: int = i / cols
		
		var item_bbox: Rect2 = template_box
		var new_pos: Vector2 = item_bbox.position
		new_pos.y -= scroll
		new_pos += Vector2(col * template_box.size.x, row * template_box.size.y)
		new_pos.x += margin
		item_bbox.position = new_pos
		
		if _debug_draw and i == selected_idx:
			draw_rect(item_bbox, Color.RED, false, 8.0)
		
		draw_item(template, item_bbox, items[i])

func draw_item(template_control: Control, box: Rect2, item: Variant) -> void:
	var item_box: Rect2 = template_control.get_global_rect()
	item_box.position += box.position
	
	if template_control is Label:
		var label: Label = template_control
		var text: String = ""
		
		if str(template_control.name)[0] == '-':
			var property_name: String = template_control.name.substr(1)
			var property_value = get_property(item, property_name)
			
			# formatting
			#text = label.text.format([property_value]) if property_value != null else label.text
			
			# replacing
			text = str(property_value) if property_value != null else label.text
		else:
			text = label.text
		
		var font_size: int = label.get_theme_font_size("font_size")
		if font_size == 0:
			font_size = label.get_theme_default_font_size()
		
		draw_string(
			label.get_theme_font("font"),
			item_box.position + Vector2(0, font_size),
			text,
			HORIZONTAL_ALIGNMENT_LEFT,
			item_box.size.x,
			font_size
		)
	
	elif template_control is TextureRect:
		var texture_rect: TextureRect = template_control
		if texture_rect.texture:
			draw_texture_rect(texture_rect.texture, item_box, false, texture_rect.modulate)
	
	elif template_control is ColorRect:
		var color_rect: ColorRect = template_control
		draw_rect(item_box, color_rect.color, true)
	
	if _debug_draw:
		draw_rect(item_box, Color.WHITE, false, 1.0)
	
	for child in template_control.get_children():
		if child is Control:
			draw_item(child, box, item)

func get_property(obj: Variant, property_name: String) -> Variant:
	if obj is Dictionary:
		return obj.get(property_name)
	
	elif obj is Object:
		return obj.get(property_name)
	
	# Try to get property via get() method if it exists
	if obj is RefCounted and obj.has_method("get"):
		return obj.call("get", property_name)
	
	return null
