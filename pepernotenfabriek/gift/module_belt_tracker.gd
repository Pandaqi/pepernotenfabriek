extends Node2D
class_name ModuleBeltTracker

var belts : Array[ConveyorBelt] = []
var has_been_on_belt := false

func is_on_belt() -> bool:
	return belts.size() > 0

func add_belt(b:ConveyorBelt) -> void:
	has_been_on_belt = true
	belts.append(b)

func remove_belt(b:ConveyorBelt) -> void:
	belts.erase(b)

func is_controlled_by(b:ConveyorBelt) -> bool:
	return is_on_belt() and belts[0] == b
