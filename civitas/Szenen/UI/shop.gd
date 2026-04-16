extends Control

@onready var cratearea = $Crate
@onready var sellarea = $Sell
@onready var woodTradeLabel = $Crate/HBoxContainer/HBoxContainer2/VBoxContainer2/WoodLabel
@onready var stoneTradeLabel = $Crate/HBoxContainer/HBoxContainer2/VBoxContainer/StoneLabel

@onready var crates = [
	$Crate/HBoxContainer/VBoxContainer/HBoxContainer/Crate1,
	$Crate/HBoxContainer/VBoxContainer/HBoxContainer/Crate2,
	$Crate/HBoxContainer/VBoxContainer/HBoxContainer/Crate3,
	$Crate/HBoxContainer/VBoxContainer/HBoxContainer2/Crate4,
	$Crate/HBoxContainer/VBoxContainer/HBoxContainer2/Crate5,
	$Crate/HBoxContainer/VBoxContainer/HBoxContainer2/Crate6
]

@onready var amount = $Sell/HBoxContainer/Panel/VBoxContainer/HBoxContainer4/Mengezahl
@onready var more = $Sell/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/TextureButton2
@onready var less = $Sell/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/TextureButton

var selected_crate_id: int = -1
var current_amount: int = 0

func _ready():
	cratearea.visible = true
	sellarea.visible = false

	for crate in crates:
		crate.pressed.connect(_on_crate_pressed.bind(crate))
		
	var time_manager = get_node("/root/TimeManager") # adjust path if needed
	time_manager.connect("day_changed", Callable(self, "_on_day_changed"))
	
	_on_day_changed(time_manager.current_day) # update immediately
	more.pressed.connect(_on_more_pressed)
	less.pressed.connect(_on_less_pressed)

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
	selected_crate_id = crate.crate_id
	
	print("Clicked crate:", selected_crate_id)
	
	cratearea.visible = false
	sellarea.visible = true

func _on_less_pressed():
	current_amount = max(0, current_amount - 1)
	update_amount_label()

func _on_more_pressed():
	current_amount += 1
	update_amount_label()
