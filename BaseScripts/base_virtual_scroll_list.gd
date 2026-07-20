extends Control
class_name BaseVirtualScrollList


signal item_left_clicked(idx: int)
signal item_right_clicked(idx: int)

enum GridAlignment {LEFT, RIGHT, CENTER}

@onready var initial_custom_minimum_size: Vector2 = custom_minimum_size

@export_group("Can Grab Scroll Focus")
@export var can_grab_scroll_focus: bool = false
@export var stretch_focus_duration: float = 0.1
@export var popular_titles_expand_margin: float = 330.0

@export_group("General")
@export var template_viewport: SubViewport
@export var grid_alignment: GridAlignment = GridAlignment.LEFT
@export var default_scroll_tick_amount: float = 15.0
@export var fast_tick_amount_multiplier: float = 2.5
@export var row_width: int = -1
@export var template_path: NodePath
@export var _debug_draw: bool = false

@export var is_nested: bool = false



var scroll_tick_amount: float = default_scroll_tick_amount
var template: Control

var items: Array = []
var scroll: float = 0.0
var selected_idx: int = -1
var hovered_idx: int = -1
var can_scroll: bool = true

@export var shader_bg: ColorRect

var left_click_pressed: bool = false:
	set(on):
		if on == left_click_pressed:
			return
		left_click_pressed = on
		if on:
			if selected_idx != -1:
				item_left_clicked.emit(selected_idx)
		else:
			selected_idx = -1

var right_click_pressed: bool = false:
	set(on):
		if on == right_click_pressed:
			return
		right_click_pressed = on
		if on:
			if selected_idx != -1:
				item_right_clicked.emit(selected_idx)
		else:
			selected_idx = -1




func _ready() -> void:
	_initialize.call_deferred()
	template = get_node_or_null(template_path)
	
	if not Engine.is_editor_hint():
		if template == null:
			push_error("Template not provided, skipping _ready(). To provide one, drag and drop a template in the inspector")
			return
		
		remove_child(template)
		if template_viewport:
			template_viewport.add_child(template)
	
	if template:
		template.tree_exiting.connect(_on_template_exiting)
	
	if shader_bg:
		shader_bg.hide()
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	item_left_clicked.connect(_on_item_left_clicked)
	item_right_clicked.connect(_on_item_right_clicked)

func _initialize() -> void:
	pass

func _on_template_exiting() -> void:
	template = null




func _add_item(item: Variant, redraw: bool = true) -> void:
	items.append(item)
	queue_redraw()

func _process(delta: float) -> void:
	if not template:
		return
	
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
			if scroll + size.y - template.size.y > end_position:
				if is_nested:
					scroll = lerpf(scroll, end_position - size.y + get_parent().size.y, delta * 10.0)
				else:
					scroll = lerpf(scroll, end_position - size.y + template.size.y, delta * 10.0)
				queue_redraw()
		elif scroll > 0:
			scroll = lerpf(scroll, 0.0, delta * 10.0)
			queue_redraw()

func _input(event):
	if event.is_action_pressed("ctrl"):
		scroll_tick_amount = default_scroll_tick_amount * fast_tick_amount_multiplier
	elif event.is_action_released("ctrl"):
		scroll_tick_amount = default_scroll_tick_amount

func _gui_input(event: InputEvent) -> void:
	if not template or items.is_empty():
		return
	
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				selected_idx = get_index_at_position(mb.position)
			
			left_click_pressed = mb.pressed # order is important, need to be processed after changing selected_idx
			queue_redraw()
		elif mb.button_index == MOUSE_BUTTON_RIGHT:
			if mb.pressed:
				selected_idx = get_index_at_position(mb.position)
			
			right_click_pressed = mb.pressed # order is important, need to be processed after changing selected_idx
			queue_redraw()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if can_scroll:
				scroll += scroll_tick_amount
				queue_redraw()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			if can_scroll:
				scroll -= scroll_tick_amount
				queue_redraw()
	
	#elif event is InputEventMouseMotion and left_click_pressed:
		#var mm: InputEventMouseMotion = event
		#selected_idx = get_index_at_position(mm.position)
		#queue_redraw()
	
	elif event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event
		hovered_idx = get_index_at_position(mm.position)
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

func get_row_count() -> int:
	var item_size: Vector2 = get_item_size()
	if item_size.y <= 0:
		return 1
	return floori(size.y / item_size.y)

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

#func select_item(idx: int) -> void: ## unused? ig
	#selected_idx = idx
	#item_left_clicked.emit(idx)

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
	var y_padding: float = 0.0
	var start_index: int = max(0, floori(scroll / (template_box.size.y + y_padding)) * cols)
	var end_index: int = min(items.size(), start_index + ( ceili(size.y / (template_box.size.y + y_padding) ) * cols) + 1)
	
	if start_index > end_index:
		return
	
	var margin: float = get_grid_margin()
	
	
	for i in range(start_index, end_index):
		var col: int = i % cols
		var row: int = floori(i / cols)
		
		
		var item_bbox: Rect2 = template_box
		var new_pos: Vector2 = item_bbox.position
		new_pos.y -= scroll
		new_pos += Vector2(col * template_box.size.x, row * (template_box.size.y + y_padding))
		new_pos.x += margin
		item_bbox.position = new_pos
		
		if _debug_draw and i == selected_idx:
			draw_rect(item_bbox, Color.RED, false, 8.0)
		
		draw_item(template, item_bbox, items[i])

func draw_item(template_control: Control, box: Rect2, item) -> void:
	var item_box: Rect2 = template_control.get_global_rect()
	item_box.position += box.position
	
	
	
	
	if template_control == template:
		draw_rect(item_box, Color(0.0, 0.003, 0.08, 0.2), true)
	
	if template_control is Label:
		var label: Label = template_control
		var text: String = ""
		
		if str(template_control.name)[0] == '-': ## -prop: replaces with item's property "prop"
			var property_name: String = template_control.name.substr(1)
			var property_value = get_property(item, property_name)
			# formatting
			#text = label.text.format([property_value]) if property_value != null else label.text
			
			# replacing
			text = str(property_value) if property_value != null else label.text
		elif str(template_control.name)[0] == '+': ## +part1-part2: write the result of the func item.part1 with arg item.part2
			var parts: PackedStringArray = template_control.name.split("-", true, 1)
			var method_name: String = parts[0].substr(1)
			var arg_name: String
			if len(parts) > 1:
				arg_name = parts[1]
			else:
				arg_name = ""
			var value: String
			if arg_name != "":
				value = item.call(method_name, item.get(arg_name))
			else:
				value = item.call(method_name)
			text = value if value else ""
		elif str(template_control.name)[0] == '?':
			var parts: PackedStringArray = template_control.name.split("-", true, 1)
			var method_name: String = parts[0].substr(1)
			var arg_name: String = parts[1] if len(parts) > 1 else ""
			var boolean: bool
			if arg_name != "":
				boolean = item.call(method_name, item.get(arg_name))
			else:
				boolean = item.call(method_name)
			if boolean:
				text = label.text if boolean else ""
		else:
			text = label.text
		
		
		var font_size: int = label.get_theme_font_size("font_size")
		if font_size == 0:
			font_size = label.get_theme_default_font_size()
		
		var modulate = label.get_theme_color("font_color", "Label")
		#if font_color == 0:
			#font_color = label.get_theme_()
		
		draw_string(
			label.get_theme_font("font"),
			item_box.position + Vector2(0, font_size),
			text,
			HORIZONTAL_ALIGNMENT_LEFT,
			item_box.size.x,
			font_size,
			modulate,
		)
	
	elif template_control is TextureRect:
		if str(template_control.name) == "Thumbnail":
			if item is Global.SongItem:
				var texture_rect: TextureRect = template_control
				var thumbnail: Texture2D = Tools.get_cached_thumbnail(item.id)
				
				var texture_to_draw: Texture2D = thumbnail if thumbnail else texture_rect.texture
				if texture_to_draw:
					# Calculer le rect qui conserve le ratio
					var fitted_rect = _get_fitted_rect(texture_to_draw, item_box)
					draw_texture_rect(texture_to_draw, fitted_rect, false)		
		elif str(template_control.name)[0] == '?':
			var parts: PackedStringArray = template_control.name.split("-", true, 1)
			var method_name: String = parts[0].substr(1)
			var arg_name: String = parts[1] if len(parts) > 1 else ""
			var boolean: bool
			if arg_name != "":
				boolean = item.call(method_name, item.get(arg_name))
			else:
				boolean = item.call(method_name)
			if boolean:
				var texture_rect: TextureRect = template_control
				if texture_rect.texture:
					draw_texture_rect(texture_rect.texture, item_box, false, texture_rect.modulate)
		elif str(template_control.name)[0] == '+':
			var parts: PackedStringArray = template_control.name.split("-", true, 1)
			var method_name: String = parts[0].substr(1)
			var arg_name: String = parts[1] if len(parts) > 1 else ""
			var tex: Texture2D
			if arg_name != "":
				tex = item.call(method_name, item.get(arg_name))
			else:
				tex = item.call(method_name)
			
			var texture_rect: TextureRect = template_control
			if tex:
				var fitted_rect = _get_fitted_rect(tex, item_box)
				draw_texture_rect(tex, fitted_rect, false)
			#elif texture_rect.texture:
					#draw_texture_rect(texture_rect.texture, item_box, false, texture_rect.modulate)
		else:
			var texture_rect: TextureRect = template_control
			if texture_rect.texture:
				draw_texture_rect(texture_rect.texture, item_box, false, texture_rect.modulate)
	
	elif template_control is ColorRect:
		if str(template_control.name)[0] == '-':
			var property_name: String = template_control.name.substr(1)
			var property_value = get_property(item, property_name)
			if property_value is bool and property_value:
				var color_rect: ColorRect = template_control
				draw_rect(item_box, color_rect.color, true)
		elif str(template_control.name) == "ShaderBGRef":
			if shader_bg:
				if item is Global.SongItem and item.is_playing():
					shader_bg.position = item_box.position + template_control.position
		else:
			var color_rect: ColorRect = template_control
			draw_rect(item_box, color_rect.color, true)
	
	if _debug_draw:
		draw_rect(item_box, Color.WHITE, false, 1.0)
	
	for child in template_control.get_children():
		if child is Control:
			draw_item(child, box, item)

func _get_fitted_rect(texture: Texture2D, target_rect: Rect2) -> Rect2:
	var texture_size = texture.get_size()
	if texture_size.x == 0 or texture_size.y == 0:
		return target_rect
	
	var target_aspect = target_rect.size.x / target_rect.size.y
	var texture_aspect = texture_size.x / texture_size.y
	
	var draw_size: Vector2
	
	if texture_aspect > target_aspect:
		# L'image est plus large → adapter à la largeur
		draw_size.x = target_rect.size.x
		draw_size.y = target_rect.size.x / texture_aspect
	else:
		# L'image est plus haute → adapter à la hauteur
		draw_size.y = target_rect.size.y
		draw_size.x = target_rect.size.y * texture_aspect
	
	# Centrer dans le target_rect
	var draw_pos = target_rect.position + (target_rect.size - draw_size) / 2.0
	
	return Rect2(draw_pos, draw_size)

func get_property(obj: Variant, property_name: String) -> Variant:
	if obj is Dictionary:
		return obj.get(property_name)
	
	elif obj is Object:
		return obj.get(property_name)
	
	# Try to get property via get() method if it exists
	if obj is RefCounted and obj.has_method("get"):
		return obj.call("get", property_name)
	
	return null

func _on_item_left_clicked(idx: int) -> void:
	if can_grab_scroll_focus:
		mouse_force_pass_scroll_events = false
		can_scroll = true

func _on_item_right_clicked(idx: int) -> void: # does not work as intended with context menus because the menu eats the input and no release is detected
	#print("Index %s right clicked" % idx)
	pass

func _on_mouse_entered() -> void:
	pass

func _on_mouse_exited() -> void:
	if can_grab_scroll_focus:
		if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
			_release_focus()

func _release_focus():
	mouse_force_pass_scroll_events = true
	can_scroll = false
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "custom_minimum_size", initial_custom_minimum_size, stretch_focus_duration)





#
