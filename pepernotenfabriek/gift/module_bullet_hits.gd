extends Node2D
class_name ModuleBulletHits

var player_indices : Array[int] = []
var num_hits := 0

func _on_killed() -> void:
	player_indices = []
	num_hits = 0

func register(b:Bullet) -> void:
	num_hits += 1
	if not player_indices.has(b.player_index):
		player_indices.append(b.player_index)
