extends Node


func set_cursor_image(alias: String):
	match alias:
		"arrow":
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		"hover":
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		"grab":
			Input.set_default_cursor_shape(Input.CURSOR_CAN_DROP)
		"invalid":
			Input.set_default_cursor_shape(Input.CURSOR_CROSS)
		"can_move":
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
