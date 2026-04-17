extends RefCounted
class_name BuildingPlacement

static func handle_placed(building: Node) -> void:
	if building == null:
		return

	SignalBus.building_added.emit(building)

	if building is ResidentalBuilding:
		SignalBus.resBuilding_added.emit(5, building)

static func handle_removed(building: Node) -> void:
	if building == null:
		return

	SignalBus.building_removed.emit(building)

	if building is ResidentalBuilding:
		SignalBus.resBuilding_removed.emit(5, building)
