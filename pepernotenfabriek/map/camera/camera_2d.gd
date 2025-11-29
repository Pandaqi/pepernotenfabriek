extends Camera2D

const MOVE_SPEED := 8.0
const ZOOM_SPEED := 8.0

@export var map_data : MapData

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(dt:float) -> void:
	var map_bounds := map_data.bounds
	if not map_bounds: return
	
	var target_position := map_bounds.get_center()
	
	var vp_size := get_viewport_rect().size - 2*Global.config.camera_edge_margin
	var desired_size := map_bounds.size
	var ratios := vp_size / desired_size
	
	var target_zoom : Vector2 = min(ratios.x, ratios.y) * Vector2.ONE
	
	var move_factor := MOVE_SPEED*dt
	var zoom_factor := ZOOM_SPEED*dt
	set_position(get_position().lerp(target_position, move_factor))
	set_zoom(get_zoom().lerp(target_zoom, zoom_factor))
