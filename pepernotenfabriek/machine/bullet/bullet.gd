extends RigidBody2D
class_name Bullet

@export var sprite : Sprite2D
@export var map_data : MapData
@export var col_shape : CollisionShape2D

@export var module_pooling : ModulePooling
@export var module_map_bounds : ModuleMapBounds
@export var module_visuals : Node2D

@export var audio_player : AudioStreamPlayer2D

## player who shot this bullet; goes through index to prevent cyclic references to Player objects
var player_index : int

func _ready() -> void:
	module_pooling.killed.connect(_on_killed)

func set_size(s:float) -> void:
	col_shape.shape = CircleShape2D.new()
	col_shape.shape.radius = 0.5*s
	module_visuals.set_scale(s / 256.0 * Vector2.ONE)
	module_map_bounds.cache_size(Vector2.ONE * s)

func shoot(player:int, from:Vector2, vec:Vector2) -> void:
	module_pooling.revive(from)
	player_index = player
	apply_central_impulse(vec)

# Unfortunately, I don't see an automatic way to hook into a RigidBody's _integrate_forces
# Using events here has timing issues
func _integrate_forces(state:PhysicsDirectBodyState2D):
	module_pooling._integrate_forces(state)

func _on_killed(good := false) -> void:
	map_data.return_bullet_to_pool(self)

func get_size() -> Vector2:
	return sprite.scale * 256.0

func _on_body_entered(body: Node) -> void:
	if not (body is Gift): return
	body.module_bullet_hits.register(self)
	
	if not audio_player.playing:
		audio_player.pitch_scale = AudioManager.get_pitch_shift_semitones()
		audio_player.play()
