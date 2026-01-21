extends Node

var capacity := 5

func _ready():
	SignalBus.placed_resBuilding.connect(_on_placed)


func _on_placed() -> void:
	SignalBus.resBuilding_added.emit(5, self)
	
func _on_removed() -> void:
	SignalBus.resBuilding_removed.emit(5, self)
	
