extends RigidBody2D
class_name Gift

var has_been_on_screen := false
var is_active := false
@export var col_shape : CollisionShape2D
@export var sprite : Sprite2D
@export var map_data : MapData

var reset_state := Vector2.ZERO

func set_active(val:bool, pos := Vector2(-1000,-1000)) -> void:
	reset_state = pos
	
	has_been_on_screen = false
	is_active = val
	
	set_visible(val)
	set_linear_velocity(Vector2.ZERO)
	set_angular_velocity(0)

# @NOTE: Safest bet for teleporting RigidBodies is always this, otherwise really weird errors/flickering/etc
func _integrate_forces(state):
	if reset_state.length() > 0.03:
		state.transform.origin = reset_state
		reset_state = Vector2.ZERO
		col_shape.set_deferred("disabled", not is_active)

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	has_been_on_screen = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if has_been_on_screen:
		kill()

func kill(score := false) -> void:
	if not is_active: return
	
	print("Kill gift, reason score = ", score)
	if score: map_data.gifts_delivered += 1
	else: map_data.gifts_failed += 1
	
	map_data.return_gift_to_pool(self)
	set_active(false)
