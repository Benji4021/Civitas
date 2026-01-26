extends Control
# oder Node / Node2D – egal

@export var pause_overlay_scene: PackedScene

var pause_overlay_instance: Control = null
var pause_layer: CanvasLayer = null


func _on_pause_texture_button_pressed():
	if pause_overlay_instance != null:
		return

	# CanvasLayer erstellen
	pause_layer = CanvasLayer.new()
	pause_layer.layer = 100  # hoch genug → über ALLEM

	add_child(pause_layer)

	# Pause Overlay instanziieren
	pause_overlay_instance = pause_overlay_scene.instantiate()
	pause_layer.add_child(pause_overlay_instance)

	pause_overlay_instance.resume_pressed.connect(_on_resume)


func _on_resume():
	pause_layer.queue_free()
	pause_layer = null
	pause_overlay_instance = null
