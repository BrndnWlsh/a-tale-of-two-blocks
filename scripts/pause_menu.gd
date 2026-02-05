extends VBoxContainer

const MAIN_MENU = preload("uid://cho6rbymnn3re")

func _on_resume_pressed() -> void:
	visible = false
	$"../CharacterBody3D".capture_mouse()

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
