extends Area2D

@export var weapon_scene: PackedScene

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("add_to_hotbar"):
		var slot = body.find_empty_hotbar_slot()
		if slot != -1:
			body.add_to_hotbar(weapon_scene, slot)
			queue_free()
