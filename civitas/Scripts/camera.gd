extends Camera2D

# Bewegung
@export var move_speed: float = 900.0

# Zoom
@export var zoom_speed: float = 3.0        # Zoom-Einheiten pro Sekunde
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

# Exportierte Grenzen (andere Namen, damit sie die nativen Camera2D-Member nicht überschreiben)
@export var bounds_left: int = -1000
@export var bounds_right: int = 1000
@export var bounds_top: int = -1000
@export var bounds_bottom: int = 1000
@export var clamp_to_bounds: bool = true

func _ready():
	# Diese Kamera aktiv setzen
	make_current()

	# Falls du Grenzen verwenden willst -> die nativen limit_* Felder setzen
	if clamp_to_bounds:
		limit_left = bounds_left
		limit_right = bounds_right
		limit_top = bounds_top
		limit_bottom = bounds_bottom


func _physics_process(delta):
	# WASD / Pfeiltasten Bewegung (Input-Actions siehe weiter unten)
	var input_dir = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
	position += input_dir * move_speed * delta

	# Position innerhalb der Grenzen halten (falls aktiviert)
	if clamp_to_bounds:
		position.x = clamp(position.x, limit_left, limit_right)
		position.y = clamp(position.y, limit_top, limit_bottom)

	# Zoom steuern: E rein (zoom_in), Q raus (zoom_out)
	var new_zoom = zoom
	if Input.is_action_pressed("zoom_in"):
		new_zoom -= Vector2.ONE * zoom_speed * delta
	elif Input.is_action_pressed("zoom_out"):
		new_zoom += Vector2.ONE * zoom_speed * delta

	# Zoom-Grenzen anwenden
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	zoom = new_zoom
