extends Node2D
class_name ModuleRotator

@export var entity : Node2D
@export var rotate_speed := 0.05

func _physics_process(delta: float) -> void:
	entity.rotate(delta * rotate_speed)
