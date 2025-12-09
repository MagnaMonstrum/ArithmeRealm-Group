extends StaticBody2D

class_name LootNumNode

@export var loot_num_resource: LootNumResource
@onready var label: Label = $Area2D/Label

var current_value: int

var loot_num_paths = {
	0: "res://project/scripts/inventory/LootNums/0zero.tres",
	1: "res://project/scripts/inventory/LootNums/1one.tres",
	2: "res://project/scripts/inventory/LootNums/2two.tres",
	3: "res://project/scripts/inventory/LootNums/3three.tres",
	4: "res://project/scripts/inventory/LootNums/4four.tres",
	5: "res://project/scripts/inventory/LootNums/5five.tres",
	6: "res://project/scripts/inventory/LootNums/6six.tres",
	7: "res://project/scripts/inventory/LootNums/7seven.tres",
	8: "res://project/scripts/inventory/LootNums/8eight.tres",
	9: "res://project/scripts/inventory/LootNums/9nine.tres"
}

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

# signal give_loot(loot_num_item: LootNumResource)

# @onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_loot_num_item(num_loot_value: int) -> void:
	print(num_loot_value)
	var res := LootNumResource.new()
	res.value = num_loot_value

	print("res ", res) # should NOT be null

	loot_num_resource = res
	print("resource is ready")

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("player entered")
	if loot_num_resource:
		print("value ", loot_num_resource.value)
		if body is Player:
			body.collect(loot_num_resource)
			queue_free()
