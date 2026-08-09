extends CanvasLayer

@onready var slots_container: HBoxContainer = $HotbarContainer/Slots
@onready var room_cleared_label: Label = $RoomClearedLabel
@export var slot_scene: PackedScene

var slot_nodes: Array = []
const HOTBAR_SIZE: int = 9

func _ready() -> void:
	for i in range(HOTBAR_SIZE):
		var slot = slot_scene.instantiate()
		slots_container.add_child(slot)
		slot.set_slot_number(i + 1)
		slot_nodes.append(slot)

	print("Slots created: ", slot_nodes.size())

	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		update_hotbar(player.inventory, player.current_slot)

func update_hotbar(inventory: Array, current_slot: int) -> void:
	if slot_nodes.is_empty():
		return
	for i in range(HOTBAR_SIZE):
		slot_nodes[i].set_filled(inventory[i] != null)
		slot_nodes[i].set_selected(i == current_slot)

func _on_player_inventory_changed(inventory: Array, current_slot: int) -> void:
	update_hotbar(inventory, current_slot)

func show_room_cleared() -> void:
	room_cleared_label.visible = true
