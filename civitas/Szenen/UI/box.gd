extends TextureButton

@export var closed_texture: Texture2D

@onready var amount_label = $StoneLabel
@onready var item_sprite = $FirstTradeImg

var saved_open_normal: Texture2D
var saved_open_hover: Texture2D
var saved_open_pressed: Texture2D

func _ready() -> void:
	saved_open_normal = texture_normal
	saved_open_hover = texture_hover
	saved_open_pressed = texture_pressed

	item_sprite.z_index = 10
	amount_label.z_index = 11
	item_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_open_state(amount_text: String, item_texture: Texture2D) -> void:
	texture_normal = saved_open_normal
	texture_hover = saved_open_hover
	texture_pressed = saved_open_pressed

	if item_texture != null:
		item_sprite.texture = item_texture

	item_sprite.visible = true
	amount_label.text = amount_text
	amount_label.visible = true
	disabled = false

func show_closed_state(item_texture: Texture2D, amount_text: String = "") -> void:
	if closed_texture != null:
		texture_normal = closed_texture
		texture_hover = closed_texture
		texture_pressed = closed_texture

	item_sprite.visible = false
	amount_label.visible = false
	disabled = true
