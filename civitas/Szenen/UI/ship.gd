extends Control

@onready var crate1 = $Crate/HBoxContainer/VBoxContainer/HBoxContainer/Crate1
@onready var crate2 = $Crate/HBoxContainer/VBoxContainer/HBoxContainer/Crate2
@onready var crate3 = $Crate/HBoxContainer/VBoxContainer/HBoxContainer/Crate3

@onready var crate4 = $Crate/HBoxContainer/VBoxContainer/HBoxContainer2/Crate1
@onready var crate5 = $Crate/HBoxContainer/VBoxContainer/HBoxContainer2/Crate2
@onready var crate6 = $Crate/HBoxContainer/VBoxContainer/HBoxContainer2/Crate3

@export var stone_texture: Texture2D
@export var wood_texture: Texture2D

var crate_data = {}

func _ready() -> void:
	randomize()

	var time_manager = get_node("/root/TimeManager")
	time_manager.connect("day_changed", Callable(self, "_on_day_changed"))

	generate_new_trades()

func _on_close_btn_pressed() -> void:
	queue_free()

func _on_day_changed(day) -> void:
	generate_new_trades()

func get_all_crates() -> Array:
	return [crate1, crate2, crate3, crate4, crate5, crate6]

func generate_new_trades() -> void:
	var possible_items = ["stein", "holz"]

	for crate in get_all_crates():
		var item_name = possible_items.pick_random()
		var amount = randi_range(1, 5)
		var reward = amount * 3

		setup_crate(crate, item_name, amount, reward)

func setup_crate(crate: Node, item_name: String, amount: int, reward: int) -> void:
	var amount_label = crate.get_node_or_null("StoneLabel")
	var item_sprite = crate.get_node_or_null("FirstTradeImg")

	if amount_label == null:
		print("StoneLabel nicht gefunden in: ", crate.name)
		return

	if item_sprite == null:
		print("FirstTradeImg nicht gefunden in: ", crate.name)
		return

	amount_label.text = str(amount) + "x"

	if item_name == "stein":
		item_sprite.texture = stone_texture
	elif item_name == "holz":
		item_sprite.texture = wood_texture

	crate_data[crate.name] = {
		"item": item_name,
		"amount": amount,
		"reward": reward,
		"done": false
	}

	if crate is TextureButton:
		crate.disabled = false

func get_crate_info(crate_name: String) -> Dictionary:
	if crate_data.has(crate_name):
		return crate_data[crate_name]
	return {}
