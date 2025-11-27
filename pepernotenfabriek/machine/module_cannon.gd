extends Node2D
class_name ModuleCannon

@export var map_data : MapData

func _input(ev:InputEvent) -> void:
	if ev.is_action_released("ui_accept"):
		fire()

func get_shooting_dir() -> Vector2:
	return Vector2.from_angle(global_rotation)

func get_shooting_force() -> float:
	return 200.0

func get_shooting_vec() -> Vector2:
	return get_shooting_force() * get_shooting_dir()

func fire() -> void:
	var b := map_data.grab_bullet_from_pool()
	if not b: return
	
	b.set_active(true, global_position)
	b.shoot(get_shooting_vec())
