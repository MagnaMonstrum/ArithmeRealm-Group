extends Node2D

@export var enemy_scene: PackedScene
@export var loot_num_resource: LootNumResource

var loot_num_scene = preload("res://project/scenes/loot_num.tscn")

@onready var player = $Player 
 
# signal loot_spawned(num: int)

var num_sprites_paths = {
	0: "res://art/sprites/numbers/0zero.png",
	1: "res://art/sprites/numbers/1one.png",
	2: "res://art/sprites/numbers/2two.png",
	3: "res://art/sprites/numbers/3three.png",
	4: "res://art/sprites/numbers/4four.png",
	5: "res://art/sprites/numbers/5five.png",
	6: "res://art/sprites/numbers/6six.png",
	7: "res://art/sprites/numbers/7seven.png",
	8: "res://art/sprites/numbers/8eight.png",
	9: "res://art/sprites/numbers/9nine.png"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_enemy()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_enemy() -> void:
	var spawn_0 = $EnemySpawnPoint
	# var spawn_1 = $EnemySpawnPoint2
	# var spawn_2 = $EnemySpawnPoint3
	
	var enemy_0 = enemy_scene.instantiate() 
	enemy_0.global_position = spawn_0.global_position
	add_child(enemy_0)
	enemy_0.drop_num.connect(self.spawn_loot_num)

func spawn_loot_num(pos: Vector2, num_loot: int) -> void:
	var loot_num_instance = loot_num_scene.instantiate()
	loot_num_instance.global_position = pos
	loot_num_instance.set_loot_num_item(num_loot)
	add_child(loot_num_instance)
	var sprite := loot_num_instance.get_node("Area2D").get_node("Sprite2D") as Sprite2D
	sprite.texture = load(num_sprites_paths[num_loot])

# func add_item_to_player(loot_num_resource):
	
