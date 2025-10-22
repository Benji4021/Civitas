extends Area2D

func _ready():
	input_pickable = true  # ermöglicht Mausinteraktion

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Object!")
