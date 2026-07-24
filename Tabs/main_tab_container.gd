extends TabContainer
class_name MainTabContainer

func _ready() -> void:
	
	current_tab = 0
	Global.main_tab_container = self
	
	#var childs: Array[Node] = get_children()
	#for index in range(childs.size()):
		#var child: Node = childs[index]
		##child.set("index", index)
		#if child.has_method("_on_tab_changed"):
			#tab_changed.connect(func(tab: int): child._on_tab_changed())
	## might use visibility notifier
	
	tab_changed.connect(_on_tab_changed)
	_initialize.call_deferred()

func _initialize() -> void:
	pass

func _on_tab_changed(tab: int):
	pass
