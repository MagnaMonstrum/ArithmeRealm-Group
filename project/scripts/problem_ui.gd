extends Control

# Controller for the math problem overlay.
# Handles open/close lifecycle, pausing, problem generation,
# inventory UI binding, and delegates drag/drop validation.

var blob : Node
var inventory : Array
var paused_before_open := false
var player : Node
var target_answer: int = 0
var dragged_slot_index: int = -1
var dragged_value: int = -1
var dragging := false
var drag_start_pos := Vector2.ZERO

@onready var addition_blob := $CanvasLayer/Control/AdditionBlob
@onready var inv_ui := $CanvasLayer/InvUI
var rng := RandomNumberGenerator.new()

func _ready():
	visible = false
	# Let UI process while the game is paused (2 == PROCESS_MODE_WHEN_PAUSED).
	process_mode = 2
	set_process_input(true)
	rng.randomize()

func open(blob, inventory):
	# Show overlay, pause gameplay, and bind references
	self.blob = blob
	self.inventory = inventory
	paused_before_open = get_tree().paused
	get_tree().paused = true

	# Get player reference for inventory manipulation
	player = get_tree().current_scene.get_node_or_null("Player")

	# Center UI elements in the current viewport so they're not off-screen.
	var viewport_size = get_viewport_rect().size

	if addition_blob:
		addition_blob.visible = true
		_set_problem_label()
		_make_blob_droppable()
	else:
		pass
	if inv_ui:
		# Bind UI to player's actual inventory resource
		if player and player.inventory:
			inv_ui.inv = player.inventory
		
		if inv_ui.has_method("open"):
			inv_ui.open()
			# Refresh UI slots from bound inventory
			if inv_ui.has_method("update_slots") and inv_ui.inv:
				inv_ui.update_slots(inv_ui.inv.slots)
				_make_slots_draggable()
		else:
			inv_ui.visible = true



	self.visible = true

func _set_problem_label() -> void:
	# Build and display a simple A + B sum that equals a target from inventory
	var label := addition_blob.get_node_or_null("Label") as Label
	if label == null:
		return

	var inv_values: Array[int] = []
	for v in inventory:
		if typeof(v) == TYPE_INT and v >= 0:
			inv_values.append(v)

	if inv_values.is_empty():
		# Fallback: show a simple 1+1
		label.text = "1 + 1"
		self.target_answer = 2
		return

	var target = inv_values[rng.randi_range(0, inv_values.size() - 1)]
	var problem := ProblemGenerator.make_problem(Global.current_level, target, "inventory")
	label.text = problem.get("label", "%d + %d" % [target, 0])

	# Store target for drag/drop validation
	self.target_answer = problem.get("answer", target)


func close():
	# Restore previous pause state and free the overlay
	get_tree().paused = paused_before_open
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	# Minimal input: ESC to close; legacy drag handled here but superseded by DropReceiver
	if event.is_action_pressed("ui_cancel"):
		close()
		accept_event()
	
	# Handle drag start on inventory slots
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_slot_idx = _get_clicked_slot_index(event.position)
		if clicked_slot_idx >= 0:
			dragged_slot_index = clicked_slot_idx
			if player and player.inventory and clicked_slot_idx < player.inventory.slots.size():
				var slot = player.inventory.slots[clicked_slot_idx]
				if slot.value >= 0:
					dragged_value = slot.value
					dragging = true
					drag_start_pos = event.position
					accept_event()
	
	# Handle drop on blob
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT and dragging:
		dragging = false
		var blob_rect = _get_blob_rect()
		if blob_rect and blob_rect.has_point(event.position) and dragged_value >= 0:
			_handle_drop(dragged_value, dragged_slot_index)
			accept_event()
		dragged_value = -1
		dragged_slot_index = -1

func _get_clicked_slot_index(pos: Vector2) -> int:
	if not inv_ui:
		return -1
	var grid = inv_ui.get_node_or_null("NinePatchRect/GridContainer")
	if not grid:
		return -1
	
	for i in range(grid.get_child_count()):
		var slot_ui = grid.get_child(i)
		if slot_ui and slot_ui.get_global_rect().has_point(pos):
			return i
	return -1

func _get_blob_rect() -> Rect2:
	if not addition_blob:
		return Rect2()
	return addition_blob.get_global_rect()

func _make_slots_draggable() -> void:
	# Slots are now handled in _unhandled_input
	pass

func _on_slot_gui_input(event: InputEvent, slot_index: int, slot_ui: Control) -> void:
	# No longer used
	pass

func _make_blob_droppable() -> void:
	if not addition_blob:
		return
	# Blob is handled in _unhandled_input now
	pass

func _on_blob_gui_input(event: InputEvent) -> void:
	# No longer used
	pass

func _handle_drop(value: int, slot_index: int) -> void:
	if value == target_answer:
		# Correct answer
		_on_correct_answer(slot_index)
	else:
		# Wrong answer
		_on_wrong_answer()

func _on_correct_answer(slot_index: int) -> void:
	# Remove the number from inventory
	if player and player.inventory and slot_index < player.inventory.slots.size():
		var slot = player.inventory.slots[slot_index]
		if slot.amount > 0:
			slot.amount -= 1
			if slot.amount == 0:
				slot.value = -1
		player.inventory.emit_signal("update_signal", player.inventory.slots)
	
	# Play correct animation (placeholder for future AnimatedSprite2D)
	if addition_blob.has_method("play_correct_animation"):
		await addition_blob.play_correct_animation()
	else:
		# Temporary: just wait a bit before closing
		await get_tree().create_timer(0.5).timeout
	
	# Close the problem UI
	close()

func _on_wrong_answer() -> void:
	# Play wrong animation (placeholder for future AnimatedSprite2D)
	if addition_blob.has_method("play_wrong_animation"):
		await addition_blob.play_wrong_animation()
	
	# UI stays open, player can try again
	dragged_value = -1
	dragged_slot_index = -1
