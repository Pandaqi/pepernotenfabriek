class_name ButtonInstruction extends PanelContainer

enum Type
{
	LOGIN,
	LOGOUT
}

@export var button_visualizer : ButtonVisualizer
@export var button_container : Control
@export var label : Label

func activate(btn: InputButton, tp:Type) -> void:
	set_type(tp)
	set_button(btn)
	refresh_size()

func refresh_size() -> void:
	var icon_size : float = Global.config_shared.button_instructions_icon_size
	button_container.refresh_size(Vector2.ONE * icon_size)
	label.custom_minimum_size.y = icon_size
	label.add_theme_font_size_override("font_size", Global.config_shared.button_instructions_font_size)

func set_type(tp:Type) -> void:
	if tp == Type.LOGIN:
		label.set_text("BUTTON_NEW_PLAYER")
	
	if tp == Type.LOGOUT:
		label.set_text(get_logout_text())

func get_logout_text() -> String:
	if Global.input.removal_type == Global.input.ButtonRemovalType.NONE:
		return "BUTTON_LOGOUT_RELOAD"
	if Global.input.removal_type == Global.input.ButtonRemovalType.HOLD_COND:
		return "BUTTON_LOGOUT_MODE"
	
	var time : int = ceil(Global.input.get_removal_time() / 1000.0)
	return "{tr_1} ({time}s)".format({ tr_1 = tr("BUTTON_LOGOUT"), time = time })

func set_button(btn:InputButton) -> void:
	button_container.set_visible(btn != null)
	if not btn: return
	button_container.set_button(btn)
