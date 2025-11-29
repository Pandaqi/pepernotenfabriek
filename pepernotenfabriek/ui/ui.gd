extends CanvasLayer
class_name UI

@export var score : Score
@export var score_label : Label
@export var target_label : Label
@export var prog_bar : TextureProgressBar
@export var map_data : MapData
@export var state_data : StateData

@export var anim_player_streak : AnimationPlayer
@export var anim_player_score : AnimationPlayer

@export var audio_player : AudioStreamPlayer

@export var game_over_menu : GameOverMenu

func _ready() -> void:
	score.score_changed.connect(_on_score_changed)
	score.progress.connect(_on_progress)
	score.game_over.connect(_on_game_over)
	score.target_changed.connect(_on_target_changed)
	score.streak_global.is_updated.connect(_on_streak_updated)

func _on_score_changed(s:float) -> void:
	score_label.set_text(str(int(floor(s))))
	anim_player_score.play("score")

func _on_progress(ratio:float) -> void:
	prog_bar.set_value(ratio)
	update_target_label()

func _on_target_changed(_target:int) -> void:
	update_target_label()

func update_target_label() -> void:
	var string := str(score.gifts_delivered) + " / " + str(score.gifts_delivered_target)
	target_label.set_text(string)

func _on_game_over() -> void:
	execute_machine_party_time()
	state_data.final_score = score.get_value()
	game_over_menu.activate()
	audio_player.play()

func execute_machine_party_time() -> void:
	var machines := map_data.machines
	var num_random_shots := 10
	for i in range(num_random_shots):
		for m in machines:
			m.shoot_random()

func _on_streak_updated(streak:ScoreStreak) -> void:
	if not streak.is_active(): 
		anim_player_streak.stop()
		return
	
	anim_player_streak.speed_scale = lerp(0.5, 2.0, streak.get_ratio())
	anim_player_streak.play("score_streak")
