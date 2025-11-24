extends Node2D

func start():
	modulate.a = 1.0
	position = Vector2(0, -20)
	
	var tween = get_tree().create_tween()
	tween.set_loops(6)

	tween.tween_property(self, "position:y", -30, 0.25)
	tween.tween_property(self, "position:y", -20, 0.25)

	
	#await get_tree().create_timer(3.0).timeout
	#queue_free()
