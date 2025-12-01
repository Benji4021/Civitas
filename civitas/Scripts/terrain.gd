extends Area2D

@export var clock_popup_scene: PackedScene
@export var removal_time := 2


var clicked := false

func _ready():
	$Clickable.connect("clicked", _on_clicked)

func _on_clicked():
	if not clicked:
		clicked = true
		handle_click()


func handle_click():
	print("Object!")

	if clock_popup_scene:
		var popup = clock_popup_scene.instantiate()
		add_child(popup)
		popup.position = Vector2(0, -32)

		if popup.has_method("start"):
			popup.start(removal_time)

	# 3 sek dann Szene löschen
	await get_tree().create_timer(removal_time).timeout
	queue_free()
