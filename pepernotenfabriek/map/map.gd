extends Node2D
class_name Map

@export var map_data : MapData
@export var gift_scene : PackedScene
@export var bullet_scene : PackedScene

@export var generator : MapGenerator
@export var visualizer : MapVisualizer

func _ready() -> void:
	map_data.reset()
	map_data.cache_gifts(self, gift_scene)
	map_data.cache_bullets(self, bullet_scene)
	
	generator.generate()
	visualizer.visualize(generator)
