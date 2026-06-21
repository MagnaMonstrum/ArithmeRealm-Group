extends Control

func _ready() -> void:
	%Back.pressed.connect(back)
	%Tutorial.pressed.connect(tutorial)
	%Level2.pressed.connect(level2)
	%Level3.pressed.connect(level3)

func back() -> void:
	get_tree().change_scene_to_file("res://project/scenes/menus/main_menu.tscn")

func tutorial() -> void:
	get_tree().change_scene_to_file("res://project/scenes/levels/tutorial_level.tscn")

func level2() -> void:
	get_tree().change_scene_to_file("res://project/scenes/levels/level_2.tscn")

func level3() -> void:
	get_tree().change_scene_to_file("res://project/scenes/levels/level_3.tscn")
