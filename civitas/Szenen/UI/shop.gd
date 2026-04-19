extends Control

@onready var cratearea = $Both/Crate
@onready var sellarea = $Both/Sell
@onready var woodTradeLabel = $Both/Crate/HBoxContainer2/VBoxContainer2/WoodLabel
@onready var stoneTradeLabel = $Both/Crate/HBoxContainer2/VBoxContainer/StoneLabel
@onready var RessourcenLabel = $Both/Label2
@onready var wood_btn = $Both/Sell/Panel/VBoxContainer/HBoxContainer/TextureButton
@onready var stone_btn = $Both/Sell/Panel/VBoxContainer/HBoxContainer/TextureButton2
@onready var incrate_png = $Both/Sell/TextureRect/incrate

@onready var wood_icon = preload("res://Assets/woodtrade.png")
@onready var stone_icon = preload("res://Assets/stonetrade.png")
@onready var sold_icon = preload("res://Szenen/coins.png")

@onready var crates = [
	$Both/Crate/VBoxContainer/HBoxContainer/Crate1,
	$Both/Crate/VBoxContainer/HBoxContainer/Crate2,
	$Both/Crate/VBoxContainer/HBoxContainer/Crate3,
	$Both/Crate/VBoxContainer/HBoxContainer2/Crate4,
	$Both/Crate/VBoxContainer/HBoxContainer2/Crate5,
	$Both/Crate/VBoxContainer/HBoxContainer2/Crate6
]

@onready var crate1_label = $Both/Crate/VBoxContainer/HBoxContainer/Crate1/Label
@onready var crate1_img = $Both/Crate/VBoxContainer/HBoxContainer/Crate1/FirstTradeImg

@onready var amount = $Both/Sell/Panel/VBoxContainer/HBoxContainer4/Mengezahl
@onready var more = $Both/Sell/Panel/VBoxContainer/HBoxContainer2/TextureButton2
@onready var less = $Both/Sell/Panel/VBoxContainer/HBoxContainer2/TextureButton
@onready var yes_btn = $Both/Sell/Panel/VBoxContainer/HBoxContainer3/Yes
@onready var no_btn = $Both/Sell/Panel/VBoxContainer/HBoxContainer3/No

var selected_crate_id: int = -1
var current_amount: int = 0
var selected_resource: String = ""

func _ready():
	cratearea.visible = true
	sellarea.visible = false
	
	for crate in crates:
		crate.pressed.connect(_on_crate_pressed.bind(crate))
		
	var time_manager = get_node("/root/TimeManager") # adjust path if needed
	time_manager.connect("day_changed", Callable(self, "_on_day_changed"))
	time_manager.day_changed.connect(_on_day_changed)
	time_manager.connect("crate_updated", Callable(self, "_on_crate_updated"))

	
	_on_day_changed(time_manager.current_day) # update immediately
	more.pressed.connect(_on_more_pressed)
	less.pressed.connect(_on_less_pressed)
	SignalBus.resource_changed.connect(_on_resource_changed)
	update_resource_label()
	wood_btn.pressed.connect(_on_wood_selected)
	stone_btn.pressed.connect(_on_stone_selected)
	wood_btn.toggle_mode = true
	stone_btn.toggle_mode = true
	clear_selection()

	
	if Globals.crate_storage.is_empty():
		for crate in crates:
			Globals.crate_storage[crate.crate_id] = {
				"state": "empty", 
				# "empty" | "listed" | "sold"
				"resource": "",
				"amount": 0,
				"pending_money": 0
			}

	for crate in crates:
		update_crate_visual(crate)

	
func _on_close_btn_pressed():
	emit_signal("resume_pressed")
	queue_free()

func update_amount_label():
	amount.text = str(current_amount)

func _on_day_changed(day):
	var time_manager = get_node("/root/TimeManager")
	
	var wts = time_manager.wood_to_stone
	var stw = time_manager.stone_to_wood
	
	woodTradeLabel.text = str(wts.x) + "x"
	stoneTradeLabel.text = str(stw.x) + "x"

func _on_crate_pressed(crate):
	var data = Globals.crate_storage[crate.crate_id]

	if data["state"] == "sold":
		Globals.money += data["pending_money"]
		SignalBus.resource_changed.emit("money", Globals.money)

		# reset crate
		data["state"] = "empty"
		data["resource"] = ""
		data["amount"] = 0
		data["pending_money"] = 0

		Globals.crate_storage[crate.crate_id] = data

		update_crate_visual(crate)
		return

	selected_crate_id = crate.crate_id
	
	print("Clicked crate:", selected_crate_id)

	cratearea.visible = false
	sellarea.visible = true

func _on_wood_selected():
	selected_resource = "lumber"
	current_amount = 0

	wood_btn.button_pressed = true
	stone_btn.button_pressed = false

	incrate_png.texture = wood_icon

	update_amount_label()

func _on_stone_selected():
	selected_resource = "stone"
	current_amount = 0

	stone_btn.button_pressed = true
	wood_btn.button_pressed = false

	incrate_png.texture = stone_icon

	update_amount_label()

func clear_selection():
	selected_resource = ""
	current_amount = 0

	wood_btn.button_pressed = false
	stone_btn.button_pressed = false

	incrate_png.texture = null
	update_amount_label()

func _on_less_pressed():
	current_amount = max(0, current_amount - 1)
	update_amount_label()

func _on_more_pressed():
	if selected_resource == "":
		return
	
	var max_amount = 10
	
	if selected_resource == "lumber":
		max_amount = min(10, Globals.lumber)
	elif selected_resource == "stone":
		max_amount = min(10, Globals.stone)

	current_amount = min(current_amount + 1, max_amount)
	update_amount_label()

func _on_yes_pressed():
	if selected_resource == "" or current_amount <= 0:
		return

	if selected_resource == "lumber":
		if Globals.lumber < current_amount:
			return
		Globals.lumber -= current_amount
		SignalBus.resource_changed.emit("lumber", Globals.lumber)

	elif selected_resource == "stone":
		if Globals.stone < current_amount:
			return
		Globals.stone -= current_amount
		SignalBus.resource_changed.emit("stone", Globals.stone)
	var data = Globals.crate_storage[selected_crate_id]

	data["resource"] = selected_resource
	data["amount"] = current_amount
	data["state"] = "listed"
	data["pending_money"] = 0

	Globals.crate_storage[selected_crate_id] = data


	# update visual immediately
	for crate in crates:
		if crate.crate_id == selected_crate_id:
			update_crate_visual(crate)

	# reset UI
	current_amount = 0
	selected_resource = ""
	clear_selection()
	wood_btn.button_pressed = false
	stone_btn.button_pressed = false

	# switch back to crate view
	sellarea.visible = false
	cratearea.visible = true

	update_amount_label()

func _on_no_pressed():
	current_amount = 0
	selected_resource = ""
	wood_btn.button_pressed = false
	stone_btn.button_pressed = false

	sellarea.visible = false
	cratearea.visible = true
	clear_selection()

	update_amount_label()


func update_resource_label() -> void:
	RessourcenLabel.text = "Holz: " + str(Globals.lumber) + \
	"  Stein: " + str(Globals.stone) + \
	"  Geld: " + str(Globals.money)

func _on_resource_changed(resource_type: String, new_value: int) -> void:
	update_resource_label()

func update_crate_visual(crate):
	var data = Globals.crate_storage[crate.crate_id]

	var label = crate.get_node("Label")
	var img = crate.get_node("FirstTradeImg")

	# SOLD STATE
	if data["state"] == "sold":
		label.visible = false
		img.texture = sold_icon
		crate.disabled = false
		crate.modulate = Color(1, 1, 1)
		return

	# LISTED STATE
	if data["state"] == "listed":
		label.visible = true
		label.text = str(data["amount"])

		if data["resource"] == "lumber":
			img.texture = wood_icon
		elif data["resource"] == "stone":
			img.texture = stone_icon

		crate.disabled = true
		crate.modulate = Color(0.6, 0.6, 0.6)
		return

	# EMPTY STATE
	label.text = ""
	img.texture = null
	crate.disabled = false
	crate.modulate = Color(1, 1, 1)
