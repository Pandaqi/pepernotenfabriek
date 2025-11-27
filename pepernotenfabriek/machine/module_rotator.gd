extends Node2D
class_name ModuleRotator

@onready var entity = get_parent()
@export var rotate_speed := 0.05

func _physics_process(delta: float) -> void:
	entity.rotate(delta * rotate_speed)
