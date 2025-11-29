class_name Tutorial extends Node2D

var stages : Array[TutorialStage] = []
@export var stages_debug : Array[TutorialStage] = []

@export var sprite_scene : PackedScene
var sprites : Array[TutorialSprite] = []

var sprite_size := Vector2(512.0, 512.0)

var active := false
var num_times_shown := 0

func _ready() -> void:
	prepare_sprites()
	prepare_anchor_tool()

func prepare_sprites() -> void:
	# collect the right stages
	if "tutorials" in Global.config_shared:
		stages = Global.config_shared.tutorials
	
	if stages_debug.size() > 0:
		stages = stages_debug
	
	# create objects for them
	for i in range(count_stages()):
		var t : TutorialSprite = sprite_scene.instantiate()
		add_child(t)
		sprites.append(t)
		t.set_stage(stages[i])

func prepare_anchor_tool() -> void:
	var anchor_tool := ScreenAnchorTool.new(
		Global.config_shared.tutorial_anchor,
		sprite_size, 0.1*Global.config_shared.tutorial_sprite_scale
	)
	add_child(anchor_tool)
	anchor_tool.show_elements(sprites)

func set_active(val:bool) -> void:
	if Global.config_shared.tutorial_only_once and num_times_shown > 0: 
		set_visible(false)
		return
	
	active = val
	set_visible(val)
	if val:
		appear()

func appear() -> void:
	num_times_shown += 1
	# make them pop into view one by one
	for sprite in sprites:
		await sprite.appear()

func count_stages() -> int:
	return stages.size()
