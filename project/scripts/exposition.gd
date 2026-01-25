extends Control

func _ready() -> void:
	%Next.pressed.connect(Next)

func Next() -> void:
	get_tree().change_scene_to_file("res://project/scenes/levels/tutorial_level.tscn")
