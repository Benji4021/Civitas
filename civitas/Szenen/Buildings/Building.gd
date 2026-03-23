extends Node

var cost_wood : int
var cost_stone : int
var cost_gold : int
var cost_people : int

var costs = [cost_wood, cost_stone, cost_gold, cost_people]

var BuildingType : Buildings

enum Buildings
{
		ResidentialBuilding,
		Mine,
		Lumbermill,
		Windmill,
		Bank
}

func _ready():
	SignalBus.placed_resBuilding.connect(_on_placed)
	
func _init() -> void:
	_on_placed()


func _on_placed() -> void:
	SignalBus.resBuilding_added.emit(5, self)
	
func _on_removed() -> void:
	SignalBus.resBuilding_removed.emit(5, self)
	
