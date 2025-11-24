extends TextureRect

func _get_drag_data(_pos):
	var drag_preview = TextureRect.new()
	drag_preview.texture = texture
	set_drag_preview(drag_preview)
	return self.texture
