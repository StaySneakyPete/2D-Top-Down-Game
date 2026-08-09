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
@onready var sprite: Sprite2D = $Sprite2D

var health: int
var player: Node2D = null
var can_attack: bool = true
var dir_textures: Dictionary = {}

func _ready() -> void:
	health = max_health
	player = get_tree().get_first_node_in_group("player")
	dir_textures = {
	"south": load("res://enemies/sprites/Golem/south.png"),
	"north": load("res://enemies/sprites/Golem/north.png"),
	"east": load("res://enemies/sprites/Golem/east.png"),
	"west": load("res://enemies/sprites/Golem/west.png"),
	"south_east": load("res://enemies/sprites/Golem/south-east.png"),
	"south_west": load("res://enemies/sprites/Golem/south-west.png"),
	"north_east": load("res://enemies/sprites/Golem/north-east.png"),
	"north_west": load("res://enemies/sprites/Golem/north-west.png"),
}

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
		update_sprite_direction(direction)
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

func update_sprite_direction(direction: Vector2) -> void:
	if direction.length() < 0.1:
		return  # not moving, keep current sprite

	var angle = direction.angle()
	var degrees = rad_to_deg(angle)
	if degrees < 0:
		degrees += 360

	var key = "south"
	if degrees >= 337.5 or degrees < 22.5:
		key = "east"
	elif degrees < 67.5:
		key = "south_east"
	elif degrees < 112.5:
		key = "south"
	elif degrees < 157.5:
		key = "south_west"
	elif degrees < 202.5:
		key = "west"
	elif degrees < 247.5:
		key = "north_west"
	elif degrees < 292.5:
		key = "north"
	elif degrees < 337.5:
		key = "north_east"

	sprite.texture = dir_textures[key]
