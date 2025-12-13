extends CharacterBody2D
class_name Player

@export var inventory: Inv

@onready var animated_sprite = $AnimatedSprite2D
@onready var damage_areaH = $DamagAreaH
@onready var damage_areaV = $DamagAreaV
@onready var damage_collisionH = $DamagAreaH.get_node("CollisionShape2D")
@onready var damage_collisionV = $DamagAreaV.get_node("CollisionShape2DV")
@onready var inv = $InvUI

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

var attack_damage = 10

enum facing_direction {WEST, EAST, NORTH, SOUTH}
var current_dir : int
var attacking := false
var attack_animations := ["attack_e", "attack_n", "attack_s"]

signal provide_inv(loot_num_values: Array)

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	set_direction()
	handle_movement()
	handle_attack()

func set_direction() -> void:
	if Input.is_action_pressed("left"):
		current_dir = facing_direction.WEST
		damage_areaH.scale.x = -1
	elif Input.is_action_pressed("right"):
		current_dir = facing_direction.EAST
		damage_areaH.scale.x = 1
	elif Input.is_action_pressed("up"):
		current_dir = facing_direction.NORTH
		damage_areaV.scale.y = -1
	elif Input.is_action_pressed("down"):
		damage_areaV.scale.y = 1
		current_dir = facing_direction.SOUTH

func handle_movement():
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	move_and_slide()

	if velocity and !attacking:
		match current_dir:
			facing_direction.WEST:
				animated_sprite.flip_h = true
				animated_sprite.play("walking_e")
			facing_direction.EAST:
				animated_sprite.flip_h = false
				animated_sprite.play("walking_e")
			facing_direction.NORTH:
				animated_sprite.play("walking_n")
			facing_direction.SOUTH:
				animated_sprite.play("walking_s")

	elif !velocity and !attacking:
		match current_dir:
			facing_direction.WEST:
				animated_sprite.flip_h = true
				animated_sprite.play("idle_e")
			facing_direction.EAST:
				animated_sprite.flip_h = false
				animated_sprite.play("idle_e")
			facing_direction.NORTH:
				animated_sprite.play("idle_n")
			facing_direction.SOUTH:
				animated_sprite.play("idle_s")

func handle_attack() -> void:
	if Input.is_action_just_pressed("attack"):
		attacking = true
		# Animations
		match current_dir:
			facing_direction.WEST:
				animated_sprite.flip_h = true
				animated_sprite.play("attack_e")
			facing_direction.EAST:
				animated_sprite.flip_h = false
				animated_sprite.play("attack_e")
			facing_direction.NORTH:
				animated_sprite.play("attack_n")
			facing_direction.SOUTH:
				animated_sprite.play("attack_s")

		# HitBox collision shapes
		damage_collisionH.disabled = false
		damage_collisionV.disabled = false

		await get_tree().create_timer(0.2).timeout

		damage_collisionH.disabled = true
		damage_collisionV.disabled = true

func collect(loot_num: LootNumResource) -> void:
	inventory.insert(loot_num.value)
	inv.update_slots(inventory.slots)

func _on_damage_area_entered(area:Area2D) -> void:
	if (area.get_parent().has_method("take_damage")):
		# print(area.get_parent().has_method("take_damage"))
		area.get_parent().take_damage(50)

func _on_animated_sprite_2d_animation_finished() -> void:
	attacking = false

func provide_loot_num_values(blob) -> void: # This function gives the inventory values to the blob.
	var inv_array := inventory.get_items()
	blob.receive_inv_values(inv_array)
