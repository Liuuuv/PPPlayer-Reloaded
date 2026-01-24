extends Node2D
class_name Main

#@onready var select_folder_dialog: FileDialog = %SelectFolderDialog

func _ready() -> void:
	Global.main = self
	
	
	
	#select_folder_dialog.dir_selected.connect(_on_select_folder_dialog_selected)
#
#func _on_select_folder_dialog_selected(dir: String):
	#print(dir)

func _process(delta: float) -> void:
	pass
	
	## CA MARCHE -v
	#if Input.is_action_just_pressed("debug"):
		#var image = DisplayServer.clipboard_get_image()
		#$UILayer/test.texture = ImageTexture.create_from_image(image)
	
	if Input.is_action_just_pressed("debug"):
		print("debug")
		print("noting to do")
