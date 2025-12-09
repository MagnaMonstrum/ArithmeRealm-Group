extends Area2D


@onready var timer = $Timer
@onready var display_A = $"Control Problem Holder/Control Num A/TR Num A"
@onready var display_B = $"Control Problem Holder/Control Num B/TR Num B"

@export var int_A: int
@export var int_B: int

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
	set_A_and_B()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_A_and_B() -> void:
	int_A = rng.randi_range(0, 9)
	int_B = rng.randi_range(0, 9)
	
	var correct_answer = int_A + int_B

	display_A.texture = load(num_sprites_paths[int_A])
	display_B.texture = load(num_sprites_paths[int_B])

	

# func _on_timer_timeout() -> void:
# 	set_A_and_B()
	
