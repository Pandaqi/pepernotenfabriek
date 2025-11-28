extends Node2D
class_name Machine

var is_button_held := false
var time_press := 0.0
var player_index : int

signal pressed()
signal released(dur:float)
signal canceled()

@export var module_rotator : ModuleRotator
@export var module_cannon : ModuleCannon
@export var module_visuals : ModuleVisualsMachine

func _input(ev:InputEvent) -> void:
	debug_input(ev)

func debug_input(ev:InputEvent) -> void:
	if not OS.is_debug_build(): return
	
	if ev.is_action_pressed("ui_accept"):
		_on_pressed()
	
	if ev.is_action_released("ui_accept"):
		var time_held := Time.get_ticks_msec() - time_press
		_on_released(time_held)

func set_size(s:Vector2) -> void:
	var base_scale := 256.0
	set_scale(s / base_scale)

func _on_pressed() -> void:
	is_button_held = true
	time_press = Time.get_ticks_msec()
	pressed.emit()

func _on_released(dur:float) -> void:
	is_button_held = false
	released.emit(dur)

func _on_cancel_input() -> void:
	is_button_held = false
	canceled.emit()

func shoot_random() -> void:
	module_rotator.do_random()
	module_cannon.do_random()
