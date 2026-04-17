extends Control

signal resume_pressed

@onready var ruler_edit = $Panel/TextureRect/ProfilSetting/VBoxContainer/LeaderLabel/LineEdit
@onready var kingdom_edit = $Panel/TextureRect/ProfilSetting/VBoxContainer/KingdomLabel/LineEdit
@onready var safe_btn = $Panel/TextureRect/ProfilSetting/SaveButton
@onready var statistics = $Panel/TextureRect/Statistiken
@onready var profile = $Panel/TextureRect/ProfilSetting

@onready var statistics_label = $Panel/TextureRect/Statistiken/Label3

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	safe_btn.visible = false
	ruler_edit.text = Globals.ruler_name
	kingdom_edit.text = Globals.kingdom_name
	statistics.visible = true
	profile.visible = false

	update_statistics()

	if not SignalBus.resource_changed.is_connected(_on_resource_changed):
		SignalBus.resource_changed.connect(_on_resource_changed)

func _physics_process(delta):
	if ruler_edit.text != Globals.ruler_name or kingdom_edit.text != Globals.kingdom_name:
		safe_btn.visible = true
	else:
		safe_btn.visible = false

func update_statistics():
	statistics_label.text = "Abbauzeiten:\n" + \
		"Stein: 5s\n" + \
		"Holz: 10s\n\n" + \
		"Ressourcen:\n" + \
		"Holz: " + str(Globals.lumber) + "\n" + \
		"Stein: " + str(Globals.stone) + "\n" + \
		"Geld: " + str(Globals.money) + "\n" + \
		"Bevölkerung: " + str(Globals.population)
		
func _on_resource_changed(resource_type: String, new_value: int) -> void:
	update_statistics()

func _on_save_button_pressed():
	Globals.ruler_name = ruler_edit.text
	Globals.kingdom_name = kingdom_edit.text
	safe_btn.visible = false

func _on_continue_btn_pressed():
	statistics.visible = false
	profile.visible = true

func _on_previous_btn_pressed():
	profile.visible = false
	statistics.visible = true

func _on_close_btn_pressed():
	emit_signal("resume_pressed")
	queue_free()
