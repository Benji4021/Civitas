extends Control

@onready var portrait_button = $Panel2/TextureButton
@onready var slide_panel = $ClipContainer/SlidePanel

var tween: Tween
var is_open := false

var open_x := 0.0
var closed_x := -420.0

func _ready():
	slide_panel.position.x = closed_x
	portrait_button.pressed.connect(_on_portrait_button_pressed)

func _on_portrait_button_pressed():
	is_open = !is_open

	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	if is_open:
		tween.tween_property(slide_panel, "position:x", open_x, 0.35)
	else:
		tween.tween_property(slide_panel, "position:x", closed_x, 0.35)
		
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		print("Clicked on:", get_viewport().gui_get_hovered_control())
