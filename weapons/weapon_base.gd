extends Node2D
class_name WeaponBase

@export var cooldown: float = 0.3
var can_attack: bool = true

func attack(direction: Vector2) -> void:
	if not can_attack:
		return
	can_attack = false
	_do_attack(direction)
	await get_tree().create_timer(cooldown).timeout
	can_attack = true

func _do_attack(direction: Vector2) -> void:
	pass  # child scripts override this
