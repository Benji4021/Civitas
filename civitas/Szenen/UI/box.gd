extends TextureButton

@onready var amount_label = $StoneLabel
@onready var item_sprite = $FirstTradeImg

@export var closed_texture: Texture2D

var is_done := false

func _pressed() -> void:
	if is_done:
		return

	is_done = true

	# Box schließen
	texture_normal = closed_texture
	texture_hover = closed_texture
	texture_pressed = closed_texture

	# 🔥 DAS IST NEU → Zahl ausblenden
	amount_label.visible = false

	# optional: Item auch ausblenden
	# item_sprite.visible = false

	disabled = true
