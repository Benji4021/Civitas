extends Area2D

@export var clock_popup_scene: PackedScene

var clicked := false

func _ready():
	input_pickable = true

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and not clicked:

		clicked = true
		handle_click()


func handle_click():
	print("Object!")

	if clock_popup_scene:
		var popup = clock_popup_scene.instantiate()
		add_child(popup)
		popup.start()

	# 3 sek dann Szene löschen
	await get_tree().create_timer(3.0).timeout
	queue_free()
