extends Node2D

@onready var benennung = $CanvasLayer/Benennung

var ruler_named := false
var kingdom_named := false

func _ready():
	if not ruler_named and not kingdom_named:
#		benennung.visible = true
		#benennung.start_ruler_naming()
		Globals.input_locked = true
	else:
		Globals.input_locked = false
