extends Node2D
class_name ModuleCannon

@export var entity : Machine
@export var rotation_node : Node2D
@export var map_data : MapData
var min_fire_speed := 200.0
var max_fire_speed := 2000.0
var max_held_time := 2000.0 # ms

@export var audio_player : AudioStreamPlayer2D

func _ready() -> void:
	entity.released.connect(fire)

func get_shooting_dir() -> Vector2:
	return Vector2.from_angle(rotation_node.global_rotation)

func get_shooting_force(time_ratio:float) -> float:
	return lerp(min_fire_speed, max_fire_speed, time_ratio)

func get_shooting_vec(time_ratio:float) -> Vector2:
	return get_shooting_force(time_ratio) * get_shooting_dir()

func do_random() -> void:
	var rand_time := randf_range(500, 2000)
	fire(rand_time)

func fire(time_held:float) -> void:
	var b := map_data.grab_bullet_from_pool()
	if not b: 
		map_data.out_of_bullets.emit()
		return
	
	var time_ratio : float = clamp(time_held / max_held_time, 0.0, 1.0)
	b.shoot(entity.player_index, global_position, get_shooting_vec(time_ratio))
	
	Global.tween.play_popup_tween(entity)
	audio_player.pitch_scale = AudioManager.get_pitch_shift_semitones()
	audio_player.play()
