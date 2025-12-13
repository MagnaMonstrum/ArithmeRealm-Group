extends Resource

class_name Inv

signal update_signal

var inv_size := 9

@export var slots: Array[InvSlot]
func insert(value: int) -> void:
	for i in range(inv_size):
		if slots[i].value == -1:
			slots[i].value = value
			slots[i].amount += 1
			break
		elif slots[i].value == value:
			slots[i].amount += 1
			break

	emit_signal("update_signal", slots)


# this function is used to provide the values of the current inventory. Currently only AddBlob is uses it.
func get_items() -> Array: 
	var values = []
	
	for i in range(len(slots)):
		values.append(slots[i].value)

	return values
