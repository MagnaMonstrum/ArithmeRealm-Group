extends Node

var player_in_enemy_area: bool = false
var gem_amount: int = 0

const MAX_LEVEL := 3
var current_level: int = 1

func set_level(level: int) -> void:
	current_level = clamp(level, 1, MAX_LEVEL)

func advance_level() -> void:
	set_level(current_level + 1)