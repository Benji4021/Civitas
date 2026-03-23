extends Control
@export var pause_overlay_scene: PackedScene

var pause_overlay_instance: Control = null
var pause_layer: CanvasLayer = null
@onready var day_label: Label = $Ui/InformationBoard/VBoxContainer/DayLabel
@onready var wood_label: Label = $Ui/InformationBoard/VBoxContainer/HBoxContainer2/TreePanel/HBoxContainer/Label
@onready var stone_label: Label = $Ui/InformationBoard/VBoxContainer/HBoxContainer2/StonePanel/HBoxContainer/Label
@onready var population_label: Label = $Ui/InformationBoard/VBoxContainer/HBoxContainer/PeoplePanel/HBoxContainer/Label
@onready var money_label: Label = $Ui/InformationBoard/VBoxContainer/HBoxContainer/MoneyPanel/HBoxContainer/Label
@onready var king_label: Label = $Ui/NamePanel/Label2
@onready var pointer_pivot = $Ui/InformationBoard/Clock/PointerPivot
	
func _ready():
	SignalBus.resource_changed.connect(_on_resource_changed)
	TimeManager.day_changed.connect(_on_day_changed)
	
	day_label.text = "Tag " + str(TimeManager.current_day)
	_update_resource("lumber", Globals.lumber)
	_update_resource("stone", Globals.stone)
	_update_resource("population", Globals.population)
	_update_resource("money", Globals.money)
		
func _process(delta):
	if Globals.ruler_name != "" && Globals.kingdom_name != "":
		king_label.text = "Herrscher " + Globals.ruler_name + " aus Königreich " + Globals.kingdom_name
	var progress = TimeManager.get_day_progress()
	var start_angle = deg_to_rad(-90)
	var end_angle = deg_to_rad(270)
	pointer_pivot.rotation = lerp(start_angle, end_angle, progress)
			
func _on_resource_changed(resource_type: String, new_value: int) -> void:
	_update_resource(resource_type, new_value)
	
func _on_day_changed(new_day):
	day_label.text = "Tag " + str(new_day)
	
func _update_resource(resource_type: String, value: int) -> void:
	match resource_type:
		"lumber":
			wood_label.text = str(value)
		"stone":
			stone_label.text = str(value)
		"population":
			population_label.text = str(value)
		"money": 
			money_label.text = str(value)
	
func _on_pause_texture_button_pressed():
	if pause_overlay_instance != null:
		return
	
	pause_layer = CanvasLayer.new()
	pause_layer.layer = 10
	
	add_child(pause_layer)
	pause_overlay_instance = pause_overlay_scene.instantiate()
	pause_layer.add_child(pause_overlay_instance)
	
	pause_overlay_instance.resume_pressed.connect(_on_resume)

	
func _on_resume():
	pause_layer.queue_free()
	pause_layer = null
	pause_overlay_instance = null
	
	
func _on_ben_rater_btn_pressed():
	get_tree().change_scene_to_file("res://Szenen/UI/book.tscn")
