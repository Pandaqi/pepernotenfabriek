extends Node2D
class_name Basket

@export var area : Area2D
@export var col_shape : CollisionShape2D
@export var sprite : Sprite2D
@export var sprite_type : Sprite2D
var type : Gift.GiftType

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func set_type(tp:Gift.GiftType) -> void:
	type = tp
	sprite_type.set_frame(Gift.get_frame(tp))

func set_size(s:Vector2) -> void:
	var new_shape = RectangleShape2D.new()
	new_shape.size = s * Global.config.basket_area_size_factor
	col_shape.shape = new_shape
	
	var base_scale := 256
	sprite.set_scale(s / base_scale)

func _on_body_entered(body:Node2D) -> void:
	if not (body is Gift): return
	if body.type != type: return
	
	Global.tween.play_popup_tween(self)
	body.call_deferred("_on_enter_basket", self)
