extends CanvasLayer
 
const UI_LIGHT_BROWN: Color = Color("c98a52")
const UI_DARK_BROWN: Color = Color("7a4520")
const UI_TEXT: Color = Color("fff3d6")
const UI_TEXT_DARK: Color = Color("4a2815")
 
var dialog: AcceptDialog
 
 
func _ready() -> void:
	SignalBus.missing_resources_requested.connect(_on_missing_resources_requested)
 
	dialog = AcceptDialog.new()
	dialog.title = "Nicht genug Ressourcen"
	dialog.dialog_autowrap = true
	add_child(dialog)
 
	_style_dialog(dialog)
 
 
func _load_ui_font() -> FontFile:
	return load("res://Assets/Jacquard12-Regular.ttf")
 
 
func _make_panel_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = UI_LIGHT_BROWN
	sb.border_color = UI_DARK_BROWN
	sb.border_width_left = 6
	sb.border_width_top = 6
	sb.border_width_right = 6
	sb.border_width_bottom = 6
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10
	sb.shadow_color = Color(0, 0, 0, 0.25)
	sb.shadow_size = 4
	sb.expand_margin_left = 6
	sb.expand_margin_top = 6
	sb.expand_margin_right = 6
	sb.expand_margin_bottom = 6
	return sb
 
 
func _make_button_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = UI_DARK_BROWN
	sb.border_color = Color("4f2a12")
	sb.border_width_left = 3
	sb.border_width_top = 3
	sb.border_width_right = 3
	sb.border_width_bottom = 3
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	return sb
 
 
func _style_dialog(target_dialog: AcceptDialog) -> void:
	var ui_font: FontFile = _load_ui_font()
	var panel_style := _make_panel_style()
	var button_style := _make_button_style()
 
	target_dialog.add_theme_stylebox_override("panel", panel_style)
	target_dialog.add_theme_font_override("font", ui_font)
	target_dialog.add_theme_font_size_override("font_size", 18)
	target_dialog.add_theme_color_override("title_color", UI_TEXT)
	target_dialog.add_theme_color_override("font_color", UI_TEXT)
	target_dialog.add_theme_color_override("font_outline_color", UI_DARK_BROWN)
	target_dialog.add_theme_constant_override("outline_size", 3)
 
	var ok_button: Button = target_dialog.get_ok_button()
	if ok_button != null:
		ok_button.add_theme_font_override("font", ui_font)
		ok_button.add_theme_font_size_override("font_size", 18)
		ok_button.add_theme_color_override("font_color", UI_TEXT)
		ok_button.add_theme_stylebox_override("normal", button_style)
		ok_button.add_theme_stylebox_override("hover", button_style)
		ok_button.add_theme_stylebox_override("pressed", button_style)
 
 
func _on_missing_resources_requested(missing: Dictionary) -> void:
	if dialog == null:
		return
 
	dialog.dialog_text = build_missing_text(missing)
	dialog.popup_centered()
 
 
func build_missing_text(missing: Dictionary) -> String:
	var parts: Array[String] = []
 
	if missing.has("money"):
		parts.append("💰 Gold: %d" % int(missing["money"]))
	if missing.has("wood"):
		parts.append("🪵 Holz: %d" % int(missing["wood"]))
	if missing.has("stone"):
		parts.append("🪨 Stein: %d" % int(missing["stone"]))
 
	return "Dir fehlen:\n\n" + "\n".join(parts)
