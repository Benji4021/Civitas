extends Button

@onready var right_area = $"../HBoxContainer/RightArea"
@onready var panel = $".."

func _on_pressed():
	print("Button gedrückt")
	panel.position += Vector2(-100, 0)
