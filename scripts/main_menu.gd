extends VBoxContainer

const MAIN = preload("res://scenes/game.tscn")


func _on_new_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN)



func _on_quit_pressed() -> void:
	get_tree().quit()
