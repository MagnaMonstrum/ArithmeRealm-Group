extends Control

func _ready() -> void:
	%Play.pressed.connect(play)

func play() -> void:
	get_tree().change_scene_to_file("res://project/scenes/levels/tutorial_level.tscn")
