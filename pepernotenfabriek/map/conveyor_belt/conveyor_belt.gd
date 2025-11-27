extends Node2D
class_name ConveyorBelt

@export var dir := Vector2.RIGHT
@export var push_force := 500.0
@export var max_push_change_per_frame := 60.0
@export var area : Area2D
@export var col_shape : CollisionShape2D
@export var sprite : Sprite2D
@export var belt_thickness := 80.0
@export var belt_extra_margin := 64.0

var bounds : Array[Vector2]
var start_pos : Vector2
var end_pos : Vector2

var bodies : Array[Gift]
var gift_types : Array[Gift.GiftType]

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body:Node2D) -> void:
	if not (body is Gift): return
	if body.is_on_belt(): return
	bodies.append(body)
	body.add_belt(self)

func _on_body_exited(body:Node2D) -> void:
	if not (body is Gift): return
	if not bodies.has(body): return
	bodies.erase(body)
	body.remove_belt(self)

func _physics_process(_delta: float) -> void:
	var target_velocity := dir.normalized() * push_force
	for body in bodies:
		var cur_velocity := body.get_linear_velocity()
		var change_needed := target_velocity - cur_velocity
		var change_amount_clamped : float = clamp(change_needed.length(), 0.0, max_push_change_per_frame)
		var change_clamped := change_amount_clamped * change_needed.normalized()
		body.apply_central_force(change_clamped)

func get_belt_vec() -> Vector2:
	return end_pos - start_pos

func get_belt_length() -> float:
	return get_belt_vec().length()

func get_belt_size() -> Vector2:
	return Vector2(get_belt_length(), belt_thickness)

func get_belt_angle() -> float:
	return dir.angle()

func get_belt_center() -> Vector2:
	return 0.5*(start_pos + end_pos)

func get_offset_vec() -> Vector2:
	return dir.orthogonal().normalized()

func get_pos_with_offset(ratio:float, edge_margin:= 0.0) -> Vector2:
	var pos_base := start_pos + ratio * get_belt_vec()
	var pos_offset := get_offset_vec() * (randf() - 0.5) * (belt_thickness - edge_margin)
	return pos_base + pos_offset

func set_gift_types(tp:PackedInt32Array) -> void:
	var types : Array[Gift.GiftType] = []
	for elem in tp:
		if types.has(elem): continue
		types.append(elem)
	gift_types = types

func update_sizes(map_bounds:Rect2) -> void:
	var vp := map_bounds.size
	
	# find where it intersects with edge of screen
	# (we're only interested in the two closest locations in each direction, + and -)
	var pos := get_position()
	var left_bound = Geometry2D.line_intersects_line(pos, dir, Vector2.ZERO, Vector2.DOWN)
	var right_bound = Geometry2D.line_intersects_line(pos, dir, vp, Vector2.UP)
	var top_bound = Geometry2D.line_intersects_line(pos, dir, Vector2.ZERO, Vector2.RIGHT)
	var bottom_bound = Geometry2D.line_intersects_line(pos, dir, vp, Vector2.LEFT)
	var bounds_all = [left_bound, right_bound, top_bound, bottom_bound]
	
	var first_bound_positive_dot := Vector2.ZERO
	var dist_bound_positive_dot := INF
	var first_bound_negative_dot := Vector2.ZERO
	var dist_bound_negative_dot := INF
	for b in bounds_all:
		if b == null: continue
		var vec : Vector2 = (b - pos)
		var dot : float = vec.normalized().dot(dir.normalized())
		var dist := vec.length()
		
		if dot > 0 and dist < dist_bound_positive_dot:
			dist_bound_positive_dot = dist
			first_bound_positive_dot = b
		
		if dot < 0 and dist < dist_bound_negative_dot:
			dist_bound_negative_dot = dist
			first_bound_negative_dot = b
	
	# (the direction that matches DIR will have highest dot product, namely 1, other is -1)
	# (that should be the ENDING direction; that's where we're GOING)
	bounds = [first_bound_negative_dot, first_bound_positive_dot]
	start_pos = bounds[0] - dir.normalized()*belt_extra_margin
	end_pos = bounds[1] + dir.normalized()*belt_extra_margin
	
	# update sprites and area to match
	# (because they're centered, we need to offset their local anchor pos to be center of screen)
	var belt_size := get_belt_size()
	set_position(get_belt_center())
	set_rotation(get_belt_angle())
	var base_scale := 128.0
	sprite.set_scale(belt_size / base_scale)
	col_shape.shape = RectangleShape2D.new()
	col_shape.shape.size = belt_size
