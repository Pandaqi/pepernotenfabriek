extends RigidBody2D
class_name Gift

enum GiftType
{
	LETTER,
	SPECULAAS,
	GIFT_1,
	GIFT_2
}

@export var sprite : Sprite2D
@export var col_shape : CollisionShape2D
@export var map_data : MapData

var type : GiftType

@export var module_pooling : ModulePooling
@export var module_belt_tracker : ModuleBeltTracker
@export var module_map_bounds : ModuleMapBounds
@export var module_bullet_hits : ModuleBulletHits
@export var module_visuals : Node2D
@export var module_audio : ModuleAudioGift


static func get_frame(tp:GiftType) -> int:
	if tp == GiftType.LETTER: return 4
	if tp == GiftType.SPECULAAS: return 5
	if tp == GiftType.GIFT_1: return 0
	if tp == GiftType.GIFT_2: return 2
	return -1

func _ready() -> void:
	module_pooling.killed.connect(_on_killed)
	module_pooling.revived.connect(_on_revived)

func set_size(s:float) -> void:
	col_shape.shape = CircleShape2D.new()
	col_shape.shape.radius = 0.5*s
	module_visuals.set_scale(s / 256.0 * Vector2.ONE)
	module_map_bounds.cache_size(Vector2.ONE * s)

# Unfortunately, I don't see an automatic way to hook into a RigidBody's _integrate_forces
# Using events here has timing issues
func _integrate_forces(state:PhysicsDirectBodyState2D):
	module_pooling._integrate_forces(state)

func _on_revived() -> void:
	module_audio.play_appear()

func _on_enter_basket(b:Basket) -> void:
	module_audio.play_deliver()
	
	freeze = true
	var tw := Global.tween.play_shrink_tween(sprite)
	await tw.finished
	
	freeze = false
	module_pooling.tween_kill = false
	module_pooling.kill(true)
	module_pooling.tween_kill = true

func _on_killed(good := false) -> void:
	print("Kill gift, reason score = ", good)
	
	if good: 
		map_data.gift_delivered.emit(self)
	
	if not good:
		module_audio.play_fail()
		map_data.gift_failed.emit(self)
	
	module_belt_tracker.has_been_on_belt = false
	module_bullet_hits._on_killed()
	
	map_data.return_gift_to_pool(self)

func set_type(tp:GiftType) -> void:
	type = tp
	sprite.set_frame(get_frame(type))
