extends Node2D
class_name ModuleRotator

@export var entity : Machine
@export var node_to_rotate : Node2D
@export var rotate_speed := 0.5
@export var rotate_speed_held := 7.5
var rotate_dir := 1

@export var randomize_dir_at_start := true
@export var enable_dir_change := false
const MAX_DUR_FOR_DIR_CHANGE := 80.0

func _ready() -> void:
	if randomize_dir_at_start and randf() <= 0.5: rotate_dir *= -1
	entity.released.connect(_on_released)

func _on_released(dur:float) -> void:
	if not enable_dir_change: return
	if dur > MAX_DUR_FOR_DIR_CHANGE: return
	rotate_dir *= -1

func get_rotate_speed() -> float:
	if entity.is_button_held: return rotate_speed_held
	return rotate_speed

func _physics_process(delta: float) -> void:
	node_to_rotate.rotate(delta * rotate_dir * get_rotate_speed())

func do_random() -> void:
	node_to_rotate.set_rotation(2 * randf() * PI)
