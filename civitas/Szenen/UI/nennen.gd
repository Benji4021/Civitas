extends Control

@onready var title_label = $Panel/TextureRect/Label
@onready var name_input = $Panel/TextureRect/LineEdit
@onready var btn = $Button

var phase := "story"

func _ready():
	name_input.max_length = 20
	name_input.visible = false

func start_story():
	Globals.input_locked = true
	phase = "story"
	btn.text = "Weiter"
	title_label.text = "Du wachst an einem unbekannten Ort auf und hast nur ein Ziel:                    Macht"

func start_ruler_naming():
	Globals.input_locked = true
	phase = "ruler"
	btn.text = "Speichern"
	title_label.text = "Name deines Königs:"
	name_input.visible = true
	name_input.text = ""
	visible = true
	name_input.grab_focus()

func start_kingdom_naming():
	Globals.input_locked = true
	phase = "kingdom"
	btn.text = "Speichern"
	title_label.text = "Name deines Königreichs:"
	name_input.text = ""
	visible = true
	name_input.grab_focus()

func _on_button_pressed():
	match phase:
		"story":
			start_ruler_naming()

		"ruler":
			if name_input.text.strip_edges() == "":
				return
			Globals.ruler_name = name_input.text.strip_edges()
			start_kingdom_naming()

		"kingdom":
			if name_input.text.strip_edges() == "":
				return
			Globals.kingdom_name = name_input.text.strip_edges()

			Globals.input_locked = false
			visible = false
