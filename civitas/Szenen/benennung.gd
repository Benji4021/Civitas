extends Node2D

@onready var benennung = $CanvasLayer/Benennung

func _ready():
	benennung.visible = false
	if Globals.ruler_name == "" and Globals.kingdom_name == "":
		benennung.visible = true
		benennung.start_ruler_naming()
		Globals.input_locked = true
	else:
		benennung.visible = false
		Globals.input_locked = false
