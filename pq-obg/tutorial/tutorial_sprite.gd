class_name TutorialSprite extends Node2D

var stage : TutorialStage

@onready var bg : Sprite2D = $BG
@onready var sprite : Sprite2D = $Sprite

const bg_frames := [TutorialStage.Type.OBJECTIVE, TutorialStage.Type.GAME_OVER, TutorialStage.Type.BUTTON_PRESS, TutorialStage.Type.BUTTON_HOLD, TutorialStage.Type.GAMEPLAY]

func set_stage(s:TutorialStage) -> void:
	stage = s
	bg.set_frame(get_background_frame(stage.type))
	
	sprite.texture = Global.config_shared.tutorial_spritesheet
	var frames := Global.config_shared.tutorial_spritesheet_frames
	sprite.hframes = frames.x
	sprite.vframes = frames.y
	sprite.set_frame(stage.frame)

func get_background_frame(tp:TutorialStage.Type) -> int:
	var base_frame := 3
	var offset := bg_frames.find(tp)
	return base_frame + offset

func appear() -> void:
	# always start being invisible
	var target_scale := scale
	set_scale(Vector2.ZERO)
	
	var dur := 0.3 # this is just the popup animation
	var tw := get_tree().create_tween()
	tw.tween_property(self, "scale", 1.15*target_scale, 0.5*dur)
	tw.tween_property(self, "scale", target_scale, 0.5*dur)
	
	var delay := Global.config_shared.tutorial_delay
	tw.tween_interval(delay)
	
	await tw.finished
