extends Node2D
class_name ModuleHoming

@export var enabled := false

@export var body : RigidBody2D
@export var map_data : MapData

@export var sight_radius := 512.0
@export var lock_on_radius := 64.0
@export var strength_factor := 2.5
@export var min_speed_for_activation := 300.0
@export var look_ahead_factor := 0.5 # usual speed is ~1000, so this amounts to a look ahead roughly equal to the sight radius

func _physics_process(delta: float) -> void:
	if not enabled: return
	
	# if we already hit something, stop homing and just let us go free
	if body.hit_something: return
	
	# if we're going too slow, then homing is too noticeable and silly
	# so disable then
	var vel := body.linear_velocity
	var speed := vel.length()
	var going_too_slow := speed < min_speed_for_activation
	if going_too_slow: return
	
	var gifts := map_data.gifts_active
	var total_vector := Vector2.ZERO
	var num_gifts_considered := 0
	
	# if we're really close to something
	# we ignore anything else and go for that specific thing for sure
	var closest_dist_unprojected := INF
	var closest_vec_unprojected := Vector2.ZERO
	
	var projected_position := global_position + vel * look_ahead_factor
	$Node2D.global_position = projected_position
	for gift in gifts:
		var vec_to_gift_unprojected := gift.global_position - global_position
		var dist_unprojected := vec_to_gift_unprojected.length()
		if dist_unprojected < closest_dist_unprojected:
			closest_dist_unprojected = dist_unprojected
			closest_vec_unprojected = vec_to_gift_unprojected
		
		var vec_to_gift := gift.global_position - projected_position
		var dist := vec_to_gift.length()
		if dist > sight_radius: continue
		
		# if we basically have to turn around to hit this thing
		# then it's not worth homing on it
		var dot_prod := vel.normalized().dot(vec_to_gift.normalized())
		var too_different := dot_prod <= 0
		if too_different: continue
		
		num_gifts_considered += 1
		total_vector += lerp(Vector2.ZERO, vec_to_gift.normalized(), 1.0 - dist/sight_radius)
	
	if closest_dist_unprojected < lock_on_radius:
		num_gifts_considered = 1
		total_vector = closest_vec_unprojected.normalized()
	
	if num_gifts_considered <= 0: return
	
	var final_vector := total_vector / num_gifts_considered
	var strength := vel.length() * strength_factor
	body.apply_central_force(final_vector * strength)
	
