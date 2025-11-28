extends Node2D
class_name TweenManager

var base_duration := 0.3

func play_popup_tween(obj:Node2D) -> Tween:
	var cur_scale := obj.scale
	var tw := get_tree().create_tween()
	tw.tween_property(obj, "scale", cur_scale*1.35, 0.33*base_duration)
	tw.tween_property(obj, "scale", cur_scale, 0.66*base_duration)
	return tw

func play_shrink_tween(obj:Node2D) -> Tween:
	var tw := get_tree().create_tween()
	tw.tween_property(obj, "scale", Vector2.ZERO, base_duration)
	return tw
