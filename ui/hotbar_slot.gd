extends Panel

@onready var slot_label: Label = $SlotLabel
@onready var item_icon: ColorRect = $ItemIcon

func set_slot_number(number: int) -> void:
	slot_label.text = str(number)

func set_filled(is_filled: bool) -> void:
	item_icon.visible = is_filled

func set_selected(is_selected: bool) -> void:
	# Highlight the panel if this is the active slot
	if is_selected:
		modulate = Color(1.5, 1.5, 1.5)  # brighten
	else:
		modulate = Color(1, 1, 1)  # normal
