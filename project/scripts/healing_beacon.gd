extends Node2D

const ChestUiScene := preload("res://project/scenes/chest_ui.tscn")

@onready var interactable := $Interactable
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var static_body: StaticBody2D = $StaticBody2D
@onready var static_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D

@export var int_A: int
@export var int_B: int
var problem_data: Dictionary = {}

var chest_ui: Control
var target_answer: int = 0
var is_used := false
var is_fading := false
var incorrect_guesses := 0

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:		
	interactable.interact = _on_interact
	interactable.interaction_name = "Use Healing Beacon"
	rng.randomize()
	generate_problem()

func _process(_delta: float) -> void:
	if is_used or is_fading:
		return
	
	# Update interactability based on player health
	var player = get_tree().current_scene.get_node_or_null("Player")
	if player:
		interactable.is_interactable = player.current_health < player.max_health
	else:
		interactable.is_interactable = true

func _on_interact() -> void:
	if is_used or is_fading:
		return
	
	# Check if player is at full health
	var player = get_tree().current_scene.get_node_or_null("Player")
	if player and player.current_health >= player.max_health:
		return # Can't use beacon at full health
	
	if !is_instance_valid(chest_ui):
		chest_ui = ChestUiScene.instantiate()
		chest_ui.top_level = true
		var target_parent = get_tree().current_scene if get_tree().current_scene else get_tree().root
		target_parent.add_child(chest_ui)

	if !chest_ui.is_node_ready():
		await chest_ui.ready
	
	chest_ui.open(self, problem_data)

func generate_problem() -> void:
	problem_data = ProblemGenerator.make_problem(Global.current_level, -1, "healing_beacon")
	int_A = problem_data.get("a", rng.randi_range(1, 9))
	int_B = problem_data.get("b", rng.randi_range(1, 9))
	target_answer = problem_data.get("answer", int_A + int_B)

func on_correct_answer() -> void:
	if is_used or is_fading:
		return
	is_used = true
	is_fading = true
	
	# Heal the player (current health + 25% of max health)
	var player = get_tree().current_scene.get_node_or_null("Player")
	if player and player.has_method("heal"):
		var heal_amount := int(player.max_health * 0.25)
		player.heal(heal_amount)
	
	# Disable collisions while fading away
	if static_collision:
		static_collision.disabled = true
	if interactable:
		interactable.is_interactable = false
	
	# Fade away and disappear after correct answer
	animation_player.play("fade_away")
	await animation_player.animation_finished
	queue_free()

func on_wrong_answer() -> void:
	incorrect_guesses += 1
	
	if incorrect_guesses >= 3:
		# Too many wrong answers - fade away without healing
		if is_fading:
			return
		is_fading = true
		
		# Disable collisions while fading away
		if static_collision:
			static_collision.disabled = true
		if interactable:
			interactable.is_interactable = false
		
		# Fade away and disappear
		animation_player.play("fade_away")
		await animation_player.animation_finished
		queue_free()
	else:
		# Generate a new problem for the player to try again
		generate_problem()
