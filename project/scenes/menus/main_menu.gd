extends Control

func _ready() -> void:
	%Play.pressed.connect(play)
	%Quit.pressed.connect(quit)

func play() -> void:
	get_tree().change_scene_to_file("res:///scenes/levels/tutorial_level.tscn")

func quit() -> void:
	get_tree().quit()
