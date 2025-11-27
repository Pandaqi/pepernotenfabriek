extends Node2D
class_name ModuleGiftSpawner

@export var belt : ConveyorBelt
@export var timer : Timer
@export var map_data : MapData

func _ready() -> void:
	timer.timeout.connect(_on_timeout)
	restart_timer()

func _on_timeout() -> void:
	place_gift()
	restart_timer()

func place_gift() -> void:
	var g := map_data.grab_gift_from_pool()
	if not g: return
	
	# @TODO: Read/save somewhere from `g`
	var gift_size := 64.0
	var pos := belt.get_pos_with_offset(0.0, 0.5*gift_size)
	g.set_type(belt.gift_types.pick_random())
	g.set_active(true, pos)

func restart_timer() -> void:
	timer.stop()
	timer.wait_time = randf_range(1.0, 8.0)
	timer.start()
