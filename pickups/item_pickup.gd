extends Area2D

@export var item: Item
@export var amount: int = 1

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("add_item"):
		if body.add_item(item, amount):
			queue_free()
