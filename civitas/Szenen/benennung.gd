extends Node2D

@onready var benennung = $CanvasLayer/Benennung
@onready var time_color: CanvasModulate = $TimeColor
var shop_overlay_instance: Control = null
var shop_layer: CanvasLayer = null

var time_colors = [
	{ "time": 0.75,  "color": Color(0.9, 0.5, 0.3) },     # sunrise
	{ "time": 0.35, "color": Color(1.0, 0.9, 0.6) },     # morning
	{ "time": 0.0,  "color": Color(1.0, 0.8, 0.7) },     # afternoon
	{ "time": 1.0,  "color": Color(0.179, 0.18, 0.42, 1.0) }    # back to night
]

func _ready():
	benennung.visible = false
	if Globals.ruler_name == "" and Globals.kingdom_name == "":
		benennung.visible = true
		benennung.start_story()
		Globals.input_locked = true
	else:
		benennung.visible = false
		Globals.input_locked = false

func _process(delta):
	var progress = TimeManager.get_day_progress()
	time_color.color = Color(0.978, 0.826, 0.697, 1.0).lerp(Color(0.27, 0.271, 0.519, 1.0), abs(sin(progress * PI)))

func get_time_color(progress: float) -> Color:
	for i in range(time_colors.size() - 1):
		var current = time_colors[i]
		var next = time_colors[i + 1]

		if progress >= current.time and progress <= next.time:
			var local_t = inverse_lerp(current.time, next.time, progress)
			return current.color.lerp(next.color, local_t)

	return time_colors[-1].color

func _on_texture_button_pressed():
	if shop_overlay_instance != null:
		return # Already open

	shop_layer = CanvasLayer.new()
	shop_layer.layer = 11 # higher than pause_layer

	add_child(shop_layer)

	shop_overlay_instance = load("res://Szenen/UI/shop.tscn").instantiate()
	shop_layer.add_child(shop_overlay_instance)
