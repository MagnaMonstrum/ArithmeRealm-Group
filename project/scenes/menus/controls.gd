extends Control

func _ready() -> void:
	%Back.pressed.connect(play)

func play() -> void:
	visible = false