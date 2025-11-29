extends Node2D
class_name Score

@export var map_data : MapData
@export var player_data : PlayerData

var gifts_delivered : int = 0
var gifts_failed : int = 0

var gifts_delivered_target : int = 0

@export var streak_global : ScoreStreak
@export var debug_game_over := true

var value := 0.0

signal score_changed(val:float)
signal progress(val:float)
signal target_changed(target:int)
signal game_over()

func _ready() -> void:
	map_data.gift_delivered.connect(_on_gift_delivered)
	map_data.gift_failed.connect(_on_gift_failed)
	
	player_data.setup_finished.connect(_on_all_players_ready)
	Global.input.buttons_changed.connect(_on_buttons_changed)
	
	streak_global = ScoreStreak.new()
	await get_tree().process_frame
	
	add_value(0)
	recalculate_target()

func _input(ev:InputEvent) -> void:
	debug_input(ev)

func debug_input(ev:InputEvent) -> void:
	if not OS.is_debug_build(): return
	
	if debug_game_over and ev.is_action_released("ui_accept"):
		gifts_delivered = gifts_delivered_target
		check_game_over()

func _on_all_players_ready() -> void:
	_on_buttons_changed()

func _on_buttons_changed() -> void:
	recalculate_target()

func recalculate_target() -> void:
	var ratio := player_data.get_ratio()
	gifts_delivered_target = floor(lerp(Global.config.gifts_target_min, Global.config.gifts_target_max, ratio) * Global.config.gifts_target_factor)
	target_changed.emit(gifts_delivered_target)
	progress.emit(get_delivery_ratio())

func get_delivery_ratio() -> float:
	return clamp(gifts_delivered / float(gifts_delivered_target), 0.0, 1.0)

func _on_gift_delivered(g:Gift) -> void:
	gifts_delivered += 1
	
	var players := player_data.get_from_indices(g.module_bullet_hits.player_indices)
	for p in players:
		p.module_streak.grow()
	
	streak_global.grow()
	
	add_value(calculate_score_for_gift(g))
	
	check_game_over()

func check_game_over() -> void:
	var ratio := get_delivery_ratio()
	progress.emit(ratio)
	if ratio >= 1.0:
		game_over.emit()

func calculate_score_for_gift(g:Gift) -> float:
	var max_streak := 0.0
	var players := player_data.get_from_indices(g.module_bullet_hits.player_indices)
	for p in players:
		max_streak = max(max_streak, p.module_streak.get_ratio())
	
	var base_score : float = lerp(Global.config.score_min, Global.config.score_max, max_streak)
	var multiplier : float = lerp(Global.config.mult_min, Global.config.mult_max, streak_global.get_ratio())
	
	return base_score * multiplier

func get_value() -> float:
	return value

func add_value(dv:float) -> void:
	value = clamp(value + dv, 0.0, INF)
	score_changed.emit(value)

func _on_gift_failed(g:Gift) -> void:
	gifts_failed += 1
	
	if Global.config.break_player_streak_for_failed_gifts:
		var players := player_data.get_from_indices(g.module_bullet_hits.player_indices)
		for p in players:
			p.module_streak.kill()
	
	if Global.config.break_global_streak_for_failed_gifts:
		streak_global.kill()
