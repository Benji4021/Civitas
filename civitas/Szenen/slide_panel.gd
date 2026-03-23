extends Control

@export var panel_width: float = 350
@export var slide_time: float = 0.3

var is_open: bool = false

@onready var toggle_btn = $ToggleButton2

func _ready():
	# Panel initial rechts außerhalb
	position.x = get_viewport_rect().size.x

func _on_toggle_button_2_toggled(toggled_on):
	is_open = toggled_on
	
	var viewport_width = get_viewport_rect().size.x
	var target_x: float
	
	if is_open:
		target_x = viewport_width - panel_width 
		toggle_btn.scale.x = -1   # flip horizontally
	else:
		target_x = viewport_width 
		toggle_btn.scale.x = 1    # normal
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:x", target_x, slide_time)
