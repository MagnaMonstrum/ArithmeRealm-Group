extends Control

func _ready() -> void:
	%Play.pressed.connect(play)
	%Quit.pressed.connect(quit)

func play() -> void:
	get_tree().change_scene_to_file("res://project/scenes/levels/map2.tscn")

func quit() -> void:
	get_tree().quit()
