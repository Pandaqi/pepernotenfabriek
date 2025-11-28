extends Node2D
class_name Score

@export var map_data : MapData
@export var player_data : PlayerData

var break_player_streak_for_failed_gifts := true
var break_global_streak_for_failed_gifts := true

var gifts_delivered : int = 0
var gifts_failed : int = 0

var gifts_target_min : int = 10
var gifts_target_max : int = 30
var gifts_delivered_target : int = 20

var score_min := 10.0
var score_max := 100.0

var mult_min := 0.5
var mult_max := 4.0

@export var streak_global : ScoreStreak

var value := 0.0

signal score_changed(val:float)
signal progress(val:float)
signal target_changed(target:int)
signal game_over(stats)

func _ready() -> void:
	map_data.gift_delivered.connect(_on_gift_delivered)
	map_data.gift_failed.connect(_on_gift_failed)
	
	player_data.all_players_ready.connect(_on_all_players_ready)
	Global.input.buttons_changed.connect(_on_buttons_changed)
	
	streak_global = ScoreStreak.new()
	add_value(0)

func _on_all_players_ready() -> void:
	_on_buttons_changed()

func _on_buttons_changed() -> void:
	var ratio := player_data.get_ratio()
	gifts_delivered_target = floor(lerp(gifts_target_min, gifts_target_max, ratio))
	target_changed.emit(gifts_delivered_target)
	progress.emit(get_delivery_ratio())

func get_delivery_ratio() -> float:
	return clamp(gifts_delivered / float(gifts_delivered_target), 0.0, 1.0)

func _on_gift_delivered(g:Gift) -> void:
	gifts_delivered += 1
	
	for idx in g.module_bullet_hits.player_indices:
		player_data.players[idx].module_streak.grow()
	
	streak_global.grow()
	
	add_value(calculate_score_for_gift(g))
	
	var ratio := get_delivery_ratio()
	progress.emit(ratio)
	if ratio >= 1.0:
		game_over.emit({})

func calculate_score_for_gift(g:Gift) -> float:
	var max_streak := 0.0
	for idx in g.module_bullet_hits.player_indices:
		max_streak = max(max_streak, player_data.players[idx].module_streak.get_ratio())
	
	var base_score : float = lerp(score_min, score_max, max_streak)
	var multiplier : float = lerp(mult_min, mult_max, streak_global.get_ratio())
	
	return base_score * multiplier

func add_value(dv:float) -> void:
	value = clamp(value + dv, 0.0, INF)
	score_changed.emit(value)

func _on_gift_failed(g:Gift) -> void:
	gifts_failed += 1
	
	if break_player_streak_for_failed_gifts:
		for idx in g.module_bullet_hits.player_indices:
			player_data.players[idx].module_streak.kill()
	
	if break_global_streak_for_failed_gifts:
		streak_global.kill()
