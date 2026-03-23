extends Control

@onready var ruler_edit = $Panel/TextureRect/ProfilSetting/VBoxContainer/LeaderLabel/LineEdit
@onready var kingdom_edit = $Panel/TextureRect/ProfilSetting/VBoxContainer/KingdomLabel/LineEdit
@onready var safe_btn = $Panel/TextureRect/ProfilSetting/SaveButton
@onready var statistics = $Panel/TextureRect/Statistiken
@onready var profile = $Panel/TextureRect/ProfilSetting

func _ready():
	safe_btn.visible = false
	ruler_edit.text = Globals.ruler_name
	kingdom_edit.text = Globals.kingdom_name
	statistics.visible = true
	profile.visible = false

func _physics_process(delta):
	if ruler_edit.text != Globals.ruler_name || kingdom_edit.text != Globals.kingdom_name:
		safe_btn.visible = true
	else:
		safe_btn.visible = false

func _on_close_btn_pressed():
	get_tree().change_scene_to_file("res://Szenen/Test.tscn")

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
