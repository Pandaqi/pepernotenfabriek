extends Resource
class_name MapData

var max_num_gifts := 20
var max_num_bullets := 40

var gifts_active : Array[Gift]
var gifts_inactive : Array[Gift]

var bullets_active : Array[Bullet]
var bullets_inactive : Array[Bullet]

var belts : Array[ConveyorBelt]
var machines : Array[Machine]
var baskets : Array[Basket]

var bounds := Rect2(Vector2.ZERO, Vector2.ZERO)
const CELL_SIZE := 128.0

signal out_of_bullets()
signal gift_delivered(g:Gift)
signal gift_failed(g:Gift)

func reset() -> void:
	gifts_active = []
	gifts_inactive = []
	
	bullets_active = []
	bullets_inactive = []
	
	belts = []
	machines = []
	baskets = []

func is_out_of_bounds(pos:Vector2, margin := Vector2.ONE) -> bool:
	if bounds.size.length() <= 0.03: return true
	var box := Rect2(pos-0.5*margin, margin)
	return not bounds.encloses(box) and not bounds.intersects(box, true)

func grab_gift_from_pool() -> Gift:
	if gifts_inactive.size() <= 0: return null
	var g : Gift = gifts_inactive.pop_front()
	gifts_active.append(g)
	return g

func return_gift_to_pool(g:Gift) -> void:
	if not gifts_active.has(g): return
	gifts_active.erase(g)
	gifts_inactive.append(g)

func cache_gifts(node:Node2D, gift_scene:PackedScene) -> void:
	for i in range(max_num_gifts):
		var g : Gift = gift_scene.instantiate()
		g.set_size(0.65*CELL_SIZE)
		g.set_position(Vector2(-10000,-10000))
		g.module_pooling.reset()
		gifts_inactive.append(g)
		node.add_child(g)

func grab_bullet_from_pool() -> Bullet:
	if bullets_inactive.size() <= 0: return null
	var b : Bullet = bullets_inactive.pop_front()
	bullets_active.append(b)
	return b

func return_bullet_to_pool(b:Bullet) -> void:
	if not bullets_active.has(b): return
	bullets_active.erase(b)
	bullets_inactive.append(b)

func cache_bullets(node:Node2D, bullet_scene:PackedScene) -> void:
	for i in range(max_num_bullets):
		var b : Bullet = bullet_scene.instantiate()
		b.set_size(0.4*CELL_SIZE)
		b.set_position(Vector2(10000,-10000))
		b.module_pooling.reset()
		bullets_inactive.append(b)
		node.add_child(b)
