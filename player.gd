extends CharacterBody2D

@export var starting_weapon: PackedScene
@export var speed: float = 200.0
@onready var weapon_slot: Node2D = $WeaponSlot
var current_weapon: WeaponBase = null

func _ready() -> void:
	if starting_weapon:
		equip_weapon(starting_weapon)

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()

func _process(delta: float) -> void:
	var aim_dir = (get_global_mouse_position() - global_position).normalized()
	weapon_slot.rotation = aim_dir.angle()

	if Input.is_action_pressed("fire") and current_weapon:
		current_weapon.attack(aim_dir)

func equip_weapon(weapon_scene: PackedScene) -> void:
	if current_weapon:
		current_weapon.queue_free()
	current_weapon = weapon_scene.instantiate()
	weapon_slot.add_child(current_weapon)
