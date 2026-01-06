class_name Enemy
extends CharacterBody2D

signal drop_num(pos: Vector2, num_loot: int)

@onready var enemy_health_bar = $EnemyHealth/ProgressBar
@onready var player := get_tree().get_current_scene().get_node("Player")
@onready var animated_sprite = $AnimatedSprite2D

const SPEED := 18
var max_health = 100
var current_health = 100
var taking_damage := false
var attack_damage := 6 # Damage dealt to player on collision
var attack_cooldown := 1.6 # Time between attacks
var can_attack := true
var attacking := false
var player_in_range := false
var attack_windup := 0.5 # Delay before damage is applied
var hitstun_duration := 0.4
var knockback: Vector2 = Vector2.ZERO
var knockback_decay := 10.0

func _ready() -> void:
	update_health(max_health, max_health)
	# Ensure enemy is on correct collision layer (layer 3)
	collision_layer = 3
	collision_mask = 3

	animated_sprite.play("default")
	# Connect HurtBox signals to detect player proximity
	var hurtbox = get_node_or_null("HurtBox")
	if hurtbox:
		hurtbox.body_entered.connect(_on_hurtbox_body_entered)
		hurtbox.body_exited.connect(_on_hurtbox_body_exited)


func _physics_process(_delta: float) -> void:
	if Global.player_in_enemy_area:
		move()
	handle_death()

	# Apply knockback decay
	if knockback.length() > 0.1:
		velocity += knockback
		knockback = knockback.move_toward(Vector2.ZERO, knockback_decay * _delta)

	# Trigger attack if conditions met
	if player_in_range and can_attack and not attacking:
		_attacking_sequence()

func move() -> void:
	# Simple chase towards the player, speed via constant
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * SPEED
	move_and_slide()

func handle_death() -> void:
	var death_position = global_position
	var random_num = randi_range(0, 100)
	if current_health <= 0:
		emit_signal("drop_num", death_position, random_num)

		queue_free()

func take_damage(dmg: int) -> void:
	current_health -= dmg
	update_health(current_health, max_health)
	# Brief hitstun and knockback to prevent instant mutual hits
	can_attack = false
	attacking = false
	if player:
		var away = (global_position - player.global_position).normalized()
		knockback = away * 120.0
	await get_tree().create_timer(hitstun_duration).timeout
	can_attack = true

func _on_hurtbox_body_entered(body: Node2D) -> void:
	# Track player proximity; actual damage is applied after windup
	if body.is_in_group("player"):
		player_in_range = true

func _on_hurtbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _attacking_sequence() -> void:
	attacking = true
	# Attack has a windup (telegraph) before applying damage
	await get_tree().create_timer(attack_windup).timeout
	if player_in_range and can_attack and is_instance_valid(player):
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)
			can_attack = false
			# Wait for cooldown before the next attack
			await get_tree().create_timer(attack_cooldown).timeout
			can_attack = true
	attacking = false

func update_health(current_health: int, max_health: int) -> void:
	if enemy_health_bar:
		enemy_health_bar.max_value = max_health
		enemy_health_bar.value = current_health


# # placeholder until defeating enemy mechanic works
# func _on_timer_timeout() -> void:
# 	health_amount -= 10
