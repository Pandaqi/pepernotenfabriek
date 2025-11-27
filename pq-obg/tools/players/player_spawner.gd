class_name PlayerSpawner extends Node2D

@export var player_scene : PackedScene
@export var player_data : PlayerData

@export var clear_input_on_reload := false

func _ready() -> void:
	Global.input.button_added.connect(on_button_added)
	Global.input.button_removed.connect(on_button_removed)
	Global.input.buttons_changed.connect(on_buttons_changed)
	
	# init calls
	player_data.reset(Global.config_shared.player_colors)
	if clear_input_on_reload: Global.input.clear()
	var btns_already_in_play = Global.input.buttons_used.duplicate()
	for btn in btns_already_in_play:
		place_player(btn)

func on_button_added(btn:InputButton) -> void:
	place_player(btn)

func on_button_removed(btn:InputButton) -> void:
	remove_player(btn)

func place_player(btn:InputButton) -> void:
	var p : Player = player_scene.instantiate()
	add_child(p)
	player_data.add_player(p)
	p.get_node("ModuleInput").activate(btn)
	
	if p.has_node("ModuleStatus"):
		p.get_node("ModuleStatus").revive()

func remove_player(btn:InputButton) -> void:
	var connected_player = get_player_with_button(btn)
	if not connected_player: return
	
	connected_player.get_node("ModuleInput").deactivate()
	player_data.remove_player(connected_player)
	
	if connected_player.has_node("ModuleStatus"):
		connected_player.get_node("ModuleStatus").die()
		return
	
	connected_player.queue_free()

func get_player_with_button(btn:InputButton) -> Player:
	for p in player_data.players:
		if p.get_node("ModuleInput").button == btn:
			return p
	return null

func on_buttons_changed() -> void:
	for p in player_data.players:
		var btn : InputButton = p.get_node("ModuleInput").button
		if Global.input.is_button_possible(btn): continue
		var new_btn : InputButton = Global.input.get_next_button_any()
		if not new_btn: continue
		p.get_node("ModuleInput").activate(btn)
