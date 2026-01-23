extends Node2D

@export var BuyScene: PackedScene
@onready var InteractableBuy := $InteractableBuy

var player: Node
@export var gem_price = 10

func _ready() -> void:
	%CostLabel.text = "Dat kost je: " + str(gem_price) + " gems!"
	player = get_tree().current_scene.get_node_or_null("Player")

	process_mode = PROCESS_MODE_WHEN_PAUSED

	InteractableBuy.interact = _on_interact

func _on_interact() -> void:
	%BuyMenu.visible = true
	get_tree().paused = true


func _on_no_pressed() -> void:
	%BuyMenu.visible = false
	get_tree().paused = false

func _on_yes_pressed() -> void:
	if Global.gem_amount >= gem_price:
		player._on_remove_gems(gem_price)
		Global.advance_level()
		get_tree().paused = false
		get_tree().change_scene_to_packed(BuyScene)
