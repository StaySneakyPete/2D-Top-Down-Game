extends CanvasLayer

@onready var grid: GridContainer = $Control/GridContainer
@export var slot_scene: PackedScene  # reuse your hotbar_slot.tscn style, or make a similar one

var slot_nodes: Array = []

func _ready() -> void:
	for i in range(20):
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		slot_nodes.append(slot)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		visible = not visible

func update_inventory(inventory: Array) -> void:
	for i in range(inventory.size()):
		var slot_data = inventory[i]
		slot_nodes[i].set_filled(slot_data != null)

func _on_player_inventory_changed(inventory: Array) -> void:
	update_inventory(inventory)
