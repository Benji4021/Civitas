extends Control

func _can_drop_data(_pos, data):
	return data is Texture

func _drop_data(pos, data):
	var new_icon = TextureRect.new()
	new_icon.texture = data
	new_icon.position = pos
	new_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(new_icon)

	# kleiner Einblend-Effekt
	new_icon.scale = Vector2(0.5, 0.5)
	new_icon.modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.tween_property(new_icon, "scale", Vector2.ONE, 0.25)
	tween.tween_property(new_icon, "modulate:a", 1.0, 0.25)
