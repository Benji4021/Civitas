extends Node2D

@onready var benennung = $CanvasLayer/Benennung
@onready var time_color: CanvasModulate = $TimeColor
var time_colors = [
	{ "time": 0.0,  "color": Color(0.07, 0.07, 0.2) },   # midnight
	{ "time": 0.2,  "color": Color(0.9, 0.5, 0.3) },     # sunrise
	{ "time": 0.35, "color": Color(1.0, 0.9, 0.6) },     # morning
	{ "time": 0.6,  "color": Color(1.0, 0.8, 0.7) },     # afternoon
	{ "time": 0.75, "color": Color(0.8, 0.3, 0.4) },     # sunset
	{ "time": 1.0,  "color": Color(0.07, 0.07, 0.2) }    # back to night
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
	time_color.color = get_time_color(progress)

func get_time_color(progress: float) -> Color:
	for i in range(time_colors.size() - 1):
		var current = time_colors[i]
		var next = time_colors[i + 1]
		
		if progress >= current.time and progress <= next.time:
			var local_t = inverse_lerp(current.time, next.time, progress)
			return current.color.lerp(next.color, local_t)
	
	return time_colors[-1].color
