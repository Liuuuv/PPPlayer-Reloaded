extends TabContainer
class_name MainTabContainer

func _ready() -> void:
	
	current_tab = 0
	
	_initialize.call_deferred()

func _initialize() -> void:
	Global.main_tab_container = self
