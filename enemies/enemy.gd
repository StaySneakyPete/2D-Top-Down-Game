extends CharacterBody2D

@export var speed: float = 100.0
@export var max_health: int = 30
@export var damage: int = 10
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 1.0
@export var loot_scene: PackedScene

var health: int
var player: Node2D = null
var can_attack: bool = true

func _ready() -> void:
	health = max_health
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not player:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance > attack_range:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		if can_attack:
			attack_player()

func attack_player() -> void:
	can_attack = false
	if player.has_method("take_damage"):
		player.take_damage(damage)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy health: ", health)
	if health <= 0:
		die()

func die() -> void:
	if loot_scene:
		var loot = loot_scene.instantiate()
		get_tree().current_scene.add_child(loot)
		loot.global_position = global_position
	queue_free()
