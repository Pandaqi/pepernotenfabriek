extends Node2D
class_name MachineDistributor

@export var player_data : PlayerData
@export var map_data : MapData

func _ready() -> void:
	Global.input.buttons_changed.connect(_on_buttons_changed)

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
	for i in range(machines.size()):
		var machine := machines[i]
		var player_index : int = i % num_players
		var player := players[player_index]
		player.module_machines.add(machine)
	
	await get_tree().process_frame
	
	for player in players:
		player.module_machines.refresh_visualizers()
