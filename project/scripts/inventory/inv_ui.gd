extends Control

@onready var inv: Inv = preload("res://project/scripts/inventory/inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inv.update_signal.connect(update_slots)
	update_slots(inv.slots)
	close()

func update_slots(invslots) -> void:
	for i in range(min(invslots.size(), slots.size())):
		slots[i].update(invslots[i])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_inv"):
		if is_open:
			close()
		else:
			open()

func open() -> void:
	visible = true
	is_open = true

func close() -> void:
	visible = false
	is_open = false
