extends TextureButton

@export var house_type: String = ""
@export var house_scene: PackedScene

func _get_drag_data(pos):
	var data = {
		"type": house_type,
		"scene": house_scene
	}
	var preview = TextureRect.new()
	preview.texture = self.texture_normal
	preview.modulate.a = 0.7
	set_drag_preview(preview)

	return data
