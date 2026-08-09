extends CharacterBody2D

signal died

@export var speed: float = 100.0
@export var max_health: int = 30
@export var damage: int = 10
@export var attack_range: float = 40.0
@export var detection_range: float = 500.0
@export var attack_cooldown: float = 1.0
@export var loot_scene: PackedScene
@export var item_pickup_scene: PackedScene
@export var possible_drops: Array[LootEntry] = []

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

	if distance <= attack_range:
		velocity = Vector2.ZERO
		if can_attack:
			attack_player()
	elif distance <= detection_range:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

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
	died.emit()
	if loot_scene:
		var loot = loot_scene.instantiate()
		get_tree().current_scene.call_deferred("add_child", loot)
		loot.global_position = global_position

	for entry in possible_drops:
		if entry.item and randf() <= entry.drop_chance:
			var pickup = item_pickup_scene.instantiate()
			pickup.item = entry.item
			pickup.amount = 1
			get_tree().current_scene.call_deferred("add_child", pickup)
			var offset = Vector2(randf_range(-12, 12), randf_range(-12, 12))
			pickup.global_position = global_position + offset

	queue_free()
