extends Control

func _ready() -> void:
	%Exit.pressed.connect(exit)
	process_mode = PROCESS_MODE_WHEN_PAUSED


func exit() -> void:
	get_tree().change_scene_to_file("res://project/scenes/menus/main_menu.tscn")