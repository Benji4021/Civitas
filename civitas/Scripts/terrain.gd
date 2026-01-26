extends Area2D
class_name Terrain

@export var clock_popup_scene: PackedScene
@export var resource_type: String = "lumber"

var removal_time := 2.0
var clicked := false
var drop_amount := 5


func _ready():
	SignalBus.terrain_clicked.connect(_on_bus_terrain_clicked)


func _on_bus_terrain_clicked(t: Node) -> void:
	if t != self:
		return
	if clicked:
		return

	clicked = true
	_handle_click()


func _handle_click():
	print("Collected:", drop_amount, resource_type)

	if clock_popup_scene:
		var popup = clock_popup_scene.instantiate()
		add_child(popup)
		popup.position = Vector2(0, -32)

		if popup.has_method("start"):
			popup.start(removal_time)

	await get_tree().create_timer(removal_time).timeout
	SignalBus.collect_resources.emit(resource_type, drop_amount, self)
	queue_free()
