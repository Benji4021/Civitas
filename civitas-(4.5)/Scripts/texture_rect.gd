extends TextureRect

func _get_drag_data(_pos):
	var preview = TextureRect.new()
	preview.texture = texture
	preview.modulate.a = 0.8
	set_drag_preview(preview)
	return texture
