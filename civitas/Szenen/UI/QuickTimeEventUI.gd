extends CanvasLayer
 
@export var houses_path: NodePath = NodePath("../Houses")
@export var min_interval: float = 18.0
@export var max_interval: float = 30.0
 
const EVENT_FIRE: String = "fire"
const EVENT_SEQUENCE: String = "sequence"
const EVENT_REPAIR: String = "repair"
 
const UI_LIGHT_BROWN: Color = Color("c98a52")
const UI_DARK_BROWN: Color = Color("7a4520")
const UI_TEXT: Color = Color("fff3d6")
const UI_TEXT_DARK: Color = Color("4a2815")
 
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
 
var houses: Node = null
 
var interval_timer: Timer
var fail_timer: Timer
 
var panel: PanelContainer
var title_label: Label
var desc_label: Label
var timer_label: Label
var instruction_label: Label
var progress_bar: ProgressBar
var mash_button: Button
var hold_button: Button
var arrow_row: HBoxContainer
var arrow_buttons: Dictionary = {}
var target_icon: Label
var qte_system_started: bool = false
 
var active_event: Dictionary = {}
var hold_active: bool = false
var hold_progress: float = 0.0
 
 
func _ready() -> void:
	rng.randomize()
	houses = get_node_or_null(houses_path)
 
	SignalBus.building_placed.connect(_on_building_placed)
 
	_create_ui()
	_create_timers()
 
 
func _on_building_placed(_building: Node) -> void:
	if houses == null:
		houses = get_node_or_null(houses_path)
	try_start_qte_system()
 
 
func _process(delta: float) -> void:
	_update_target_icon()
 
	if fail_timer != null and not fail_timer.is_stopped() and active_event.has("type"):
		timer_label.text = "Zeit: %.1f s" % fail_timer.time_left
 
	if String(active_event.get("type", "")) == EVENT_REPAIR and fail_timer != null and not fail_timer.is_stopped():
		if hold_active:
			hold_progress += delta
		else:
			hold_progress = max(0.0, hold_progress - delta * 0.45)
 
		var target: float = float(active_event.get("target", 2.0))
		progress_bar.value = clamp((hold_progress / target) * 100.0, 0.0, 100.0)
		instruction_label.text = "Reparaturfortschritt: %d%%" % int(progress_bar.value)
 
		if hold_progress >= target:
			_resolve_event(true)
 
 
func _input(event: InputEvent) -> void:
	if active_event.is_empty():
		return
 
	var event_type: String = String(active_event.get("type", ""))
 
	if event_type != EVENT_SEQUENCE:
		return
 
	if event.is_action_pressed("ui_up"):
		_sequence_input_step("up")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		_sequence_input_step("down")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_left"):
		_sequence_input_step("left")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		_sequence_input_step("right")
		get_viewport().set_input_as_handled()
 
 
func _create_timers() -> void:
	interval_timer = Timer.new()
	interval_timer.one_shot = true
	interval_timer.timeout.connect(_on_interval_timeout)
	add_child(interval_timer)
 
	fail_timer = Timer.new()
	fail_timer.one_shot = true
	fail_timer.timeout.connect(_on_event_failed)
	add_child(fail_timer)
 
 
func _load_ui_font() -> FontFile:
	return load("res://Assets/Jacquard12-Regular.ttf")
 
 
func _style_label(lbl: Label, font: FontFile, size: int = 18, use_light_text: bool = true) -> void:
	lbl.add_theme_font_override("font", font)
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", UI_TEXT if use_light_text else UI_TEXT_DARK)
	lbl.add_theme_color_override("font_outline_color", UI_DARK_BROWN)
	lbl.add_theme_constant_override("outline_size", 3)
 
 
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
 
 
func _make_progress_style(fill: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("8c5a34") if not fill else Color("f2c078")
	sb.border_color = UI_DARK_BROWN
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	return sb
 
 
func _style_accept_dialog(dialog: AcceptDialog) -> void:
	var ui_font: FontFile = _load_ui_font()
	var panel_style := _make_panel_style()
	var button_style := _make_button_style()
 
	dialog.add_theme_stylebox_override("panel", panel_style)
	dialog.add_theme_font_override("font", ui_font)
	dialog.add_theme_font_size_override("font_size", 18)
	dialog.add_theme_color_override("title_color", UI_TEXT)
	dialog.add_theme_color_override("font_color", UI_TEXT)
	dialog.add_theme_color_override("font_outline_color", UI_DARK_BROWN)
	dialog.add_theme_constant_override("outline_size", 3)
 
	var ok_button: Button = dialog.get_ok_button()
	if ok_button != null:
		ok_button.add_theme_font_override("font", ui_font)
		ok_button.add_theme_font_size_override("font_size", 18)
		ok_button.add_theme_color_override("font_color", UI_TEXT)
		ok_button.add_theme_stylebox_override("normal", button_style)
		ok_button.add_theme_stylebox_override("hover", button_style)
		ok_button.add_theme_stylebox_override("pressed", button_style)
 
 
func _create_ui() -> void:
	var ui_font: FontFile = _load_ui_font()
 
	target_icon = Label.new()
	target_icon.visible = false
	target_icon.text = "!"
	target_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	target_icon.z_index = 100
	target_icon.add_theme_font_override("font", ui_font)
	target_icon.add_theme_font_size_override("font_size", 26)
	target_icon.add_theme_color_override("font_color", UI_TEXT)
	target_icon.add_theme_color_override("font_outline_color", UI_DARK_BROWN)
	target_icon.add_theme_constant_override("outline_size", 4)
	add_child(target_icon)
 
	panel = PanelContainer.new()
	panel.visible = false
	panel.offset_left = 20.0
	panel.offset_top = 20.0
	panel.offset_right = 420.0
	panel.offset_bottom = 320.0
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	add_child(panel)
 
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	vb.set_anchors_preset(Control.PRESET_FULL_RECT)
	vb.offset_left = 14
	vb.offset_top = 14
	vb.offset_right = -14
	vb.offset_bottom = -14
	panel.add_child(vb)
 
	title_label = Label.new()
	title_label.text = "Ereignis"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(title_label, ui_font, 26, true)
	vb.add_child(title_label)
 
	desc_label = Label.new()
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(desc_label, ui_font, 16, true)
	vb.add_child(desc_label)
 
	timer_label = Label.new()
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_style_label(timer_label, ui_font, 16, true)
	vb.add_child(timer_label)
 
	instruction_label = Label.new()
	instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(instruction_label, ui_font, 16, true)
	vb.add_child(instruction_label)
 
	progress_bar = ProgressBar.new()
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	progress_bar.add_theme_stylebox_override("background", _make_progress_style(false))
	progress_bar.add_theme_stylebox_override("fill", _make_progress_style(true))
	progress_bar.add_theme_font_override("font", ui_font)
	progress_bar.add_theme_font_size_override("font_size", 14)
	progress_bar.add_theme_color_override("font_color", UI_TEXT_DARK)
	vb.add_child(progress_bar)
 
	mash_button = Button.new()
	mash_button.text = "🔥 Löschen!"
	mash_button.pressed.connect(_on_mash_pressed)
	mash_button.add_theme_font_override("font", ui_font)
	mash_button.add_theme_font_size_override("font_size", 18)
	mash_button.add_theme_color_override("font_color", UI_TEXT)
	mash_button.add_theme_stylebox_override("normal", _make_button_style())
	mash_button.add_theme_stylebox_override("hover", _make_button_style())
	mash_button.add_theme_stylebox_override("pressed", _make_button_style())
	vb.add_child(mash_button)
 
	hold_button = Button.new()
	hold_button.text = "🛠 Gedrückt halten"
	hold_button.button_down.connect(_on_hold_button_down)
	hold_button.button_up.connect(_on_hold_button_up)
	hold_button.add_theme_font_override("font", ui_font)
	hold_button.add_theme_font_size_override("font_size", 18)
	hold_button.add_theme_color_override("font_color", UI_TEXT)
	hold_button.add_theme_stylebox_override("normal", _make_button_style())
	hold_button.add_theme_stylebox_override("hover", _make_button_style())
	hold_button.add_theme_stylebox_override("pressed", _make_button_style())
	vb.add_child(hold_button)
 
	arrow_row = HBoxContainer.new()
	arrow_row.alignment = BoxContainer.ALIGNMENT_CENTER
	arrow_row.add_theme_constant_override("separation", 8)
	vb.add_child(arrow_row)
 
	var arrow_defs: Array[Dictionary] = [
		{"key": "left", "label": "←"},
		{"key": "up", "label": "↑"},
		{"key": "down", "label": "↓"},
		{"key": "right", "label": "→"}
	]
 
	for info: Dictionary in arrow_defs:
		var btn := Button.new()
		btn.text = String(info["label"])
		btn.custom_minimum_size = Vector2(60, 48)
		btn.pressed.connect(_on_arrow_pressed.bind(String(info["key"])))
		btn.add_theme_font_override("font", ui_font)
		btn.add_theme_font_size_override("font_size", 22)
		btn.add_theme_color_override("font_color", UI_TEXT)
		btn.add_theme_stylebox_override("normal", _make_button_style())
		btn.add_theme_stylebox_override("hover", _make_button_style())
		btn.add_theme_stylebox_override("pressed", _make_button_style())
		arrow_row.add_child(btn)
		arrow_buttons[String(info["key"])] = btn
 
 
func _schedule_next_event() -> void:
	if interval_timer == null:
		return
 
	var delay: float = rng.randf_range(min_interval, max_interval)
	interval_timer.start(delay)
 
 
func _on_interval_timeout() -> void:
	if panel.visible:
		return
 
	_start_random_event()
 
 
func _start_random_event() -> void:
	var candidates: Array[Node2D] = _get_candidate_buildings()
	if candidates.is_empty():
		_schedule_next_event()
		return
 
	var building: Node2D = candidates[rng.randi_range(0, candidates.size() - 1)]
 
	var event_types: Array[String] = [EVENT_FIRE, EVENT_SEQUENCE, EVENT_REPAIR]
	var event_type: String = event_types[rng.randi_range(0, event_types.size() - 1)]
 
	active_event.clear()
	active_event["building"] = building
	active_event["type"] = event_type
 
	match event_type:
		EVENT_FIRE:
			active_event["target"] = 10
			active_event["count"] = 0
			title_label.text = "🔥 Hausbrand!"
			desc_label.text = "%s hat Feuer gefangen. Klicke schnell 10-mal, um den Brand zu löschen." % building.name
			instruction_label.text = "Fortschritt: 0 / 10"
			progress_bar.value = 0.0
			_show_mode(true, false, false)
			fail_timer.start(4.5)
 
		EVENT_SEQUENCE:
			var options: Array[String] = ["left", "up", "down", "right"]
			var seq: Array[String] = []
			for i: int in range(5):
				seq.append(options[rng.randi_range(0, options.size() - 1)])
 
			active_event["sequence"] = seq
			active_event["index"] = 0
			title_label.text = "🐀 Schädlingsalarm!"
			desc_label.text = "Bei %s breitet sich eine Rattenplage aus. Drücke die Pfeilfolge korrekt." % building.name
			instruction_label.text = "Folge: %s" % _sequence_to_text(seq)
			progress_bar.value = 0.0
			_show_mode(false, false, true)
			fail_timer.start(6.0)
 
		EVENT_REPAIR:
			hold_progress = 0.0
			hold_active = false
			active_event["target"] = 2.4
			title_label.text = "🌩 Sturmschaden!"
			desc_label.text = "%s wurde beschädigt. Halte den Button gedrückt, um das Dach rechtzeitig zu reparieren." % building.name
			instruction_label.text = "Reparaturfortschritt: 0%%"
			progress_bar.value = 0.0
			_show_mode(false, true, false)
			fail_timer.start(5.5)
 
	target_icon.visible = true
	panel.visible = true
	SignalBus.qte_event_started.emit(String(active_event.get("type", "")), building)
 
 
func _get_candidate_buildings() -> Array[Node2D]:
	var result: Array[Node2D] = []
 
	if houses == null:
		return result
 
	for child in houses.get_children():
		if child is Node2D and is_instance_valid(child):
			result.append(child as Node2D)
 
	return result
 
 
func _show_mode(show_mash: bool, show_hold: bool, show_arrows: bool) -> void:
	mash_button.visible = show_mash
	hold_button.visible = show_hold
	arrow_row.visible = show_arrows
	progress_bar.visible = true
 
 
func _on_mash_pressed() -> void:
	if String(active_event.get("type", "")) != EVENT_FIRE:
		return
 
	var count: int = int(active_event.get("count", 0)) + 1
	active_event["count"] = count
 
	instruction_label.text = "Fortschritt: %d / %d" % [count, int(active_event.get("target", 10))]
	progress_bar.value = clamp((float(count) / float(active_event.get("target", 10))) * 100.0, 0.0, 100.0)
 
	if count >= int(active_event.get("target", 10)):
		_resolve_event(true)
 
 
func _on_arrow_pressed(direction: String) -> void:
	if String(active_event.get("type", "")) != EVENT_SEQUENCE:
		return
 
	_sequence_input_step(direction)
 
 
func _sequence_input_step(direction: String) -> void:
	var sequence: Array = active_event.get("sequence", [])
	var index: int = int(active_event.get("index", 0))
 
	if index >= sequence.size():
		return
 
	if String(sequence[index]) == direction:
		index += 1
		active_event["index"] = index
		progress_bar.value = clamp((float(index) / float(sequence.size())) * 100.0, 0.0, 100.0)
		instruction_label.text = "Folge: %s\nRichtig: %d / %d" % [_sequence_to_text(sequence), index, sequence.size()]
 
		if index >= sequence.size():
			_resolve_event(true)
	else:
		active_event["index"] = 0
		progress_bar.value = 0.0
		instruction_label.text = "Falsche Richtung! Folge neu starten:\n%s" % _sequence_to_text(sequence)
 
 
func _on_hold_button_down() -> void:
	if String(active_event.get("type", "")) == EVENT_REPAIR:
		hold_active = true
 
 
func _on_hold_button_up() -> void:
	hold_active = false
 
 
func _update_target_icon() -> void:
	if target_icon == null:
		return
 
	if not active_event.has("building"):
		target_icon.visible = false
		return
 
	var building: Node2D = active_event.get("building") as Node2D
	if building == null or not is_instance_valid(building):
		target_icon.visible = false
		return
 
	var icon_map: Dictionary = {
		EVENT_FIRE: "🔥",
		EVENT_SEQUENCE: "🐀",
		EVENT_REPAIR: "🛠"
	}
 
	target_icon.text = String(icon_map.get(String(active_event.get("type", "")), "!"))
 
	var canvas_pos: Vector2 = get_viewport().get_canvas_transform() * building.global_position
	target_icon.position = canvas_pos + Vector2(-12, -64)
	target_icon.visible = true
 
 
func _on_event_failed() -> void:
	_resolve_event(false)
 
 
func _resolve_event(success: bool) -> void:
	hold_active = false
	target_icon.visible = false
 
	if fail_timer != null:
		fail_timer.stop()
 
	panel.visible = false
 
	if active_event.has("building"):
		SignalBus.qte_event_finished.emit(
			String(active_event.get("type", "")),
			success,
			active_event["building"]
		)
 
	_apply_outcome(success)
	active_event.clear()
	_schedule_next_event()
 
 
func _apply_outcome(success: bool) -> void:
	if not active_event.has("type"):
		return
 
	var event_type: String = String(active_event.get("type", ""))
 
	match event_type:
		EVENT_FIRE:
			if success:
				_change_resource("money", 5)
				_show_result("Brand gelöscht", "+5 Gold – deine Bürger feiern deinen Einsatz.")
			else:
				_change_resource("money", -15)
				_show_result("Brand außer Kontrolle", "-15 Gold – der Schaden musste teuer repariert werden.")
 
		EVENT_SEQUENCE:
			if success:
				_change_resource("lumber", 8)
				_show_result("Schädlinge vertrieben", "+8 Holz – Vorräte konnten gerettet werden.")
			else:
				_change_resource("lumber", -12)
				_show_result("Vorräte angefressen", "-12 Holz – die Ratten waren schneller.")
 
		EVENT_REPAIR:
			if success:
				_change_resource("stone", 6)
				_show_result("Dach gesichert", "+6 Stein – Material konnte wiederverwendet werden.")
			else:
				_change_resource("stone", -10)
				_show_result("Gebäude beschädigt", "-10 Stein – mehr Material für die Reparatur nötig.")
 
 
func _show_result(title: String, text: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = text
	add_child(dialog)
	_style_accept_dialog(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
 
 
func _change_resource(resource_name: String, delta: int) -> void:
	var allowed: Array[String] = ["money", "lumber", "stone"]
	if resource_name not in allowed:
		return
 
	var current: int = int(Globals.get(resource_name))
	var next_value: int = int(max(0, current + delta))
	Globals.set(resource_name, next_value)
	SignalBus.resource_changed.emit(resource_name, next_value)
 
 
func _sequence_to_text(seq: Array) -> String:
	var arrow_map := {
		"left": "←",
		"up": "↑",
		"down": "↓",
		"right": "→"
	}
 
	var parts: Array[String] = []
	for entry in seq:
		parts.append(String(arrow_map.get(String(entry), "?")))
 
	return " ".join(parts)
 
 
func try_start_qte_system() -> void:
	if qte_system_started:
		return
 
	if _get_candidate_buildings().is_empty():
		return
 
	qte_system_started = true
	_schedule_next_event()
