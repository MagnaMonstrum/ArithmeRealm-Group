extends Node2D

@onready var player = $Player
@onready var add_blob = $AdditionBlob

@export var max_enemies := 4
@export var loot_num_resource: LootNumResource
var loot_num_scene = preload("res://project/scenes/loot_num.tscn")
var current_enemy_count := 0

# signal loot_spawned(num: int)

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_blob.use_player_inv.connect(player.provide_loot_num_values)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func spawn_enemy() -> void:
	var new_mob = preload("res://project/scenes/enemy.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

	current_enemy_count += 1
	new_mob.tree_exited.connect(_on_enemy_removed)
	new_mob.drop_num.connect(spawn_loot_num)

func spawn_loot_num(pos: Vector2, num_loot: int) -> void:
	var loot_num_instance = loot_num_scene.instantiate()
	loot_num_instance.global_position = pos
	loot_num_instance.set_loot_num_item(num_loot)
	add_child(loot_num_instance)
	var sprite := loot_num_instance.get_node("Area2D").get_node("Label") as Label
	sprite.text = str(loot_num_instance.loot_num_resource.value)

func _on_enemy_removed() -> void:
	current_enemy_count -= 1

func _on_timer_timeout() -> void:
	if current_enemy_count < max_enemies:
		spawn_enemy()
