extends Control

@onready var cratearea = $Crate
@onready var sellarea = $Sell
@onready var crate1 = $Crate/HBoxContainer/VBoxContainer/HBoxContainer/Crate1
@onready var crate4 = $Crate/HBoxContainer/VBoxContainer/HBoxContainer/Crate1
@onready var woodTradeLabel = $Crate/HBoxContainer/HBoxContainer2/VBoxContainer2/WoodLabel
@onready var stoneTradeLabel = $Crate/HBoxContainer/HBoxContainer2/VBoxContainer/StoneLabel

func _ready():
	cratearea.visible = true
	sellarea.visible = false
	
	var time_manager = get_node("/root/TimeManager") # adjust path if needed
	time_manager.connect("day_changed", Callable(self, "_on_day_changed"))
	
	_on_day_changed(time_manager.current_day) # update immediately

func _on_close_btn_pressed():
	emit_signal("resume_pressed")
	queue_free()

func _on_day_changed(day):
	var time_manager = get_node("/root/TimeManager")
	
	var wts = time_manager.wood_to_stone
	var stw = time_manager.stone_to_wood
	
	woodTradeLabel.text = str(wts.x) + "x"
	stoneTradeLabel.text = str(stw.x) + "x"
