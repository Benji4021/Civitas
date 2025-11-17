extends Button

@onready var right_area = $"../HBoxContainer/RightArea"

func _on_pressed():
	print("Button gedrückt")
	var new_box = preload("res://Szenen/BoxContainer.tscn").instantiate()
	right_area.add_child(new_box)

	# sanfter Slide-In-Effekt
	new_box.modulate.a = 0.0
	new_box.scale = Vector2(0.8, 0.8)
	var tween = get_tree().create_tween()
	tween.tween_property(new_box, "modulate:a", 1.0, 0.3)
	tween.tween_property(new_box, "scale", Vector2.ONE, 0.3)
