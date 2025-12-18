extends CharacterBody2D
class_name Player

@export var inventory: Inv

@onready var animated_sprite = $AnimatedSprite2D
@onready var damage_areaH = $DamagAreaH
@onready var damage_areaV = $DamagAreaV
@onready var damage_collisionH = $DamagAreaH.get_node("CollisionShape2D")
@onready var damage_collisionV = $DamagAreaV.get_node("CollisionShape2DV")
@onready var inv = $InvUI
@onready var hud = $Hud

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

# Health system
var max_health := 100
var current_health := 100
var is_invincible := false
var invincibility_duration := 0.5  # seconds of invincibility after taking damage

var attack_damage = 10

signal health_changed(current_health: int, max_health: int)
signal player_died

enum facing_direction {WEST, EAST, NORTH, SOUTH}
var current_dir : int
var attacking := false
var attack_animations := ["attack_e", "attack_n", "attack_s"]

signal provide_inv(loot_num_values: Array)

func _ready() -> void:
	print("Player _ready called for: ", self.name)
	# Add player to group "player" for identification in the world
	add_to_group("player")
	
	# Initialize health and update HUD
	current_health = max_health
	if hud and hud.has_method("update_health"):
		hud.update_health(current_health, max_health)
	
	# Connect health signal if HUD exists
	if hud:
		health_changed.connect(_on_health_changed)

func _physics_process(_delta: float) -> void:
	if current_health <= 0:
		return  # Don't process if dead
		
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

func collect(loot_num: LootNumResource) -> bool:
	var successful = inventory.insert(loot_num.value)
	inv.update_slots(inventory.slots)
	return successful

func _on_damage_area_entered(area:Area2D) -> void:
	if (area.get_parent().has_method("take_damage")):
		# print(area.get_parent().has_method("take_damage"))
		area.get_parent().take_damage(50)

func _on_animated_sprite_2d_animation_finished() -> void:
	attacking = false

func provide_loot_num_values(blob) -> void: # This function gives the inventory values to the blob.
	var inv_array := inventory.get_items()
	blob.receive_inv_values(inv_array)

func take_damage(damage: int) -> void:
	# Player takes damage from enemies
	if is_invincible or current_health <= 0:
		return
	
	current_health = max(0, current_health - damage)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()
	else:
		# Brief invincibility after a hit (invincibility frames)
		is_invincible = true
		# Visual feedback: temporarily tint the sprite red
		animated_sprite.modulate = Color(1, 0.5, 0.5, 1)  # Red tint
		await get_tree().create_timer(invincibility_duration).timeout
		animated_sprite.modulate = Color(1, 1, 1, 1)  # Restore color
		is_invincible = false

func heal(amount: int) -> void:
	# Heal the player (clamped to max_health)
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func die() -> void:
	# Handle player death
	player_died.emit()
	velocity = Vector2.ZERO
	attacking = false
	
	# Play death animation if available, otherwise fade out
	if animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")
		await animated_sprite.animation_finished
	else:
		# Fade out effect
		var tween = create_tween()
		tween.tween_property(animated_sprite, "modulate:a", 0.0, 0.5)
		await tween.finished
	
	# Game over logic - you can expand this
	get_tree().reload_current_scene()

func _on_health_changed(health: int, max_hp: int) -> void:
	# Update HUD when health changes
	if hud and hud.has_method("update_health"):
		hud.update_health(health, max_hp)
