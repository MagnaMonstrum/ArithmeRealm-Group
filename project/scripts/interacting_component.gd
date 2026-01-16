extends Node2D

@onready var interact_label := $InteractLabel

var current_interactions := []
var can_interact := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _clean_interactions() -> void:
	# Remove hidden or non-interactable items from the list
	var filtered = []
	for area in current_interactions:
		if area and area.is_visible_in_tree():
			if "is_interactable" in area and area.is_interactable:
				filtered.append(area)
	current_interactions = filtered

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		_clean_interactions()
		if current_interactions:
			var nearest = current_interactions[0]
			# Only interact if it's an actual interactable object
			if "interact" in nearest:
				can_interact = false
				interact_label.hide()

				await nearest.interact.call()

				can_interact = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_clean_interactions()
	
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sort_by_nearest)
		var nearest = current_interactions[0]
		interact_label.text = nearest.interaction_name
		interact_label.show()
	else:
		interact_label.hide()

func _sort_by_nearest(area1, area2):
	var area1_dist = global_position.distance_to(area1.global_position)
	var area2_dist = global_position.distance_to(area2.global_position)

	return area1_dist < area2_dist

func _on_interact_range_area_entered(area: Area2D) -> void:
	current_interactions.push_back(area)

func _on_interact_range_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)
