extends Control

@onready var crate1 = $Crate/HBoxContainer/VBoxContainer/HBoxContainer/Crate1
@onready var crate2 = $Crate/HBoxContainer/VBoxContainer/HBoxContainer/Crate2
@onready var crate3 = $Crate/HBoxContainer/VBoxContainer/HBoxContainer/Crate3

@onready var crate4 = $Crate/HBoxContainer/VBoxContainer/HBoxContainer2/Crate1
@onready var crate5 = $Crate/HBoxContainer/VBoxContainer/HBoxContainer2/Crate2
@onready var crate6 = $Crate/HBoxContainer/VBoxContainer/HBoxContainer2/Crate3

@export var stone_texture: Texture2D
@export var lumber_texture: Texture2D

func _ready() -> void:
	var time_manager = get_node("/root/TimeManager")
	time_manager.day_changed.connect(_on_day_changed)

	for crate in get_all_crates():
		crate.pressed.connect(func(): _on_crate_pressed(crate))

	if Globals.ship_trades.is_empty() or Globals.ship_trades_day != TimeManager.current_day:
		generate_new_trades()

	load_existing_trades()

func _on_close_btn_pressed() -> void:
	queue_free()

func _on_day_changed(day: int) -> void:
	generate_new_trades()
	load_existing_trades()

func get_all_crates() -> Array:
	return [crate1, crate2, crate3, crate4, crate5, crate6]

func generate_new_trades() -> void:
	var possible_items = ["stone", "lumber"]
	var crates = get_all_crates()

	Globals.ship_trades.clear()

	for i in range(crates.size()):
		var item_name = possible_items.pick_random()
		var amount = randi_range(1, 5)
		var reward = amount * 3

		Globals.ship_trades.append({
			"item": item_name,
			"amount": amount,
			"reward": reward,
			"done": false
		})

	Globals.ship_trades_day = TimeManager.current_day

func load_existing_trades() -> void:
	var crates = get_all_crates()

	for i in range(crates.size()):
		if i < Globals.ship_trades.size():
			apply_trade_to_crate(crates[i], Globals.ship_trades[i])

func apply_trade_to_crate(crate: TextureButton, data: Dictionary) -> void:
	var item_texture = get_item_texture(data["item"])
	var amount_text = str(data["amount"]) + "x"

	if data["done"]:
		crate.show_closed_state(item_texture, amount_text)
	else:
		crate.show_open_state(amount_text, item_texture)

func get_item_texture(item_name: String) -> Texture2D:
	if item_name == "stone":
		return stone_texture
	elif item_name == "lumber":
		return lumber_texture
	return null

func _on_crate_pressed(crate: TextureButton) -> void:
	try_fill_crate(crate)

func try_fill_crate(crate: TextureButton) -> void:
	var index = get_all_crates().find(crate)
	if index == -1:
		return

	if index >= Globals.ship_trades.size():
		return

	var data = Globals.ship_trades[index]

	if data["done"]:
		return

	var item_name: String = data["item"]
	var amount: int = data["amount"]
	var reward: int = data["reward"]

	if not has_enough_resource(item_name, amount):
		print("Nicht genug ", item_name)
		return

	remove_resource(item_name, amount)
	add_money(reward)

	data["done"] = true
	Globals.ship_trades[index] = data

	apply_trade_to_crate(crate, data)

func has_enough_resource(resource_type: String, amount: int) -> bool:
	match resource_type:
		"stone":
			return Globals.stone >= amount
		"lumber":
			return Globals.lumber >= amount
		_:
			return false

func remove_resource(resource_type: String, amount: int) -> void:
	match resource_type:
		"stone":
			Globals.stone -= amount
			SignalBus.resource_changed.emit("stone", Globals.stone)
		"lumber":
			Globals.lumber -= amount
			SignalBus.resource_changed.emit("lumber", Globals.lumber)

func add_money(amount: int) -> void:
	Globals.money += amount
	SignalBus.resource_changed.emit("money", Globals.money)
