class_name SettingReader

var config : ConfigFile
var path : String

const DEF_PATH := "user://settings.cfg"
const FALLBACK := "%UNSET%"

func _init(custom_path := DEF_PATH):
	path = custom_path
	config = ConfigFile.new()
	config.load(path)

func save_value(s:Setting) -> void:
	config.set_value(s.section, s.key, s.value)
	config.save(path)

func is_value_unset(v:Variant) -> bool:
	return (v is String and v == FALLBACK)

func read_default_value(s:Setting, val:Variant = FALLBACK) -> Variant:
	# try the global Config or ConfigShared
	if is_value_unset(val) and (s.key in Global.config):
		val = Global.config[s.key]
	
	if is_value_unset(val) and (s.key in Global.config_shared):
		val = Global.config_shared[s.key]
	
	# if still nothing, use default
	if is_value_unset(val):
		val = s.get_default()
	
	return val

func read_value(s:Setting) -> Variant:
	# try saved ConfigFile first; fallback is not NULL because then the errors/warning complain about no default value
	var val = config.get_value(s.section, s.key, FALLBACK)
	val = read_default_value(s, val)
	return val
