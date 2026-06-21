extends Control

func _ready() -> void:
	%Play.pressed.connect(play)
	%Practice.pressed.connect(practice)

func play() -> void:
	get_tree().change_scene_to_file("res://project/scenes/menus/exposition_screen.tscn")

func practice() -> void:
	get_tree().change_scene_to_file("res://project/scenes/levels/practice.tscn")
