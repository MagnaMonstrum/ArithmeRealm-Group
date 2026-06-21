extends Control

func _ready() -> void:
	%Exit.pressed.connect(exit)


func exit() -> void:
	get_tree().change_scene_to_file("res://project/scenes/menus/main_menu.tscn")