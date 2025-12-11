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
			break
		elif slots[i].value == value:
			slots[i].amount += 1
			break

	emit_signal("update_signal", slots)
	
	return true
