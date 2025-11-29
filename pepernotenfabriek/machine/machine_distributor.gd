extends Node2D
class_name MachineDistributor

@export var player_data : PlayerData
@export var map_data : MapData

func _ready() -> void:
	Global.input.buttons_changed.connect(_on_buttons_changed)
	player_data.setup_finished.connect(_on_all_players_ready)

func _on_all_players_ready() -> void:
	_on_buttons_changed()

func _on_buttons_changed() -> void:
	refresh_machine_input_connections()

func refresh_machine_input_connections() -> void:
	var num_players : int = player_data.count()
	if num_players <= 0: return
	
	# first let all players forget about their current machines
	var players : Array[Player] = player_data.players
	for player in players:
		player.module_machines.clear()
	
	# then fairly distribute the new ones, one at a time
	var machines := map_data.machines
	var num_machines_to_distribute : int = machines.size()
	if Global.config.enable_max_machines_per_player:
		num_machines_to_distribute = min(num_machines_to_distribute, num_players * Global.config.max_machines_per_player)
	
	for i in range(machines.size()):
		machines[i].hide()
	
	for i in range(num_machines_to_distribute):
		var machine := machines[i]
		var player_index : int = i % num_players
		var player := players[player_index]
		player.module_machines.add(machine)
		machine.show()
	
	for player in players:
		player.module_machines.refresh_visualizers()
