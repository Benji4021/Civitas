extends RefCounted
class_name BuildingDB

const COSTS := {
	"Basic_House": {"gold": 20, "stone": 30, "wood": 10},
	"Muehle": {"gold": 40, "stone": 10, "wood": 40},
}

static func get_costs(building_id: String) -> Dictionary:
	return COSTS.get(building_id, {"gold": 0, "stone": 0, "wood": 0}).duplicate(true)
