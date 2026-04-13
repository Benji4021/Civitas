extends Control

signal resume_pressed

@onready var ruler_edit = $Panel/TextureRect/ProfilSetting/VBoxContainer/LeaderLabel/LineEdit
@onready var kingdom_edit = $Panel/TextureRect/ProfilSetting/VBoxContainer/KingdomLabel/LineEdit
@onready var safe_btn = $Panel/TextureRect/ProfilSetting/SaveButton
@onready var statistics = $Panel/TextureRect/Statistiken
@onready var profile = $Panel/TextureRect/ProfilSetting

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	safe_btn.visible = false
	ruler_edit.text = Globals.ruler_name
	kingdom_edit.text = Globals.kingdom_name
	statistics.visible = true
	profile.visible = false
	print(statistics)
	print(profile)
	print(safe_btn)


func _physics_process(delta):
	if ruler_edit.text != Globals.ruler_name || kingdom_edit.text != Globals.kingdom_name:
		safe_btn.visible = true
	else:
		safe_btn.visible = false
	
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
