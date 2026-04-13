extends Control


func _on_close_btn_pressed():
	emit_signal("resume_pressed")
	queue_free()
