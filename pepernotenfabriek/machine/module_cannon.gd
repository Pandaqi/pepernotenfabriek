extends Node2D
class_name ModuleCannon

@export var entity : Machine
@export var rotation_node : Node2D
@export var map_data : MapData

@export var audio_player : AudioStreamPlayer2D

func _ready() -> void:
	entity.released.connect(fire)

func get_shooting_dir() -> Vector2:
	var raw_dir := Vector2.from_angle(rotation_node.global_rotation)
	if Global.config.enable_aim_assistance: return aim_assist(raw_dir)
	return raw_dir

func get_shooting_force(time_ratio:float) -> float:
	return lerp(Global.config.bullet_min_fire_speed, Global.config.bullet_max_fire_speed, time_ratio)

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
	
	var time_ratio : float = clamp(time_held / Global.config.machine_max_held_time, 0.0, 1.0)
	b.shoot(entity.player_index, global_position, get_shooting_vec(time_ratio))
	
	Global.tween.play_popup_tween(entity)
	audio_player.pitch_scale = AudioManager.get_pitch_shift_semitones()
	audio_player.play()

func aim_assist(dir:Vector2) -> Vector2:
	var angle_dir := dir.angle()
	
	var gifts := map_data.gifts_active
	var closest_diff := INF
	var closest_angle := INF
	for gift in gifts:
		var vec_to_gift := gift.global_position - global_position
		var angle_to_gift := vec_to_gift.angle()
		
		var diff_angle : float = abs(angle_to_gift - angle_dir)
		diff_angle += 2*PI
		# float modulo
		diff_angle = diff_angle - floor(diff_angle/(2*PI))*2*PI
		
		if diff_angle >= closest_diff: continue
		
		closest_angle = angle_to_gift
		closest_diff = diff_angle
	
	# we're too far away? don't change anything
	if closest_diff > Global.config.aim_assistance_diff_threshold:
		return dir
	
	var perfect_dir := Vector2.from_angle(closest_angle)
	# with distances below max, this value will be higher than 1, so clamped to 1
	# with distances above max, this value will be lower than 1
	var weight : float = clamp(Global.config.max_aim_assistance_correction / closest_diff, 0.0, 1.0)
	var final_dir := dir.slerp(perfect_dir, weight)
	return final_dir
	
