extends Node2D

func start(duration: float):
	modulate.a = 1.0
	#position = Vector2(0, -20)
	var start_y = position.y

	
	var tween = get_tree().create_tween()
	var loop_time := 0.5
	var loops :=int(duration/loop_time)
	if loops < 1: loops = 1
	tween.set_loops(loops)

	tween.tween_property(self, "position:y", start_y - 10, 0.25)
	tween.tween_property(self, "position:y", start_y, 0.25)
	
	#für baum auch sowas nehmen
	# Optional: nach Ende des Abbaus Popup ausblenden
	# var fade = get_tree().create_tween()
	# fade.tween_property(self, "modulate:a", 0.0, 0.3)

	
	#await get_tree().create_timer(3.0).timeout
	#queue_free()
