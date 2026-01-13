extends TextureRect

@export var building_scene: PackedScene
@export var building_id: String = "house_basic"

func _get_drag_data(_pos):
	if building_scene == null:
		push_warning("building_scene ist nicht gesetzt!")
		return null

	# Preview
	var preview := TextureRect.new()
	preview.texture = texture
	preview.modulate.a = 0.8
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(64, 64)
	set_drag_preview(preview)

	# Drag payload (Dictionary ist praktisch)
	return {
		"type": "building",
		"id": building_id,
		"scene": building_scene
	}
