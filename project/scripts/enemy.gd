extends CharacterBody2D
class_name Enemy

signal drop_num(pos: Vector2, num_loot: int)

@onready var player := get_tree().get_current_scene().get_node("Player")
@onready var animated_sprite = $AnimatedSprite2D


const SPEED := 20
var health_amount := 50
var health_amount_min := 0
var taking_damage := false

func _ready() -> void:
	player.hit_enemy.connect(self.take_damage)
	animated_sprite.play("default")


func _physics_process(delta: float) -> void:
	move()
	handle_death()

func move() -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 30.0
	move_and_slide()

func handle_death() -> void:
	var death_position = global_position
	var random_num = randi_range(0, 9)
	if health_amount <= health_amount_min:
		emit_signal("drop_num", death_position, random_num)

		queue_free()

func take_damage(dmg: int) -> void:
	health_amount -= dmg

# # placeholder until defeating enemy mechanic works
# func _on_timer_timeout() -> void:
# 	health_amount -= 10
