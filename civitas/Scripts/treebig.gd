extends Area2D

@export var clock_popup_scene: PackedScene
# ENTFERNE: @export var removal_time := 2  # Nicht mehr exportieren

# Diese Variable wird vom Generator gesetzt
var removal_time := 2.0  # Standardwert
var clicked := false

func _ready():
	$Clickable.connect("clicked", _on_clicked)

func _on_clicked():
	if not clicked:
		clicked = true
		handle_click()

func handle_click():
	print("Object clicked! Removal time: ", removal_time, "s")
	
	if clock_popup_scene:
		var popup = clock_popup_scene.instantiate()
		add_child(popup)
		popup.position = Vector2(0, -32)
		
		if popup.has_method("start"):
			popup.start(removal_time)
	
	# Warte die individuelle removal_time
	await get_tree().create_timer(removal_time).timeout
	queue_free()
