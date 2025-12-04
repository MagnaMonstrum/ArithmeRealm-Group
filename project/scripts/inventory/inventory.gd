extends Resource

class_name Inv

signal update_signal


@export var slots: Array[InvSlot]

func insert(loot_num: LootNumResource) -> void:
	slots[loot_num.value].loot_num = loot_num
	slots[loot_num.value].amount += 1
	
	emit_signal("update_signal", slots)
