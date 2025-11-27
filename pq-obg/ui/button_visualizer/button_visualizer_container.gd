extends Control
class_name ButtonVisualizerContainer

@export var vis : ButtonVisualizer

const BASE_SCALE := Vector2(512, 512)
var button : InputButton

func _ready() -> void:
	gui_input.connect(_on_input_event)

func refresh_size(s:Vector2) -> void:
	custom_minimum_size = s
	
	# sprite to show
	vis.set_position(0.5 * s)
	
	var new_scale := s / BASE_SCALE
	var scale_uniform : float = min(new_scale.x, new_scale.y)
	vis.set_scale(Vector2.ONE * scale_uniform)

func set_button(btn:InputButton) -> void:
	button = btn
	vis.set_button(btn)

func _on_input_event(ev:InputEvent) -> void:
	var is_touch_button := button.type == InputButton.InputType.TOUCH
	if not is_touch_button: return
	
	var is_click := ev is InputEventScreenTouch
	if not is_click: return
	if ev.pressed: return # only trigger on RELEASE
	
	Global.input.request_login(button)
