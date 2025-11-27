extends Node2D
class_name ModuleRotator

@export var entity : Machine
@export var rotate_speed := 0.5
@export var rotate_speed_held := 7.5
var rotate_dir := 1

@export var enable_dir_change := true
const MAX_DUR_FOR_DIR_CHANGE := 80.0

func _ready() -> void:
	entity.released.connect(_on_released)

func _on_released(dur:float) -> void:
	if not enable_dir_change: return
	if dur > MAX_DUR_FOR_DIR_CHANGE: return
	rotate_dir *= -1

func get_rotate_speed() -> float:
	if entity.is_button_held: return rotate_speed_held
	return rotate_speed

func _physics_process(delta: float) -> void:
	entity.rotate(delta * rotate_dir * get_rotate_speed())
