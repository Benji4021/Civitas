extends VBoxContainer

func _ready():
	$HBoxContainer/Button.pressed.connect(_on_close_pressed)

func _on_close_pressed():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_callback(func(): queue_free())
