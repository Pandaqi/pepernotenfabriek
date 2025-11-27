extends RigidBody2D
class_name Gift

enum GiftType
{
	LETTER,
	SPECULAAS,
	GIFT_1,
	GIFT_2
}

var has_been_on_screen := false
var is_active := false
@export var col_shape : CollisionShape2D
@export var sprite : Sprite2D
@export var map_data : MapData

var type : GiftType
var reset_state := Vector2.ZERO
var belts : Array[ConveyorBelt] = []

func set_active(val:bool, pos := Vector2(-1000,-1000)) -> void:
	reset_state = pos
	
	has_been_on_screen = false
	is_active = val
	
	set_visible(val)
	set_linear_velocity(Vector2.ZERO)
	set_angular_velocity(0)

# @NOTE: Safest bet for teleporting RigidBodies is always this, otherwise really weird errors/flickering/etc
func _integrate_forces(state:PhysicsDirectBodyState2D):
	if reset_state.length() > 0.03:
		state.transform.origin = reset_state
		reset_state = Vector2.ZERO
		col_shape.set_deferred("disabled", not is_active)

func _physics_process(_delta: float) -> void:
	var standing_still := linear_velocity.length() <= 5.0
	if standing_still and (not is_on_belt()) and has_been_on_screen:
		call_deferred("kill")

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

static func get_frame(tp:GiftType) -> int:
	if tp == GiftType.LETTER: return 4
	if tp == GiftType.SPECULAAS: return 5
	if tp == GiftType.GIFT_1: return 0
	if tp == GiftType.GIFT_2: return 2
	return -1

func set_type(tp:GiftType) -> void:
	type = tp
	sprite.set_frame(get_frame(type))

func is_on_belt() -> bool:
	return belts.size() > 0

func add_belt(b:ConveyorBelt) -> void:
	belts.append(b)

func remove_belt(b:ConveyorBelt) -> void:
	belts.erase(b)
