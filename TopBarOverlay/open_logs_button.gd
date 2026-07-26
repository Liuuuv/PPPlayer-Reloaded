extends ButtonComponent

var context_menu: ContextMenu

func _ready() -> void:
	super()
	_initialize_context_menu()

func _pressed() -> void:
	Global.logs_display.open()

func _initialize_context_menu():
	context_menu = ContextMenu.new()
	
	
	context_menu.attach_to(self)
	context_menu.set_minimum_size(Vector2i(400, 0))
	#context_menu.add_placeholder_item("%s" % _get_selected_idx(), true, null)
	context_menu.add_header_item("Logs", null)
	context_menu.add_item("Clear logs", _clear_logs, false, null)

	context_menu.connect_to(self)

func _clear_logs() -> void:
	Global.logs_display.clear_logs()
