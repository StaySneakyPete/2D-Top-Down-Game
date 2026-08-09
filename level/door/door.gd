extends StaticBody2D

@onready var visual: ColorRect = $ColorRect
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	lock()

func lock() -> void:
	collision.disabled = false
	visual.color = Color(0.6, 0.15, 0.15)  # locked = red

func unlock() -> void:
	collision.set_deferred("disabled", true)
	visual.color = Color(0.2, 0.6, 0.25)
	print("Trying deferred disable")

func _on_room_manager_room_cleared() -> void:
	unlock()
