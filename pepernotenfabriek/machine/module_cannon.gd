extends Node2D
class_name ModuleCannon

@export var entity : Machine
@export var map_data : MapData
var min_fire_speed := 200.0
var max_fire_speed := 2000.0
var max_held_time := 2000.0 # ms

func _ready() -> void:
	entity.released.connect(fire)

func get_shooting_dir() -> Vector2:
	return Vector2.from_angle(global_rotation)

func get_shooting_force(time_ratio:float) -> float:
	return lerp(min_fire_speed, max_fire_speed, time_ratio)

func get_shooting_vec(time_ratio:float) -> Vector2:
	return get_shooting_force(time_ratio) * get_shooting_dir()

func fire(time_held:float) -> void:
	var b := map_data.grab_bullet_from_pool()
	if not b: 
		map_data.out_of_bullets.emit()
		return
	
	var time_ratio : float = clamp(time_held / max_held_time, 0.0, 1.0)
	
	b.set_active(true, global_position)
	b.shoot(get_shooting_vec(time_ratio))
