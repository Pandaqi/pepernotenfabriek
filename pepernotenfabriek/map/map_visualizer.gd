extends Node2D
class_name MapVisualizer

const CELL_SIZE := 128.0

@export var belt_scene : PackedScene
@export var machine_scene : PackedScene
@export var basket_scene : PackedScene
@export var map_data : MapData

var bounds : Rect2

func get_real_pos(pos:Vector2i) -> Vector2:
	return (Vector2(pos) + Vector2(0.5, 0.5)) * CELL_SIZE

func visualize(g:MapGenerator) -> void:
	# set main properties
	var grid_size := g.get_grid_size()
	bounds = Rect2(Vector2.ZERO, grid_size * CELL_SIZE)
	
	# place belts
	for i in range(g.belt_positions.size()):
		var b : ConveyorBelt = belt_scene.instantiate()
		b.set_position(get_real_pos(g.belt_positions[i]))
		b.dir = g.belt_directions[i]
		b.belt_thickness = CELL_SIZE
		b.set_gift_types(g.belt_gift_types[i])
		b.update_sizes(bounds)
		add_child(b)
		map_data.belts.append(b)
	
	# place machines
	for i in range(g.machine_positions.size()):
		var m : Machine = machine_scene.instantiate()
		m.set_position(get_real_pos(g.machine_positions[i]))
		add_child(m)
		map_data.machines.append(m)
	
	# place baskets
	for i in range(g.basket_positions.size()):
		var b : Basket = basket_scene.instantiate()
		b.set_position(get_real_pos(g.basket_positions[i]))
		b.set_type(g.basket_types[i])
		b.set_size(CELL_SIZE * 0.9 * Vector2.ONE)
		add_child(b)
		map_data.baskets.append(b)
	
	
