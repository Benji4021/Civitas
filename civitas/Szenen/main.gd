extends Node2D

@onready var benennung = $CanvasLayer/Benennung
@onready var time_color: CanvasModulate = $TimeColor

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

