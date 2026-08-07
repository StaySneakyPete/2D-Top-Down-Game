extends WeaponBase
class_name MeleeWeapon

@export var hitbox: Area2D
@export var swing_time: float = 0.15
@export var damage: int = 15

func _do_attack(direction: Vector2) -> void:
	rotation = direction.angle()
	hitbox.monitoring = true
	await get_tree().create_timer(swing_time).timeout
	hitbox.monitoring = false


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
