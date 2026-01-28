extends Button

const SPEED = 50

var destination = Vector2(0, 0)

func _ready():
	pass

func _process(delta):
	var distance_to_destination
	var distance_to_move
	if position != destination: # only move if we aren't there
		distance_to_destination = position.distance_to(destination)
		distance_to_move = SPEED * delta
		if abs(distance_to_destination) < abs(distance_to_move): # if we are close, just move to destination
			distance_to_move = distance_to_destination
		position += position.direction_to(destination) * distance_to_move


func set_destination(new_destination):
	destination = new_destination
	print("new_destination:", new_destination)
