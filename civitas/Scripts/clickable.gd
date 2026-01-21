extends Area2D


func _ready():
	input_pickable = true

func _input_event(_v, event, _i):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		input_pickable = false
		print("Object clicked!")
		SignalBus.terrain_clicked.emit(get_parent())
