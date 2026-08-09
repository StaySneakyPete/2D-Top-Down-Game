extends CharacterBody2D

@export var speed: float = 200.0
@onready var weapon_slot: Node2D = $WeaponSlot
@export var max_health: int = 100
@export var starting_item: Item

var health: int
var current_slot: int = 0
var current_weapon: WeaponBase = null
var inventory: Array = []  # each slot: {"item": Item, "count": int} or null
const INVENTORY_SIZE: int = 29
const HOTBAR_SIZE: int = 9

signal inventory_changed(inventory: Array)

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
				inventory_changed.emit(inventory, current_slot)
				return true

	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = {"item": item, "count": amount}
			inventory_changed.emit(inventory, current_slot)
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

	inventory_changed.emit(inventory, current_slot)

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()

func _process(delta: float) -> void:
	var aim_dir = (get_global_mouse_position() - global_position).normalized()
	weapon_slot.rotation = aim_dir.angle()

	if Input.is_action_pressed("fire") and current_weapon:
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
