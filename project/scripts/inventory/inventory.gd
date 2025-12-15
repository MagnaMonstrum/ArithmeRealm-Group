extends Resource

class_name Inv

signal update_signal

@export var slots: Array[InvSlot]

func insert(value: int) -> bool:
	if not slots.any(func(slot): return slot.value == -1 or slot.value == value):
		return false

	for i in range(slots.size()):
		if slots[i].value == -1:
			slots[i].value = value
			slots[i].amount += 1
			return true
		elif slots[i].value == value:
			slots[i].amount += 1
			return true


	emit_signal("update_signal", slots)
	return false


# this function is used to provide the values of the current inventory. Currently only AddBlob is uses it.
func get_items() -> Array:
	var values = []

	for i in range(len(slots)):
		values.append(slots[i].value)

	return values
