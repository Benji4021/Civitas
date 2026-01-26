extends Control
# oder Node / Node2D – egal

@export var pause_overlay_scene: PackedScene

var pause_overlay_instance: Control = null
var pause_layer: CanvasLayer = null
@onready var wood_label: Label = $Ui/InformationBoard/VBoxContainer/HBoxContainer2/TreePanel/HBoxContainer/Label
@onready var stone_label: Label = $Ui/InformationBoard/VBoxContainer/HBoxContainer2/StonePanel/HBoxContainer/Label
@onready var population_label: Label = $Ui/InformationBoard/VBoxContainer/HBoxContainer/PeoplePanel/HBoxContainer/Label
@onready var money_label: Label = $Ui/InformationBoard/VBoxContainer/HBoxContainer/MoneyPanel/HBoxContainer/Label

func _ready():
	SignalBus.resource_changed.connect(_on_resource_changed)

	_update_resource("lumber", Globals.lumber)
	_update_resource("stone", Globals.stone)
	_update_resource("population", Globals.population)
	_update_resource("money", Globals.money)


func _on_resource_changed(resource_type: String, new_value: int) -> void:
	_update_resource(resource_type, new_value)


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

	# CanvasLayer erstellen
	pause_layer = CanvasLayer.new()
	pause_layer.layer = 100  # hoch genug → über ALLEM

	add_child(pause_layer)
	# Pause Overlay instanziieren
	pause_overlay_instance = pause_overlay_scene.instantiate()
	pause_layer.add_child(pause_overlay_instance)

	pause_overlay_instance.resume_pressed.connect(_on_resume)


func _on_resume():
	pause_layer.queue_free()
	pause_layer = null
	pause_overlay_instance = null
