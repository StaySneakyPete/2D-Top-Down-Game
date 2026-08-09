extends CanvasLayer

@onready var grid: GridContainer = $Control/GridContainer
@export var slot_scene: PackedScene

var slot_nodes: Array = []
const HOTBAR_SIZE: int = 9

func _ready() -> void:
	for i in range(20):
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		slot_nodes.append(slot)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		visible = not visible

func update_inventory(inventory: Array, current_slot: int) -> void:
	for i in range(slot_nodes.size()):
		var slot_data = inventory[HOTBAR_SIZE + i]
		slot_nodes[i].set_filled(slot_data != null)

func _on_player_inventory_changed(inventory: Array, current_slot: int) -> void:
	update_inventory(inventory, current_slot)
