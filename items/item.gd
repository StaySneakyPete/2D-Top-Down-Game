extends Resource
class_name Item

@export var item_name: String = ""
@export var icon: Texture2D
@export var max_stack: int = 99
@export var description: String = ""
@export var is_weapon: bool = false
@export var weapon_scene: PackedScene  # only used if is_weapon is true
@export var pickup_color: Color = Color.WHITE
