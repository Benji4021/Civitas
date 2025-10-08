extends Camera2D

@export var move_speed: float = 75.0

func _physics_process(delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

	# normalize so diagonal isn’t faster
	if input_direction != Vector2.ZERO:
		input_direction = input_direction.normalized()

	position += input_direction * move_speed * delta
