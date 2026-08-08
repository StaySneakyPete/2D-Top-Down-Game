extends CanvasLayer

@onready var slots_container: HBoxContainer = $HotbarContainer/Slots
@export var slot_scene: PackedScene
@onready var room_cleared_label: Label = $RoomClearedLabel

var slot_nodes: Array = []

func _ready() -> void:
	for i in range(9):
		var slot = slot_scene.instantiate()
		slots_container.add_child(slot)
		slot.set_slot_number(i + 1)
		slot_nodes.append(slot)

	print("Slots created: ", slot_nodes.size())

	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		update_hotbar(player.hotbar, player.current_slot)

func update_hotbar(hotbar: Array, current_slot: int) -> void:
	if slot_nodes.is_empty():
		return
	for i in range(hotbar.size()):
		slot_nodes[i].set_filled(hotbar[i] != null)
		slot_nodes[i].set_selected(i == current_slot)


func _on_player_hotbar_changed(hotbar: Array, current_slot: int) -> void:
	update_hotbar(hotbar, current_slot)

func show_room_cleared() -> void:
	room_cleared_label.visible = true


func _on_room_manager_room_cleared() -> void:
	show_room_cleared()
