extends Node2D
class_name ModuleIdleCheck

@export var entity : Gift
@export var module_belt_tracker : ModuleBeltTracker
@export var module_map_bounds : ModuleMapBounds
@export var module_pooling : ModulePooling

const STANDING_STILL_THRESHOLD := 1.0
var standing_still := false
var time_standstill := 0.0

func _physics_process(_delta: float) -> void:
	var was_standing_still := standing_still
	standing_still = check_if_standing_still()
	
	if not standing_still:
		entity.modulate.a = 1.0
		time_standstill = 0
		return
	
	if not was_standing_still and standing_still:
		time_standstill = Time.get_ticks_msec()
	
	var diff : float = Time.get_ticks_msec() - time_standstill
	var delay_before_removal := Global.config.gift_standstill_delay_before_removal
	var ratio : float = 1.0 - clamp(diff / delay_before_removal, 0.0, 1.0)
	entity.modulate.a = ratio
	if diff < delay_before_removal: return
	
	module_pooling.call_deferred("kill")

func check_if_standing_still() -> bool:
	var velocity_is_low := entity.linear_velocity.length() <= STANDING_STILL_THRESHOLD
	if not velocity_is_low: return false
	if module_belt_tracker.is_on_belt(): return false
	if not module_belt_tracker.has_been_on_belt: return false
	return true
