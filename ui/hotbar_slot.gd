extends Panel

@onready var slot_label: Label = $SlotLabel
@onready var item_icon: ColorRect = $ItemIcon

var slot_index: int = -1
var selected_state: bool = false
var held_state: bool = false


signal slot_clicked(index: int)

func set_slot_number(number: int) -> void:
	slot_label.text = str(number)

func set_filled(is_filled: bool) -> void:
	item_icon.visible = is_filled

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Slot clicked, index: ", slot_index)
		slot_clicked.emit(slot_index)

func set_selected(is_selected: bool) -> void:
	selected_state = is_selected
	_update_visual()

func set_held(is_held: bool) -> void:
	held_state = is_held
	_update_visual()

func _update_visual() -> void:
	if held_state:
		modulate = Color(1, 1, 0.4)  # yellow while held
	elif selected_state:
		modulate = Color(1.5, 1.5, 1.5)  # bright when active hotbar slot
	else:
		modulate = Color(1, 1, 1)  # normal
