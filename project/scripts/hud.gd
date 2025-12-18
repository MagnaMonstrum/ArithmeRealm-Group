extends Control

# HUD controller that displays player health and other UI elements

@onready var health_bar = $CanvasLayer/PlayerHealth/ProgressBar
@onready var health_label = $CanvasLayer/PlayerHealth/Label

func _ready() -> void:
	# Ensure HUD processes during pause if needed
	process_mode = Node.PROCESS_MODE_ALWAYS

func update_health(current_health: int, max_health: int) -> void:
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
	
	if health_label:
		health_label.text = "HP: %d/%d" % [current_health, max_health]
