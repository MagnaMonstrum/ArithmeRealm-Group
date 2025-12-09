extends Panel

@onready var value_display: Label = %Value
@onready var amount_display: Label =  %Amount

func update(inv_slot: InvSlot):
	if inv_slot.value == -1:
		value_display.visible = false
		amount_display.visible = false
	else:
		value_display.visible = true
		value_display.text = str(inv_slot.value)
		amount_display.visible = true
		amount_display.text = str(inv_slot.amount)
