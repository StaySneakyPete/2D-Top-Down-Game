extends CharacterBody2D

@export var speed: float = 200.0
@onready var weapon_slot: Node2D = $WeaponSlot
@export var max_health: int = 100
@export var starting_item: Item

var health: int
var current_slot: int = 0
var current_weapon: WeaponBase = null
var inventory: Array = []  # each slot: {"item": Item, "count": int} or null
var held_slot: int = -1
const INVENTORY_SIZE: int = 29
const HOTBAR_SIZE: int = 9

signal inventory_changed(inventory: Array, current_slot: int, held_slot: int)

func _ready() -> void:
	health = max_health
	_ready_inventory()
	if starting_item:
		inventory[0] = {"item": starting_item, "count": 1}
	select_slot(0)

func _ready_inventory() -> void:
	for i in range(INVENTORY_SIZE):
		inventory.append(null)

func add_item(item: Item, amount: int = 1) -> bool:
	for slot in inventory:
		if slot != null and slot["item"] == item and slot["count"] < item.max_stack:
			var space = item.max_stack - slot["count"]
			var to_add = min(space, amount)
			slot["count"] += to_add
			amount -= to_add
			if amount <= 0:
				inventory_changed.emit(inventory, current_slot, held_slot)
				return true

	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = {"item": item, "count": amount}
			inventory_changed.emit(inventory, current_slot, held_slot)
			return true

	return false

func select_slot(slot: int) -> void:
	current_slot = slot
	var slot_data = inventory[slot]

	if current_weapon:
		current_weapon.queue_free()
		current_weapon = null

	if slot_data != null and slot_data["item"].is_weapon:
		current_weapon = slot_data["item"].weapon_scene.instantiate()
		weapon_slot.add_child(current_weapon)

	inventory_changed.emit(inventory, current_slot, held_slot)

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()

func _process(delta: float) -> void:
	var aim_dir = (get_global_mouse_position() - global_position).normalized()
	weapon_slot.rotation = aim_dir.angle()

	if Input.is_action_pressed("fire") and current_weapon and get_viewport().gui_get_hovered_control() == null:
		current_weapon.attack(aim_dir)

	for i in range(HOTBAR_SIZE):
		if Input.is_action_just_pressed("hotbar_" + str(i + 1)):
			select_slot(i)

	if Input.is_action_just_pressed("scroll_up"):
		select_slot((current_slot - 1 + HOTBAR_SIZE) % HOTBAR_SIZE)
	if Input.is_action_just_pressed("scroll_down"):
		select_slot((current_slot + 1) % HOTBAR_SIZE)

func take_damage(amount: int) -> void:
	health -= amount
	print("Player health: ", health)
	if health <= 0:
		print("Player died!")

func on_slot_clicked(index: int) -> void:
	if held_slot == -1:
		if inventory[index] != null:
			held_slot = index
	else:
		var temp = inventory[index]
		inventory[index] = inventory[held_slot]
		inventory[held_slot] = temp
		held_slot = -1

		if current_slot < HOTBAR_SIZE:
			select_slot(current_slot)

	inventory_changed.emit(inventory, current_slot, held_slot)

func can_craft(recipe: Recipe) -> bool:
	for i in range(recipe.ingredient_items.size()):
		var needed_item = recipe.ingredient_items[i]
		var needed_amount = recipe.ingredient_amounts[i]
		if count_item(needed_item) < needed_amount:
			return false
	return true

func count_item(item: Item) -> int:
	var total = 0
	for slot in inventory:
		if slot != null and slot["item"] == item:
			total += slot["count"]
	return total

func remove_item(item: Item, amount: int) -> void:
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["item"] == item:
			var take = min(inventory[i]["count"], amount)
			inventory[i]["count"] -= take
			amount -= take
			if inventory[i]["count"] <= 0:
				inventory[i] = null
			if amount <= 0:
				break
	inventory_changed.emit(inventory, current_slot, held_slot)

func craft(recipe: Recipe) -> bool:
	if not can_craft(recipe):
		return false
	for i in range(recipe.ingredient_items.size()):
		remove_item(recipe.ingredient_items[i], recipe.ingredient_amounts[i])
	add_item(recipe.result_item, recipe.result_amount)
	return true
