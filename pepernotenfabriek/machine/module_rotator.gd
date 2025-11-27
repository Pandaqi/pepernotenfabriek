extends Node2D
class_name ModuleRotator

@export var entity : Machine
@export var rotate_speed := 0.5
@export var rotate_speed_held := 5.0

func get_rotate_speed() -> float:
	if entity.is_button_held: return rotate_speed_held
	return rotate_speed

func _physics_process(delta: float) -> void:
	entity.rotate(delta * get_rotate_speed())
