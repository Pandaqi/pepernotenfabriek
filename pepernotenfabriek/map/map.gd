extends Node2D
class_name Map

@export var map_data : MapData
@export var gift_scene : PackedScene
@export var bullet_scene : PackedScene

@export var generator : MapGenerator
@export var visualizer : MapVisualizer

func _enter_tree() -> void:
	map_data.reset()

func _ready() -> void:
	map_data.cache_gifts(self, gift_scene)
	map_data.cache_bullets(self, bullet_scene)
	
	var num_tries := 0
	var max_tries := 1000
	while not generator.is_valid() and num_tries < max_tries:
		num_tries += 1
		generator.generate()
	visualizer.visualize(generator)
