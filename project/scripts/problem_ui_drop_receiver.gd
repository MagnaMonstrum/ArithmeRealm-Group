extends Control

# Drag-and-drop input handler for the Problem UI.
# Responsibilities:
# - Spawn a visual drag label (via scene) that follows the cursor
# - Detect drag start from InvUI slots while paused
# - Validate drop over the blob and trigger correct/wrong handlers

# This script sits on the ProblemUI and handles all drag-drop logic

const DragLabelScene = preload("res:///scenes/drag_label.tscn")

var problem_ui: Control
var player: Node
var target_answer: int = 0
var dragged_value: int = -1
var dragged_slot_index: int = -1
var dragging := false
var mouse_was_pressed := false
var drag_label_instance: Control = null
var drag_label: Label = null

signal add_gem

func _ready() -> void:
	# Initialize references and create a dedicated CanvasLayer for the drag label
	problem_ui = get_parent() as Control
	mouse_filter = Control.MOUSE_FILTER_PASS # Allow clicks to pass through to children
	set_process(true)

	# Create a CanvasLayer for the drag label so it renders on top
	var canvas = CanvasLayer.new()
	canvas.layer = 1000 # High layer number to be on top
	get_tree().root.add_child(canvas)

	# Instantiate the drag label scene
	drag_label_instance = DragLabelScene.instantiate()
	canvas.add_child(drag_label_instance)

	# Get the label node from the scene
	drag_label = drag_label_instance.get_node("Label")
	drag_label_instance.hide()

	# Store references so we can clean them up
	set_meta("drag_canvas", canvas)

func _process(delta: float) -> void:
	# Poll mouse state every frame; works reliably while the game tree is paused
	if not problem_ui or not problem_ui.visible:
		return

	var is_mouse_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var mouse_pos = get_global_mouse_position()

	# Update drag label position while dragging
	if dragging and drag_label_instance:
		# Since it's in a CanvasLayer, use viewport coordinates directly
		var viewport_mouse = get_viewport().get_mouse_position()
		drag_label_instance.position = viewport_mouse

	# Detect mouse button press (transition from not pressed to pressed)
	if is_mouse_pressed and not mouse_was_pressed:
		var slot_idx = _get_clicked_slot_index(mouse_pos)
		if slot_idx >= 0:
			player = get_tree().current_scene.get_node_or_null("Player")
			if player and player.inventory and slot_idx < player.inventory.slots.size():
				var slot = player.inventory.slots[slot_idx]
				if slot.value >= 0:
					# Begin drag from clicked inventory slot
					dragged_value = slot.value
					dragged_slot_index = slot_idx
					dragging = true

					# Show drag label with the number
					if drag_label:
						drag_label.text = str(dragged_value)
						drag_label_instance.show()

	# Detect mouse button release (transition from pressed to not pressed)
	if not is_mouse_pressed and mouse_was_pressed:
		if dragging and drag_label_instance:
			drag_label_instance.hide()
		if dragging and dragged_value >= 0:
			# Validate drop against blob bounds (in Control's local space)
			var canvas_layer = problem_ui.get_node_or_null("CanvasLayer")
			var blob_control = canvas_layer.get_node_or_null("Control")
			if blob_control:
				var blob = blob_control.get_node_or_null("AdditionBlob")
				if blob:
					var sprite = blob.get_node_or_null("Sprite2D")
					if sprite:
						# Get the blob's local position in the Control and its size
						var blob_local_pos = blob.position # Position relative to Control parent
						var texture = sprite.texture
						if texture:
							var texture_size = texture.get_size() * sprite.scale
							# The blob rect in Control's local space
							var blob_rect_local = Rect2(blob_local_pos - texture_size / 2, texture_size)

							# Convert mouse position to Control's local space
							var mouse_local = blob_control.get_local_mouse_position()

							if blob_rect_local.has_point(mouse_local):
								# Successful drop: compare value with target and handle
								target_answer = problem_ui.target_answer
								_handle_drop(dragged_value, dragged_slot_index)


		dragging = false
		dragged_value = -1
		dragged_slot_index = -1

	mouse_was_pressed = is_mouse_pressed

func _get_clicked_slot_index(pos: Vector2) -> int:
	# Hit-test InvUI grid using its local coordinate space
	var inv_ui = problem_ui.get_node_or_null("CanvasLayer/InvUI")
	if not inv_ui:
		return -1

	var grid = inv_ui.get_node_or_null("NinePatchRect/GridContainer")
	if not grid:
		return -1

	# Convert global mouse position to InvUI's local coordinate space
	var local_pos = inv_ui.get_local_mouse_position()

	for i in range(grid.get_child_count()):
		var slot = grid.get_child(i)
		if slot:
			var slot_rect = slot.get_rect()
			if slot_rect.has_point(local_pos):
				return i
	return -1

func _handle_drop(value: int, slot_idx: int) -> void:
	# Compare dragged value with generated target answer
	target_answer = problem_ui.target_answer

	if value == target_answer:
		_on_correct(slot_idx)
	else:
		_on_wrong()

func _on_correct(slot_idx: int) -> void:
	# Remove number from inventory and notify UI
	if player and player.inventory and slot_idx < player.inventory.slots.size():
		var slot = player.inventory.slots[slot_idx]

		# Consume Num from Player Inventory
		if slot.amount > 0:
			slot.amount -= 1
			if slot.amount == 0:
				slot.value = -1

		player.inventory.emit_signal("update_signal", player.inventory.slots)
		emit_signal("add_gem")

	# Play correct animation (if available) then close UI
	var blob = problem_ui.get_node_or_null("CanvasLayer/Control/AdditionBlob")
	if blob and blob.has_method("play_correct_animation"):
		await blob.play_correct_animation()
	else:
		await get_tree().create_timer(0.3).timeout

	problem_ui.close()

func _on_wrong() -> void:
	# Play wrong animation (if available); UI remains open
	var blob = problem_ui.get_node_or_null("CanvasLayer/Control/AdditionBlob")
	if blob and blob.has_method("play_wrong_animation"):
		await blob.play_wrong_animation()

	# UI stays open

func _exit_tree() -> void:
	# Clean up the drag label and canvas when this node is freed
	if has_meta("drag_canvas"):
		var canvas = get_meta("drag_canvas")
		if is_instance_valid(canvas):
			canvas.queue_free()
