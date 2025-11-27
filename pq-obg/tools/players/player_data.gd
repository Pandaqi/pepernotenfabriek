extends Resource
class_name PlayerData

var players : Array[Player] = []
var colors_available : Array[Color] = []
var colors_used : Array[Color] = []
var touch_area_layer : Control

func reset(colors:Array[Color]) -> void:
	players = []
	colors_available = colors.duplicate()
	colors_used = []

func add_player(p:Player) -> void:
	colors_used.append(colors_available.pop_front())
	players.append(p)

func remove_player(p:Player) -> void:
	var col := get_color_for(p)
	colors_used.erase(col)
	colors_available.append(col)
	players.erase(p)

func count() -> int:
	return players.size()

func get_player_num_for(p:Player) -> int:
	return players.find(p)

func get_color_for(p:Player) -> Color:
	return colors_used[get_player_num_for(p)]

# @TODO: how to add easy SIGNALS for when this has changed? Through the ModuleScore script?
func get_score_for_team(team_num:int) -> float:
	var sum := 0.0
	for player in players:
		var team := -1
		if player.has_node("ModuleStatus"):
			team = player.get_node("ModuleStatus").get_team()
		if team != team_num: continue
		
		var score := 0
		if player.has_node("ModuleScore"):
			score = player.get_node("ModuleScore").get_score()
		sum += score
	return sum
