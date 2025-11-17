extends Button

@onready var right_area = $"../HBoxContainer/RightArea"

func _on_pressed():
	var new_box = preload("res://Szenen/BoxContainer.tscn").instantiate()
	right_area.add_child(new_box)
