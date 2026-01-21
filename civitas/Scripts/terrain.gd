extends Area2D

class_name Terrain

signal collect_resources(amount: int, source: Node)
signal terrain_clicked(terrain: Terrain)

@export var clock_popup_scene: PackedScene
# ENTFERNE: @export var removal_time := 2  # Nicht mehr exportieren

# Diese Variable wird vom Generator gesetzt
var removal_time := 2 # Standardwert
var clicked := false
var drop_amount := 5

func _ready():
	SignalBus.terrain_clicked.connect(_on_bus_terrain_clicked)
	
	
	#print("Terrain _ready läuft")
	#print("Clickable node:", $Clickable, " script:", $Clickable.get_script())
	#$Clickable.clicked.connect(_on_clicked)
	#print("Connected?", $Clickable.clicked.is_connected(_on_clicked))

func _on_bus_terrain_clicked(t: Node) -> void:
	if t != self:
		return
	if clicked:
		return
	clicked = true
	_handle_click()

func _handle_click():
	print("Signal recieved! Removal time: ", removal_time, "s")
	if clock_popup_scene:
		var popup = clock_popup_scene.instantiate()
		add_child(popup)
		popup.position = Vector2(0, -32)
		if popup.has_method("start"):
			popup.start(removal_time)
	
	# Warte die individuelle removal_time
	await get_tree().create_timer(removal_time).timeout
	SignalBus.collect_resources.emit(drop_amount, self)
	queue_free()
