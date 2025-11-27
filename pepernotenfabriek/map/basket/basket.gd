extends Node2D
class_name Basket

@export var area : Area2D
@export var col_shape : CollisionShape2D
@export var sprite : Sprite2D

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func set_size(s:Vector2) -> void:
	var new_shape = RectangleShape2D.new()
	new_shape.size = s
	col_shape.shape = new_shape
	
	var base_scale := 128
	sprite.set_scale(s / base_scale)

func _on_body_entered(body:Node2D) -> void:
	if not (body is Gift): return
	# @TODO: play some simple animation for dropping into the bucket, then kill
	body.call_deferred("kill", true)
