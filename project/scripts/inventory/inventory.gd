extends Resource

class_name Inv

signal update_signal


@export var slots: Array[InvSlot] 
	
func insert(loot_num: LootNumResource) -> void:
	print("slots size:", slots.size())
	for i in range(slots.size()):
		if i == loot_num.value:
			slots[i].loot_num = loot_num
			slots[i].amount += 1
	
	emit_signal("update_signal")
