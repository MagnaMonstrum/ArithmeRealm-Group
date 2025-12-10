extends Resource

class_name Inv

signal update_signal

var inv_size := 9

@export var slots: Array[InvSlot]
func insert(value: int) -> void:
	for i in range(inv_size):
		if slots[i].value == -1:
			slots[i].value = value
			print(value)
			slots[i].amount += 1
			break
		elif slots[i].value == value:
			slots[i].amount += 1
			break

	emit_signal("update_signal", slots)
