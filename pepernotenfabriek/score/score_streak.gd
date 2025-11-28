extends Node2D
class_name ScoreStreak

var steps := 0
var max_steps := 8

signal is_broken(streak:ScoreStreak)
signal is_updated(streak:ScoreStreak)

func kill() -> void:
	steps = 0
	is_broken.emit(self)
	is_updated.emit(self)

func grow(ds := +1) -> void:
	steps = clamp(steps + ds, 0, max_steps)
	is_updated.emit(self)

func get_ratio() -> float:
	return clamp(get_ratio_raw(), 0.0, 1.0)

func get_ratio_raw() -> float:
	return steps / float(max_steps)

func interpolate(a:float, b:float) -> float:
	return lerp(a, b, get_ratio())
