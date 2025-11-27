extends RigidBody2D
class_name ModuleArm

@export var joint_node : GrooveJoint2D
@export var push_back_factor := 600.0
@export var dampen_factor := 3.0
@export var extend_impulse := 1000

func _input(ev:InputEvent) -> void:
	if ev.is_action_released("ui_accept"):
		extend(extend_impulse * mass)

func get_direction() -> Vector2:
	return Vector2.from_angle(self.global_rotation)

func extend(speed:float) -> void:
	var force := speed * get_direction()
	apply_central_impulse(force)

func _physics_process(delta: float) -> void:
	keep_arm_close(delta)
	dampen_arm(delta)

func keep_arm_close(delta: float) -> void:
	var vec_to_center := joint_node.global_position - global_position
	var offset_from_center := vec_to_center.length()
	var push_back_force : Vector2 = vec_to_center.normalized() * offset_from_center * push_back_factor
	apply_central_force(push_back_force)

func dampen_arm(delta: float) -> void:
	linear_velocity /= (1 + dampen_factor * delta)
