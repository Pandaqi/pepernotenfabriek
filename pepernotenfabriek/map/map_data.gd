extends Resource
class_name MapData

var max_num_gifts := 20
var max_num_bullets := 40

var gifts_active : Array[Gift]
var gifts_inactive : Array[Gift]

var bullets_active : Array[Bullet]
var bullets_inactive : Array[Bullet]

var gifts_delivered := 0
var gifts_failed := 0

var belts : Array[ConveyorBelt]
var machines : Array[Machine]
var baskets : Array[Basket]

signal out_of_bullets()

func reset() -> void:
	gifts_active = []
	gifts_inactive = []
	gifts_delivered = 0
	gifts_failed = 0
	
	belts = []
	machines = []
	baskets = []

func grab_gift_from_pool() -> Gift:
	if gifts_inactive.size() <= 0: return null
	var g : Gift = gifts_inactive.pop_back()
	gifts_active.append(g)
	return g

func return_gift_to_pool(g:Gift) -> void:
	if not gifts_active.has(g): return
	gifts_active.erase(g)
	gifts_inactive.append(g)

func cache_gifts(node:Node2D, gift_scene:PackedScene) -> void:
	for i in range(max_num_gifts):
		var g : Gift = gift_scene.instantiate()
		g.set_active(false)
		gifts_inactive.append(g)
		node.add_child(g)

func grab_bullet_from_pool() -> Bullet:
	if bullets_inactive.size() <= 0: return null
	var b : Bullet = bullets_inactive.pop_back()
	bullets_active.append(b)
	return b

func return_bullet_to_pool(b:Bullet) -> void:
	if not bullets_active.has(b): return
	bullets_active.erase(b)
	bullets_inactive.append(b)

func cache_bullets(node:Node2D, bullet_scene:PackedScene) -> void:
	for i in range(max_num_bullets):
		var b : Bullet = bullet_scene.instantiate()
		b.set_active(false)
		bullets_inactive.append(b)
		node.add_child(b)
