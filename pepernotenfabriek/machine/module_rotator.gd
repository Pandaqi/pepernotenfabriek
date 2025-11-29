extends Node2D
class_name ModuleRotator

@export var entity : Machine
@export var node_to_rotate : Node2D
var rotate_dir := 1

func _ready() -> void:
	if Global.config.machine_randomize_dir_at_start and randf() <= 0.5: rotate_dir *= -1

func get_rotate_speed() -> float:
	if entity.is_button_held: return Global.config.machine_rotate_speed_held
	return Global.config.machine_rotate_speed

func _physics_process(delta: float) -> void:
	node_to_rotate.rotate(delta * rotate_dir * get_rotate_speed())

func do_random() -> void:
	node_to_rotate.set_rotation(2 * randf() * PI)
