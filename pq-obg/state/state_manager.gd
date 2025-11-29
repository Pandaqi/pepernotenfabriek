extends Node
class_name StateManager

@export var settings_tabs_custom : Array[SettingTab]
@export var auto_load_settings := true
@export var save_file_name := "savegame.save"

func _ready() -> void:
	if auto_load_settings: load_settings()

func load_settings() -> void:
	var reader : SettingReader = SettingReader.new()
	var all_tabs : Array[SettingTab] = Global.config_shared.settings
	if settings_tabs_custom.size() > 0:
		all_tabs = settings_tabs_custom
	
	for tab in all_tabs:
		tab.initialize(reader)

func save(data:Dictionary) -> void:
	var save_file = FileAccess.open("user://" + save_file_name, FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)

func load_save_data() -> Dictionary:
	var save_file = FileAccess.open("user://" + save_file_name, FileAccess.READ)
	var json := JSON.new()
	json.parse(save_file)
	return json.data
