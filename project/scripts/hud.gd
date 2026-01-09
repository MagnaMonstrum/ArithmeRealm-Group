extends Control

# HUD controller that displays player health and other UI elements

@onready var health_bar = $CanvasLayer/PlayerHealth/ProgressBar
@onready var health_label = $CanvasLayer/PlayerHealth/Label

@onready var gem_counter_label = $CanvasLayer/GemCounter/GemValue/Label

func _ready() -> void:
	# Ensure HUD processes during pause if needed
	process_mode = Node.PROCESS_MODE_ALWAYS

func update_health(current_health: int, max_health: int) -> void:
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

	if health_label:
		health_label.text = "HP: %d/%d" % [current_health, max_health]

func update_gem_counter(current_gem_amount: int) -> void:
	if gem_counter_label:
		gem_counter_label.text = str(current_gem_amount)

func show_spawn_alert() -> void:
	%SpawnAlert.visible = true
	await get_tree().create_timer(10.0).timeout
	%SpawnAlert.visible = false
