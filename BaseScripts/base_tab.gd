extends Control
class_name BaseTab

var parent_tab_container: TabContainer
var tab_index: int = -1

## Shows the tab by changing the tab index of its parents.
func force_show_tab() -> void:
	if parent_tab_container and tab_index != -1:
		parent_tab_container.current_tab = tab_index
