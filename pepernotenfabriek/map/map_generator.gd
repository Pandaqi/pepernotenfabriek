extends Node2D
class_name MapGenerator

const GRID_SIZE := Vector2(10, 8)

const NUM_BELTS := 3
var belt_positions : Array[Vector2i]
var belt_directions : Array[Vector2]

const NUM_MACHINES := 6
var machine_positions : Array[Vector2i]

const NUM_BASKETS := 10
var basket_positions : Array[Vector2i]
var basket_types : Array[String] # @TODO

var grid : Array
var grid_flat : Array[GridCell]

var belt_directions_allowed := [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
var generation_failed := false

const MAX_DIST_BASKET_MACHINE := 4

func generate() -> void:
	generation_failed = false
	create_grid()
	place_belts()
	place_machines()
	place_baskets()
	
	print_grid()

func print_grid() -> void:
	print("Generation Success? ", not generation_failed)
	print(belt_positions)
	print(belt_directions)
	
	var size := get_grid_size()
	for y in range(size.y):
		var outputs := []
		for x in range(size.x):
			outputs.append(get_cell_at(Vector2(x,y)).print_pretty())
		var string := " | ".join(outputs)
		print(string)

func create_grid() -> void:
	
	var starting_state : Dictionary[GridCell.ContentType, bool] = {
		GridCell.ContentType.BELT: true,
		GridCell.ContentType.MACHINE: false,
		GridCell.ContentType.BASKET: true
	}
	
	grid = []
	grid_flat = []
	for y in range(GRID_SIZE.y):
		grid.append([])
		
		for x in range(GRID_SIZE.x):
			var cell := GridCell.new(Vector2i(x,y))
			grid[y].append(cell)
			grid_flat.append(cell)
			
			cell.set_possible_contents(starting_state.duplicate())
	
	var edge_cells := get_edge_cells()
	for cell in edge_cells:
		cell.forbid_content(GridCell.ContentType.BELT)

func get_row(idx:int) -> Array[GridCell]:
	var size := get_grid_size()
	var arr : Array[GridCell] = []
	for x in range(size.x):
		arr.append(get_cell_at(Vector2(x, idx)))
	return arr

func get_column(idx:int) -> Array[GridCell]:
	var size := get_grid_size()
	var arr : Array[GridCell] = []
	for y in range(size.y):
		arr.append(get_cell_at(Vector2(idx, y)))
	return arr

func get_edge_cells() -> Array[GridCell]:
	var top := get_row(0)
	var bottom := get_row(grid.size() - 1)
	var left := get_column(0)
	var right := get_column(grid[0].size() - 1)
	return top + bottom + left + right

func get_grid_size() -> Vector2i:
	return Vector2i(grid[0].size(), grid.size())

func has_cell_at(pos:Vector2i) -> bool:
	var size := get_grid_size()
	return pos.x >= 0 and pos.x < size.x and pos.y >= 0 and pos.y < size.y

func get_cell_at(pos:Vector2i) -> GridCell:
	return grid[pos.y][pos.x]

func get_all_cells_for_content(tp:GridCell.ContentType) -> Array[GridCell]:
	return grid_flat.filter(func(c): return c.accepts_content(tp))

func get_cells_in_dir(pos:Vector2i, dir:Vector2) -> Array[GridCell]:
	var pos_exists := true
	var dir_clamped = Vector2i(dir.normalized())
	var arr : Array[GridCell] = []
	while pos_exists:
		pos += dir_clamped
		if not has_cell_at(pos): 
			pos_exists = false
			break
		arr.append(get_cell_at(pos))
	return arr

func get_cells_along_line(pos:Vector2i, dir:Vector2) -> Array[GridCell]:
	var cells : Array[GridCell] = [get_cell_at(pos)]
	cells += get_cells_in_dir(pos, dir)
	cells += get_cells_in_dir(pos, -dir)
	return cells

func get_neighbors_for(cell:GridCell) -> Array[GridCell]:
	var NB_DIRS := [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
	var nbs : Array[GridCell] = []
	for nb_dir in NB_DIRS:
		var new_pos : Vector2i = cell.pos + nb_dir
		if not has_cell_at(new_pos): continue
		nbs.append(get_cell_at(new_pos))
	return nbs

func get_all_neighbors_for(cells:Array[GridCell]) -> Array[GridCell]:
	var nbs : Array[GridCell] = []
	for cell in cells:
		var cell_nbs := get_neighbors_for(cell)
		for cell_nb in cell_nbs:
			if nbs.has(cell_nb): continue
			nbs.append(cell_nb)
	return nbs

func place_belts() -> void:
	belt_positions = []
	belt_directions = []
	
	for i in range(NUM_BELTS):
		# pick a random valid position
		var cells := get_all_cells_for_content(GridCell.ContentType.BELT)
		if cells.size() <= 0:
			generation_failed = true
			break
		
		# save position and direction
		var cell : GridCell = cells.pick_random()
		belt_positions.append(cell.pos)
		var dir : Vector2 = belt_directions_allowed.pick_random()
		belt_directions.append(dir)
		
		# mark + disable all cells in this line
		var belt_cells := get_cells_along_line(cell.pos, dir)
		for belt_cell in belt_cells:
			belt_cell.set_content(GridCell.ContentType.BELT)
		
		# don't allow belt in any cells next to us
		# do allow machines there
		var nbs := get_all_neighbors_for(belt_cells)
		for nb in nbs:
			nb.forbid_content(GridCell.ContentType.BELT)
			nb.allow_content(GridCell.ContentType.MACHINE)

func place_machines() -> void:
	machine_positions = []
	
	for i in range(NUM_MACHINES):
		# pick a random valid position
		var cells := get_all_cells_for_content(GridCell.ContentType.MACHINE)
		if cells.size() <= 0:
			generation_failed = true
			break
		
		# save position and direction
		var cell : GridCell = cells.pick_random()
		machine_positions.append(cell.pos)
		cell.set_content(GridCell.ContentType.MACHINE)
		
		# don't allow machines next to us
		var nbs := get_neighbors_for(cell)
		for nb in nbs:
			nb.forbid_content(GridCell.ContentType.MACHINE)
	
func place_baskets() -> void:
	basket_positions = []
	basket_types = []
	
	# get all empty cells left
	var cells := get_all_cells_for_content(GridCell.ContentType.BASKET)
	var cells_reachable := []
	
	# check their suitability
	for cell in cells:
		var query := query_basket_suitability(cell)
		if not query.valid: continue
		cells_reachable.append(query)
	
	# sort based on the results
	cells_reachable.shuffle()
	#cells_reachable.sort_custom(func(a,b):
		#return a.dist_avg < b.dist_avg
	#)
	
	if cells_reachable.size() < NUM_BASKETS:
		generation_failed = true
		return
	
	# finally, place based on that
	for i in range(NUM_BASKETS):
		var cell : GridCell = cells_reachable.pop_front().cell
		basket_positions.append(cell.pos)
		cell.set_content(GridCell.ContentType.BASKET)
	
func query_basket_suitability(cell:GridCell) -> Dictionary:
	var my_pos := Vector2(cell.pos)
	var data = { "cell": cell, "valid": false, "belts": [], "machines": [], "dist_closest": INF, "dist_avg": INF, "dist_total": 0 }
	
	# for every machine...
	for m in range(machine_positions.size()):
		var pos := Vector2(machine_positions[m])
		var vec_to_machine : Vector2 = pos - my_pos
		var dist_to_machine := vec_to_machine.length()
		if dist_to_machine > MAX_DIST_BASKET_MACHINE: continue
		
		var crosses_belt := false
		
		# ... check if there's a belt between us and this possible basket location
		for i in range(belt_positions.size()):
			var belt_pos := Vector2(belt_positions[i])
			var belt_dir := Vector2(belt_directions[i])
			
			# did not intersect at all? abort
			var intersect = Geometry2D.line_intersects_line(my_pos, vec_to_machine, belt_pos, belt_dir)
			if not intersect: 
				continue
			
			# intersection is on the wrong side (not between basket and machine)? abort
			var vec_to_intersect : Vector2 = intersect - my_pos
			var dot_prod := vec_to_intersect.normalized().dot(vec_to_machine.normalized())
			var intersection_wrong_side := dot_prod <= 0
			if intersection_wrong_side: 
				continue
			
			# intersection is TOO FAR/BEHIND the machine? abort
			var dist_to_intersect := vec_to_intersect.length()
			var intersection_too_far := dist_to_intersect >= dist_to_machine
			if intersection_too_far:
				continue
			
			# ah, this is a good belt intersection, save it
			data.dist_total += dist_to_intersect
			data.dist_closest = min(data.dist_closest, dist_to_intersect)
			crosses_belt = true
			data.belts.append(i)
		
		if crosses_belt: 
			data.machines.append(m)
	
	data.valid = data.belts.size() > 0 and data.machines.size() > 0
	if data.valid:
		data.dist_avg = data.dist_total / data.belts.size()
	
	return data
