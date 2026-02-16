extends TextureButton

func _on_pressed():
	if pause_overlay_instance:
		return

	pause_overlay_instance = pause_overlay_scene.instantiate()
	add_child(pause_overlay_instance)

	pause_overlay_instance.resume_pressed.connect(_on_resume)
