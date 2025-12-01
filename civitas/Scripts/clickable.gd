extends Area2D

signal clicked

func _ready():
	input_pickable = true

func _input_event(_v, event, _i):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("clicked")
