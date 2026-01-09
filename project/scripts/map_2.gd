extends Node2D

@onready var player = $Player
@onready var add_blob = $AdditionBlob
@onready var spawns = [
		%PathFollow2D_enemy1,
		%PathFollow2D_enemy2,
		%PathFollow2D_enemy3,
	]

@export var max_enemies := 3 # Maximum number of enemies at once
@export var spawn_interval := 4.5 # Time interval between spawns (seconds)
@export var safe_spawn_distance := 140.0 # Minimum distance to player when spawning
@export var loot_num_resource: LootNumResource
var loot_num_scene = preload("res:///scenes/loot_num.tscn")
var current_enemy_count := 0


# signal loot_spawned(num: int)

var num_sprites_paths = {
	0: "res:///art/sprites/numbers/0zero.png",
	1: "res:///art/sprites/numbers/1one.png",
	2: "res:///art/sprites/numbers/2two.png",
	3: "res:///art/sprites/numbers/3three.png",
	4: "res:///art/sprites/numbers/4four.png",
	5: "res:///art/sprites/numbers/5five.png",
	6: "res:///art/sprites/numbers/6six.png",
	7: "res:///art/sprites/numbers/7seven.png",
	8: "res:///art/sprites/numbers/8eight.png",
	9: "res:///art/sprites/numbers/9nine.png"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# When Player interacts with AddBlob a request is sent to Player to provide the invetory values.
	# This is so that the math problems the player gets are always solvable (for now this seems like the best for the game experience during the prototype).
	add_blob.request_inventory.connect(player.provide_loot_num_values)

	# Adjust spawn rate via the Timer in the scene
	var timer := get_node_or_null("Timer") as Timer
	if timer:
		timer.wait_time = spawn_interval


func spawn_enemy(path_follow: PathFollow2D) -> void:
	# Choose a spawn point along the path that isn't too close to the player.
	var tries := 6
	var spawn_pos := Vector2.ZERO
	var found_valid := false
	while tries > 0 and not found_valid:
		path_follow.progress_ratio = randf()
		spawn_pos = path_follow.global_position
		if not is_instance_valid(player) or spawn_pos.distance_to(player.global_position) >= safe_spawn_distance:
			found_valid = true
		else:
			tries -= 1

	if not found_valid:
		# Skip this cycle to avoid overwhelming the player nearby
		return

	var new_mob = preload("res:///scenes/enemy.tscn").instantiate()
	new_mob.global_position = spawn_pos
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
		for i in range(len(spawns)):
			spawn_enemy(spawns[i])


func _on_button_pressed() -> void:
	get_tree().paused = not get_tree().paused
	%Pause.visible = true
