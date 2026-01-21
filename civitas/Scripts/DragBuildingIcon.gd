extends TextureRect

@export var building_scene: PackedScene
@export var building_id: String = "house_basic"
@export var footprint: Vector2i = Vector2i.ONE
	
func _get_drag_data(_pos):
	if building_scene == null:
		push_warning("building_scene ist nicht gesetzt!")
		return null

	var preview: TextureRect = TextureRect.new()
	preview.texture = texture
	preview.modulate.a = 0.8
	preview.custom_minimum_size = Vector2(64, 64)
	set_drag_preview(preview)
	
	return {
		"type": "building",
		"id": building_id,
		"scene": building_scene,
		"world_texture": texture,
		"footprint": footprint
	}
