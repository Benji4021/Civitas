extends TextureButton

@export var open_texture: Texture2D
@export var closed_texture: Texture2D

@onready var amount_label = $StoneLabel
@onready var item_sprite = $FirstTradeImg

func show_open_state(amount_text: String, item_texture: Texture2D) -> void:
	if open_texture != null:
		texture_normal = open_texture
		texture_hover = open_texture
		texture_pressed = open_texture

	amount_label.text = amount_text
	amount_label.visible = true

	item_sprite.texture = item_texture
	item_sprite.visible = true

	disabled = false

func show_closed_state(item_texture: Texture2D, amount_text: String = "") -> void:
	if closed_texture != null:
		texture_normal = closed_texture
		texture_hover = closed_texture
		texture_pressed = closed_texture

	item_sprite.texture = item_texture
	item_sprite.visible = true

	amount_label.text = amount_text
	amount_label.visible = false

	disabled = true
