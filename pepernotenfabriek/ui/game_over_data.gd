extends GameOverData
class_name GameOverDataCustom

@export var state_data : StateData

func get_header() -> String:
	return "GO_HEADER"

func get_message() -> String:
	var text := "{tr_1} {score}.".format({ tr_1 = tr("GAME_OVER_MESSAGE"), score = state_data.final_score })
	return text
