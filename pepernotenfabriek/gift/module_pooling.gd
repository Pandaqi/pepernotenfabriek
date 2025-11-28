extends Node2D
class_name ModulePooling

var initialized := false
var reset_state := Vector2.ZERO
var is_active := false

@export var entity : RigidBody2D
@export var module_map_bounds : ModuleMapBounds
@export var col_shape : CollisionShape2D

@export var tween_node : Node2D
@export var tween_revive := false
@export var tween_kill := false

signal revived()
signal killed(good:bool)

func _ready() -> void:
	module_map_bounds.screen_exit.connect(_on_screen_exited)

func reset() -> void:
	set_active(false)
	initialized = true

func set_active(val:bool, pos := Vector2(-1000,-1000)) -> void:
	var was_active := is_active
	if initialized and was_active and tween_kill:
		tween_node.set_scale(Vector2.ONE)
		var tw := Global.tween.play_popup_tween(tween_node)
		await tw.finished
	
	reset_state = pos
	
	module_map_bounds.has_been_on_screen = false
	is_active = val
	
	set_visible(val)
	entity.set_linear_velocity(Vector2.ZERO)
	entity.set_angular_velocity(0)
	
	if initialized and (not was_active) and tween_revive:
		tween_node.set_scale(Vector2.ONE)
		Global.tween.play_popup_tween(tween_node)

# @NOTE: Safest bet for teleporting RigidBodies is always this, otherwise really weird errors/flickering/etc
func _integrate_forces(state:PhysicsDirectBodyState2D):
	if reset_state.length() < 0.03: return
	
	state.transform = Transform2D(randf()*2*PI, reset_state)
	reset_state = Vector2.ZERO
	col_shape.set_deferred("disabled", not is_active)

func _on_screen_exited() -> void:
	if module_map_bounds.has_been_on_screen:
		kill()

func revive(pos:Vector2) -> void:
	if is_active: return
	set_active(true, pos)
	revived.emit()

func kill(good := false) -> void:
	if not is_active: return
	set_active(false)
	killed.emit(good)
