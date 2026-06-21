extends Node2D

const ParityQuizUiScene := preload("res://project/scenes/parity_quiz_ui.tscn")

@onready var interactable := $Interactable

var quiz_ui: Control

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact() -> void:
	if not is_instance_valid(quiz_ui):
		quiz_ui = ParityQuizUiScene.instantiate()
		quiz_ui.top_level = true

		var target_parent = get_tree().current_scene if get_tree().current_scene else get_tree().root
		target_parent.add_child(quiz_ui)

		var player = get_tree().get_first_node_in_group("player")
		if player and quiz_ui.has_signal("add_gem"):
			quiz_ui.add_gem.connect(player._on_add_gem)
		if quiz_ui.has_signal("solved"):
			quiz_ui.solved.connect(_on_quiz_solved, CONNECT_ONE_SHOT)

	if not quiz_ui.is_node_ready():
		await quiz_ui.ready
	quiz_ui.open()

func _on_quiz_solved() -> void:
	queue_free()
