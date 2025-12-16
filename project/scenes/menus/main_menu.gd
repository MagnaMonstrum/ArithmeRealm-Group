extends Control

func _ready() -> void:
	%Play.pressed.connect(play)
	%Quit.pressed.connect(quit)

func play() -> void:
	get_tree().change_scene_to_file("res://project/scenes/add_blobs_map.tscn")

func quit() -> void:
	get_tree().quit()
