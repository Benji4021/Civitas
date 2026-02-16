extends Control

@export var panel_width: float = 300
@export var slide_time: float = 0.3

var is_open: bool = false

@onready var toggle_btn = $ToggleButton


func _ready():
	# Panel initial rechts außerhalb
	position.x = get_viewport_rect().size.x
	toggle_btn.text = "<"


func _on_ToggleButton_pressed():
	is_open = !is_open

	var viewport_width = get_viewport_rect().size.x
	var target_x: float

	if is_open:
		# reinfahren
		target_x = viewport_width - panel_width
		toggle_btn.text = ">"
	else:
		# rausfahren
		target_x = viewport_width
		toggle_btn.text = "<"

	# Animation
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:x", target_x, slide_time)


func _on_toggle_button_pressed() -> void:
	pass # Replace with function body.
