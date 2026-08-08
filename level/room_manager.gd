extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_points: Array[Node2D] = []

signal room_cleared

var enemies_alive: int = 0

func _ready() -> void:
	spawn_enemies()

func spawn_enemies() -> void:
	for point in spawn_points:
		var enemy = enemy_scene.instantiate()
		get_tree().current_scene.call_deferred("add_child", enemy)
		enemy.global_position = point.global_position
		enemy.died.connect(_on_enemy_died)
		enemies_alive += 1

func _on_enemy_died() -> void:
	enemies_alive -= 1
	if enemies_alive <= 0:
		room_cleared.emit()
