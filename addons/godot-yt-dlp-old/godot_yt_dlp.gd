@tool
extends EditorPlugin


const AUTOLOAD_NAME = "YtDlpOLD"


func _enter_tree():
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/godot-yt-dlp-old/src/yt_dlp.gd")


func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)
