extends Node

@export var config : ConfigData
@export var config_shared : ConfigSharedData

var input : InputManager
var audio : AudioManager
var theme : ThemeManager

signal pause_mode_change()

func _ready():
	theme = ThemeManager.new()
	add_child(theme)
	
	input = InputManager.new()
	add_child(input)
	
	audio = AudioManager.new()
	add_child(audio)
