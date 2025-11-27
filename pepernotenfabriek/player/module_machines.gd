extends Node2D
class_name ModuleMachines

@export var module_input : ModuleInput
var machines_connected : Array[Machine] = []

func _ready() -> void:
	module_input.pressed.connect(_on_pressed)
	module_input.released.connect(_on_released)

func _on_pressed() -> void:
	for m in machines_connected:
		m._on_pressed()

func _on_released(dur:float) -> void:
	for m in machines_connected:
		m._on_released(dur)

func clear() -> void:
	machines_connected = []

func add(m:Machine) -> void:
	machines_connected.append(m)

func count() -> int:
	return machines_connected.size()

func refresh_visualizers() -> void:
	module_input.clear_button_visualizers()
	for machine in machines_connected:
		var vis := module_input.create_button_visualizer()
		vis.global_position = machine.global_position
