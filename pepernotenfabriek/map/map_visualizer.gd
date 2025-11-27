extends Node2D
class_name MapVisualizer

const CELL_SIZE := 128.0

@export var belt_scene : PackedScene
@export var machine_scene : PackedScene
@export var basket_scene : PackedScene

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
		b.update_sizes(bounds)
		add_child(b)
	
	# place machines
	for i in range(g.machine_positions.size()):
		var m : Machine = machine_scene.instantiate()
		m.set_position(get_real_pos(g.machine_positions[i]))
		add_child(m)
	
	# place baskets
	# @TODO: generate + set type/design
	for i in range(g.basket_positions.size()):
		var b : Basket = basket_scene.instantiate()
		b.set_position(get_real_pos(g.basket_positions[i]))
		b.set_size(CELL_SIZE * 0.9 * Vector2.ONE)
		add_child(b)
	
	
