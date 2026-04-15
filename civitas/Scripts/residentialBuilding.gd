extends Building

func _ready():
	SignalBus.placed_resBuilding.connect(_on_placed)
	
func _init() -> void:
	type = BuildingType.ResidentialBuilding
	cost_wood  = 20
	cost_stone = 5
	cost_money = 50
	_on_placed()


func _on_placed() -> void:
	SignalBus.resBuilding_added.emit(5, self)
	
func _on_removed() -> void:
	SignalBus.resBuilding_removed.emit(5, self)
	
