extends Node2D
class_name ModuleMachines

@export var module_input : ModuleInput
var machines_connected : Array[Machine] = []
var max_num_machines_active := 2

@export var enable_machine_switching := true
const MAX_DUR_FOR_MACHINE_CHANGE := 100.0 # ms
var current_machine := 0

@export var audio_player : AudioStreamPlayer2D
@export var module_streak : ScoreStreak

func _ready() -> void:
	module_input.pressed.connect(_on_pressed)
	module_input.released.connect(_on_released)
	
	module_streak.is_updated.connect(_on_streak_updated)

func get_current_machine_first() -> Machine:
	return get_current_machines().front()

func get_current_machines() -> Array[Machine]:
	return machines_connected.slice(current_machine, current_machine + max_num_machines_active)

func is_machine_active(m:Machine) -> bool:
	return get_current_machines().has(m)

func _on_pressed() -> void:
	for m in get_current_machines():
		m._on_pressed()

func _on_released(dur:float) -> void:
	var machines := get_current_machines()
	if enable_machine_switching and dur < MAX_DUR_FOR_MACHINE_CHANGE:
		for m in machines:
			m._on_cancel_input()
		change_current_machine(max_num_machines_active)
		return
	
	for m in machines:
		m._on_released(dur)

func change_current_machine(dm := +1) -> void:
	current_machine = (current_machine + dm) % count()
	update_visualizers_visible()
	audio_player.set_position(get_current_machine_first().global_position)
	audio_player.pitch_scale = AudioManager.get_pitch_shift_semitones()
	audio_player.play()

func clear() -> void:
	machines_connected = []

func add(m:Machine) -> void:
	machines_connected.append(m)
	m.player_index = module_input.get_player_index()

func count() -> int:
	return machines_connected.size()

func refresh_visualizers() -> void:
	module_input.clear_button_visualizers()
	for machine in machines_connected:
		var vis := module_input.add_button_visualizer()
		vis.global_position = machine.global_position
		machine.modulate.a = 1.0
	change_current_machine(0)

func update_visualizers_visible() -> void:
	for i in range(count()):
		var but := module_input.button_visualizers[i]
		var machine := machines_connected[i]
		var alpha := 1.0 if is_machine_active(machine) else 0.25
		but.modulate.a = alpha
		machine.modulate.a = alpha

func _on_streak_updated(streak:ScoreStreak) -> void:
	for machine in machines_connected:
		machine.module_visuals.set_streak_intensity(streak.get_ratio())
