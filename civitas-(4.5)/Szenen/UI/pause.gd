extends Control

signal resume_pressed

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP

func _on_button_pressed():
	emit_signal("resume_pressed")
	queue_free()
