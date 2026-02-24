extends Area2D
class_name Terrain

var rng = RandomNumberGenerator.new()

@export var clock_popup_scene: PackedScene
@export var resource_type: String

var removal_time := 2.0
var clicked := false

var drop_amount_min := 5
var drop_amount_max := 10
var drop_amount


func _ready():
	SignalBus.terrain_clicked.connect(_on_bus_terrain_clicked)
	SignalBus.break_terrain.connect(_on_break_terrain)



func _on_bus_terrain_clicked(t: Node) -> void:
	if t != self:
		return
	if clicked:
		return

	print(self)
	SignalBus.check_capacity.emit(resource_type ,self)

func _on_break_terrain(requester: Node) -> void:
	if requester != self:
		return
	clicked = true

	_handle_clicked()

func _handle_clicked():
	drop_amount = rng.randf_range(drop_amount_min, drop_amount_max)
	print("Collected:", drop_amount, resource_type)

	if clock_popup_scene:
		var popup = clock_popup_scene.instantiate()
		add_child(popup)
		popup.position = Vector2(0, -32)

		if popup.has_method("start"):
			popup.start(removal_time)

	await get_tree().create_timer(removal_time).timeout
	SignalBus.finish_farming.emit(resource_type)
	SignalBus.collect_resources.emit(resource_type, drop_amount, self)
	queue_free()
