extends Node2D
class_name ModuleMachines

@export var module_input : ModuleInput
var machines_connected : Array[Machine] = []

@export var enable_machine_switching := false
const MAX_DUR_FOR_MACHINE_CHANGE := 100.0 # ms
var current_machine := 0

func _ready() -> void:
	module_input.pressed.connect(_on_pressed)
	module_input.released.connect(_on_released)

func get_current_machine() -> Machine:
	return machines_connected[current_machine]

func _on_pressed() -> void:
	if enable_machine_switching:
		get_current_machine()._on_pressed()
		return
	
	for m in machines_connected:
		m._on_pressed()

func _on_released(dur:float) -> void:
	if enable_machine_switching:
		if dur < MAX_DUR_FOR_MACHINE_CHANGE:
			get_current_machine()._on_cancel_input()
			change_current_machine()
			return
		
		get_current_machine()._on_released(dur)
		return
	
	for m in machines_connected:
		m._on_released(dur)

func change_current_machine(dm := +1) -> void:
	current_machine = (current_machine + dm) % count()
	update_visualizers_visible()

func clear() -> void:
	machines_connected = []

func add(m:Machine) -> void:
	machines_connected.append(m)

func count() -> int:
	return machines_connected.size()

func refresh_visualizers() -> void:
	module_input.clear_button_visualizers()
	for machine in machines_connected:
		var vis := module_input.add_button_visualizer()
		vis.global_position = machine.global_position
	change_current_machine(0)

func update_visualizers_visible() -> void:
	for i in range(count()):
		var but := module_input.button_visualizers[i]
		var alpha := 1.0
		if enable_machine_switching: 
			alpha = 1.0 if (current_machine == i) else 0.25
		but.modulate.a = alpha
