extends Panel

@onready var item_visual: Sprite2D = $CenterContainer/Panel/ItemDisplay
@onready var amount_display: Label = $CenterContainer/Panel/Label

func update(inv_slot: InvSlot):
	if not inv_slot.loot_num:
		item_visual.visible = false
		amount_display.visible = false
	else:
		print("update inv ui slot")
		item_visual.visible = true
		amount_display.visible = true
		print("item_visual: ", item_visual.visible)
		print("amount_display: ", amount_display.visible)
		item_visual.texture = inv_slot.loot_num.texture
		amount_display.text = str(inv_slot.amount)
