extends Node2D
class_name ModuleInput 

@onready var entity = get_parent()

var holder : InputHolder
var button : InputButton
var button_visualizers : Array[ButtonVisualizer] = []
var removal_warning_enabled := false
var touch_area_scene := preload("res://pq-obg/ui/touch/input_touch_area.tscn")
var touch_area : InputTouchArea

@export var hold_time := 250.0
@export var player_data : PlayerData
@export var num_button_visualizers := 1

signal pressed()
signal released(time_held:float)
signal removal_warning_started()
signal removal_warning_ended()

func activate(new_button:InputButton) -> void:
	if button: Global.input.give_back_button(button)
	
	# if we're placing existing players, then we already grabbed their button 
	# so we should NOT try to do so again
	if Global.input.is_button_grabbable(new_button):
		Global.input.grab_button(new_button)
		Global.audio.play_player_change_sound()
	
	button = new_button
	
	# refresh button visualizers
	clear_button_visualizers()
	for i in range(num_button_visualizers):
		add_button_visualizer()
	
	if button.is_touch():
		create_touch_area()
	
	# the holder is responsible for timing length of button press
	if holder: remove_child(holder)
	
	holder = InputHolder.new(hold_time)
	pressed.connect(holder.start_tracking)
	released.connect(holder.stop_tracking)
	holder.held.connect(on_button_held)
	add_child(holder)

func deactivate() -> void:
	Global.audio.play_player_change_sound()
	if not Global.input.is_button_grabbable(button):
		Global.input.give_back_button(button)

func create_touch_area() -> void:
	touch_area = touch_area_scene.instantiate()
	touch_area.pressed.connect(_on_pressed)
	touch_area.released.connect(_on_released)
	
	touch_area.set_button(button)
	touch_area.set_color(player_data.get_color_for(entity))
	
	var area_layer = player_data.touch_area_layer
	area_layer.add_area(touch_area)

func clear_button_visualizers() -> void:
	for bv in button_visualizers:
		bv.queue_free()
	button_visualizers = []

func add_button_visualizer() -> void:
	button_visualizers.append(create_button_visualizer())

func create_button_visualizer() -> ButtonVisualizer:
	var node = Global.config_shared.button_visualizer_scene.instantiate()
	add_child(node)
	node.set_tint(player_data.get_color_for(entity))
	node.set_button(button)
	
	var s : Vector2 = Vector2.ONE * Global.config_shared.button_visualizer_scale * Global.config_shared.button_visualizer_scale_base
	node.set_scale(s)
	return node

func _unhandled_input(ev:InputEvent) -> void:
	var key := button.get_input_map_key()
	if key == "": return
	
	if ev.is_action_pressed(key):
		_on_pressed()
	
	if ev.is_action_released(key):
		_on_released()

func _on_pressed() -> void:
	pressed.emit()

func _on_released() -> void:
	released.emit(holder.get_time_since_press())

func on_button_held(time_held:float) -> void:
	check_for_removal(time_held)

func check_for_removal(time_held:float) -> void:
	if not Global.input.can_remove_button_by_hold(button, time_held): return
	
	# turn warnings on/off (for "you're about to remove yourself")
	var removal_time_warning : float = 0.75*Global.input.get_removal_time()
	if not removal_warning_enabled and time_held >= removal_time_warning:
		removal_warning_started.emit()
	if removal_warning_enabled and time_held < removal_time_warning:
		removal_warning_ended.emit()
	
	# actually remove us if needed
	if time_held >= Global.input.get_removal_time():
		Global.input.request_button_removal(button)
