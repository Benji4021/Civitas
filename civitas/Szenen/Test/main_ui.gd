extends Control
@export var pause_overlay_scene: PackedScene

var pause_overlay_instance: Control = null
var pause_layer: CanvasLayer = null
var transition_layer: CanvasLayer = null
var transition_instance: Control = null
var transition_active: bool = false
var dayend_overlay_instance: Control = null
var dayend_layer: CanvasLayer = null
var book_overlay_instance: Control = null
var book_layer: CanvasLayer = null

@onready var day_label: Label = $Ui/InformationBoard/VBoxContainer/DayLabel
@onready var wood_label: Label = $Ui/InformationBoard/VBoxContainer/HBoxContainer2/TreePanel/HBoxContainer/Label
@onready var stone_label: Label = $Ui/InformationBoard/VBoxContainer/HBoxContainer2/StonePanel/HBoxContainer/Label
@onready var population_label: Label = $Ui/InformationBoard/VBoxContainer/HBoxContainer/PeoplePanel/HBoxContainer/Label
@onready var money_label: Label = $Ui/InformationBoard/VBoxContainer/HBoxContainer/MoneyPanel/HBoxContainer/Label
@onready var king_label: Label = $Ui/NamePanel/ClipContainer/SlidePanel/Label2
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
	var end_angle = deg_to_rad(90)
	pointer_pivot.rotation = lerp(start_angle, end_angle, progress)
			
func _on_resource_changed(resource_type: String, new_value: int) -> void:
	_update_resource(resource_type, new_value)



func _on_day_changed(new_day):
	day_label.text = "Tag " + str(new_day)
	_show_dayend_overlay(new_day - 1, new_day)
	
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
	if book_overlay_instance != null:
		return # Already open

	book_layer = CanvasLayer.new()
	book_layer.layer = 11 # higher than pause_layer

	add_child(book_layer)

	book_overlay_instance = load("res://Szenen/UI/book.tscn").instantiate()
	book_layer.add_child(book_overlay_instance)

	# Optional: connect signals from the overlay (e.g., close button)
	if book_overlay_instance.has_signal("close_pressed"):
		book_overlay_instance.connect("close_pressed", Callable(self, "_on_book_close_pressed"))


func _show_dayend_overlay(old_day: int, new_day: int) -> void:
	if dayend_overlay_instance != null:
		return

	dayend_layer = CanvasLayer.new()
	dayend_layer.layer = 11
	add_child(dayend_layer)

	var scene = load("res://Szenen/UI/Overlay_dayend.tscn")
	dayend_overlay_instance = scene.instantiate()
	dayend_layer.add_child(dayend_overlay_instance)


	dayend_overlay_instance.transition_finished.connect(_on_dayend_transition_finished)
	dayend_overlay_instance.start_transition(old_day, new_day)
	
func _on_dayend_transition_finished() -> void:
	if dayend_layer != null:
		dayend_layer.queue_free()
		dayend_layer = null
		dayend_overlay_instance = null

#func _input(event):
#	if event is InputEventMouseButton and event.pressed:
#		print("Clicked on:", get_viewport().gui_get_hovered_control())
