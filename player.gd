extends CharacterBody2D

@export var speed: float = 200.0
@export var starting_weapon: PackedScene
@onready var weapon_slot: Node2D = $WeaponSlot
@export var max_health: int = 100

var health: int
var hotbar: Array[PackedScene] = [null, null, null, null, null, null, null, null, null]
var current_slot: int = 0
var current_weapon: WeaponBase = null

func _ready() -> void:
	health = max_health
	if starting_weapon:
		hotbar[0] = starting_weapon
	# temporary test fill — remove once pickups exist
	hotbar[1] = load("res://weapons/Sword.tscn")
	select_slot(0)

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()

func _process(delta: float) -> void:
	var aim_dir = (get_global_mouse_position() - global_position).normalized()
	weapon_slot.rotation = aim_dir.angle()

	if Input.is_action_pressed("fire") and current_weapon:
		current_weapon.attack(aim_dir)

	for i in range(9):
		if Input.is_action_just_pressed("hotbar_" + str(i + 1)):
			select_slot(i)

	if Input.is_action_just_pressed("scroll_up"):
		select_slot((current_slot - 1 + hotbar.size()) % hotbar.size())
	if Input.is_action_just_pressed("scroll_down"):
		select_slot((current_slot + 1) % hotbar.size())

func select_slot(slot: int) -> void:
	if hotbar[slot] == null:
		return  # empty slot, do nothing
	current_slot = slot
	equip_weapon(hotbar[slot])

func equip_weapon(weapon_scene: PackedScene) -> void:
	if current_weapon:
		current_weapon.queue_free()
	current_weapon = weapon_scene.instantiate()
	weapon_slot.add_child(current_weapon)

func add_to_hotbar(weapon_scene: PackedScene, slot: int) -> void:
	hotbar[slot] = weapon_scene

func take_damage(amount: int) -> void:
	health -= amount
	print("Player health: ", health)
	if health <= 0:
		print("Player died!")

func find_empty_hotbar_slot() -> int:
	for i in range(hotbar.size()):
		if hotbar[i] == null:
			return i
	return -1  # hotbar full
