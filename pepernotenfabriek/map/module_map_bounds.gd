extends Node2D
class_name ModuleMapBounds

@export var target : Node2D
@export var size : Vector2
@export var map_data : MapData

var notifier : VisibleOnScreenNotifier2D

var on_screen := false
var on_screen_camera := false
var has_been_on_screen := false
var size_box := Vector2.ZERO

@export var debug_draw := false

signal screen_enter()
signal screen_exit()

func cache_size(s:Vector2) -> void:
	if not notifier: 
		notifier = VisibleOnScreenNotifier2D.new()
		add_child(notifier)
		notifier.screen_entered.connect(func(): on_screen_camera = true)
		notifier.screen_exited.connect(func(): on_screen_camera = false)
	
	notifier.rect = Rect2(-0.5*s, s)
	size_box = s

func _draw() -> void:
	if not debug_draw: return
	
	global_position = Vector2.ZERO
	global_rotation = 0
	
	var box := Rect2(target.global_position-0.5*size_box, size_box)
	var color := Color.RED if map_data.bounds.intersects(box) else Color.BLACK
	draw_rect(box, color, true)
	
	draw_rect(map_data.bounds, Color.RED, false)
	

func _process(_delta: float) -> void:
	var pos := target.global_position
	var off_map := map_data.is_out_of_bounds(pos, size_box)
	set_state(not off_map)
	
	if debug_draw: queue_redraw()

func set_state(s:bool) -> void:
	if on_screen == s: return
	
	on_screen = s
	if on_screen: 
		has_been_on_screen = true
		screen_enter.emit()
	else: 
		screen_exit.emit()
