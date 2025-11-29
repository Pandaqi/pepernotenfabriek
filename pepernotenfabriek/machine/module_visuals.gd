extends Node2D
class_name ModuleVisualsMachine

@export var machine : Machine
@export var active_indicators : Node2D
@export var streak_indicator : Node2D
@export var anim_player_streak : AnimationPlayer

func _ready() -> void:
	machine.pressed.connect(_on_pressed)
	machine.released.connect(_on_released)
	machine.canceled.connect(_on_canceled)
	set_streak_intensity(0)
	_on_released(0.0)

func _on_pressed() -> void:
	active_indicators.set_visible(true)

func _on_released(_dur:float) -> void:
	active_indicators.set_visible(false)

func _on_canceled() -> void:
	active_indicators.set_visible(false)

func set_streak_intensity(ratio:float) -> void:
	var ratio_threshold := 0.02
	var sprite_scale : float = lerp(0.75, 1.25, ratio)
	if ratio < ratio_threshold: sprite_scale = 0
	streak_indicator.set_scale(Vector2.ONE * sprite_scale)
	
	if ratio < ratio_threshold: 
		anim_player_streak.stop()
	else:
		anim_player_streak.speed_scale = lerp(0.5, 2.0, ratio)
		anim_player_streak.play("score_streak")
