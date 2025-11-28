extends Node2D
class_name ModuleGiftSpawner

@export var belt : ConveyorBelt
@export var timer : Timer
@export var map_data : MapData
@export var player_data : PlayerData

var min_time_between_gifts := 6.0 # at minimum player count (1)
var max_time_between_gifts := 2.0 # at maximum player count (8)

var min_gift_limit : int = 3 # at minimum player count (1)
var max_gift_limit : int = 10 # at maximum player count (8)

func _ready() -> void:
	timer.timeout.connect(_on_timeout)
	_on_timeout()

func _on_timeout() -> void:
	place_gift()
	restart_timer()

func place_gift() -> void:
	if is_at_gift_limit_for_playercount(): return
	
	var g := map_data.grab_gift_from_pool()
	if not g: return
	
	var pos := belt.get_pos_with_offset(0.0, 0.75*g.module_map_bounds.size_box.y)
	g.set_type(belt.gift_types.pick_random())
	g.module_pooling.revive(pos)

func restart_timer() -> void:
	timer.stop()
	timer.wait_time = get_random_time_between_gift_spawns()
	timer.start()

func is_at_gift_limit_for_playercount() -> bool:
	var ratio := player_data.get_ratio()
	var limit : float = lerp(min_gift_limit, max_gift_limit, ratio)
	return map_data.gifts_active.size() >= limit

func get_random_time_between_gift_spawns() -> float:
	var ratio := player_data.get_ratio()
	var base_value : float = lerp(min_time_between_gifts, max_time_between_gifts, ratio)
	var randomness := 0.33*base_value
	return base_value + randf_range(-1,1)*randomness
