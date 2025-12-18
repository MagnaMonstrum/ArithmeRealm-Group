extends Node2D

const ProblemUiScene := preload("res://project/scenes/problem_ui.tscn")

@onready var player := get_tree().get_first_node_in_group("player")
@onready var interactable := $Interactable
@onready var timer = $Timer

@export var int_A: int
@export var int_B: int

signal request_inventory(blob: Node2D)

var problem_ui: Control

var curr_player_inv_values: Array

var num_sprites_paths = {
	0: "res://project/art/sprites/numbers/0zero.png",
	1: "res://project/art/sprites/numbers/1one.png",
	2: "res://project/art/sprites/numbers/2two.png",
	3: "res://project/art/sprites/numbers/3three.png",
	4: "res://project/art/sprites/numbers/4four.png",
	5: "res://project/art/sprites/numbers/5five.png",
	6: "res://project/art/sprites/numbers/6six.png",
	7: "res://project/art/sprites/numbers/7seven.png",
	8: "res://project/art/sprites/numbers/8eight.png",
	9: "res://project/art/sprites/numbers/9nine.png"
}

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:		
	interactable.interact = _on_interact
	set_A_and_B()

func _on_interact() -> void:
	# Requesting the player inventory, this signal is connected to the player via add_blobs_map
	emit_signal("request_inventory", self) 
	print("curr_inv: ", curr_player_inv_values)

	if !is_instance_valid(problem_ui):
		problem_ui = ProblemUiScene.instantiate()
		problem_ui.top_level = true # Avoid inheriting transforms/scale from the blob so the UI fills the viewport
		var target_parent = get_tree().current_scene if get_tree().current_scene else get_tree().root
		target_parent.add_child(problem_ui)
		
		var drop_receiver = problem_ui.get_node("DropReceiver")
		
		if player:
			drop_receiver.add_gem.connect(player._on_add_gem)

		print("Problem UI instanced and added")

	if !problem_ui.is_node_ready():
		await problem_ui.ready
	problem_ui.open(self, curr_player_inv_values)
	print("Problem UI open called")

func receive_inv_values(player_inv: Array) -> void:
	curr_player_inv_values = player_inv	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_A_and_B() -> void:
	int_A = rng.randi_range(0, 9)
	int_B = rng.randi_range(0, 9)

	var correct_answer = int_A + int_B
