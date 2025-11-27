extends Node2D
class_name Machine

var is_button_held := false
var time_press := 0.0

signal pressed()
signal released(dur:float)

func _input(ev:InputEvent) -> void:
	debug_input(ev)

func debug_input(ev:InputEvent) -> void:
	if not OS.is_debug_build(): return
	
	if ev.is_action_pressed("ui_accept"):
		_on_pressed()
	
	if ev.is_action_released("ui_accept"):
		var time_held := Time.get_ticks_msec() - time_press
		_on_released(time_held)

func _on_pressed() -> void:
	is_button_held = true
	time_press = Time.get_ticks_msec()
	pressed.emit()

func _on_released(dur:float) -> void:
	is_button_held = false
	released.emit(dur)
