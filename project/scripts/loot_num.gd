extends StaticBody2D

class_name LootNumNode

@export var loot_num_resource: LootNumResource
@onready var label: Label = $Area2D/Label

# signal give_loot(loot_num_item: LootNumResource)

# @onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_loot_num_item(num_loot_value: int) -> void:
	var res := LootNumResource.new()
	res.value = num_loot_value

	loot_num_resource = res

func _on_area_2d_body_entered(body: Node2D) -> void:
	if loot_num_resource:
		if body is Player:
			body.collect(loot_num_resource)
			queue_free()
