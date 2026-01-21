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
var is_opened := false
var is_fading := false

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.interact = _on_interact
	interactable.interaction_name = "Druk op E om de kist te openen"
	rng.randomize()
	generate_problem()
	# Start with closed chest (frame 0)
	sprite.frame = 0

func _on_interact() -> void:
	if is_opened or is_fading:
		return

	if !is_instance_valid(chest_ui):
		chest_ui = ChestUiScene.instantiate()
		chest_ui.top_level = true
		var target_parent = get_tree().current_scene if get_tree().current_scene else get_tree().root
		target_parent.add_child(chest_ui)

	if !chest_ui.is_node_ready():
		await chest_ui.ready

	chest_ui.open(self, problem_data)

func generate_problem() -> void:
	problem_data = ProblemGenerator.make_problem(Global.current_level, -1, "chest")
	int_A = problem_data.get("a", rng.randi_range(1, 9))
	int_B = problem_data.get("b", rng.randi_range(1, 9))
	target_answer = problem_data.get("answer", int_A + int_B)

func on_correct_answer() -> void:
	if is_opened:
		return
	is_opened = true
	# Open the chest - change to frame 2
	sprite.frame = 2
	# Disable interaction when chest is open
	if interactable:
		interactable.is_interactable = false

func on_wrong_answer() -> void:
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
