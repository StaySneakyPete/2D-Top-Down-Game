extends CanvasLayer

@onready var grid: GridContainer = $Control/GridContainer
@onready var recipe_list: VBoxContainer = $Control/RecipeList
@export var slot_scene: PackedScene
@export var recipe_button_scene: PackedScene
@export var recipes: Array[Recipe] = []

var slot_nodes: Array = []
const HOTBAR_SIZE: int = 9

func _ready() -> void:
	for i in range(20):
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		slot.slot_index = HOTBAR_SIZE + i
		slot.slot_clicked.connect(_on_slot_clicked)
		slot_nodes.append(slot)

	for recipe in recipes:
		var btn = recipe_button_scene.instantiate()
		btn.text = "Craft " + recipe.result_item.item_name
		btn.pressed.connect(_on_recipe_pressed.bind(recipe))
		recipe_list.add_child(btn)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		visible = not visible

func update_inventory(inventory: Array, current_slot: int, held_slot: int) -> void:
	for i in range(slot_nodes.size()):
		var real_index = HOTBAR_SIZE + i
		var slot_data = inventory[real_index]
		slot_nodes[i].set_filled(slot_data != null)
		slot_nodes[i].set_held(real_index == held_slot)

func _on_player_inventory_changed(inventory: Array, current_slot: int, held_slot: int) -> void:
	update_inventory(inventory, current_slot, held_slot)

func _on_slot_clicked(index: int) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.on_slot_clicked(index)

func _on_recipe_pressed(recipe: Recipe) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.craft(recipe)
