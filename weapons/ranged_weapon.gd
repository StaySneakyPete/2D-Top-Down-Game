extends WeaponBase
class_name RangedWeapon

@export var bullet_scene: PackedScene
@onready var muzzle: Marker2D = $Muzzle

func _do_attack(direction: Vector2) -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.direction = direction
