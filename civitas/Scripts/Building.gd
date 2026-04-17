extends Node
class_name Building

enum BuildingType {
	ResidentialBuilding,
	Mine,
	Lumbermill,
	Windmill,
	Bank
}

var type: BuildingType = BuildingType.Windmill
var cost_wood: int = 0
var cost_stone: int = 0
var cost_money: int = 0
var capacity: int = 0

func get_costs() -> Dictionary:
	return {
		"wood": cost_wood,
		"stone": cost_stone,
		"money": cost_money,
	}
