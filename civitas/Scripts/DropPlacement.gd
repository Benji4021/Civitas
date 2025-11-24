extends Control

func _can_drop_data(_pos, data):
	return data is Texture

func _drop_data(pos, data):
	var new_sprite = TextureRect.new()
	new_sprite.texture = data
	new_sprite.position = pos
	add_child(new_sprite)
