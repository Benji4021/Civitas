extends Node

@export var capacity: int = 5

func on_placed() -> void:
	SignalBus.resBuilding_added.emit(capacity, self)

func on_removed() -> void:
	SignalBus.resBuilding_removed.emit(capacity, self)


func _on_placed() -> void:
	SignalBus.resBuilding_added.emit(5, self)
	
func _on_removed() -> void:
	SignalBus.resBuilding_removed.emit(5, self)
	
