extends Node

var lumber := 0
var stone := 0
var money := 0

var population_capacity := 5
var population := 5


func _ready() -> void:
	# Terrain
	SignalBus.collect_resources.connect(_on_collect_resources)

	# Building
	SignalBus.resBuilding_added.connect(_on_resBuilding_added)
	SignalBus.resBuilding_removed.connect(_on_resBuilding_removed)


func _on_collect_resources(resource_type: String, amount: int, source: Node) -> void:
	modify(resource_type, amount)
	print(
		resource_type.capitalize(), ":",
		get(resource_type),
		"(+", amount, " from ", source.name, ")"
	)


func _on_resBuilding_added(amount: int, source: Node) -> void:
	population_capacity += amount
	print("Population capacity:", population_capacity, "(+", amount, " from ", source.name, ")")


func _on_resBuilding_removed(amount: int, source: Node) -> void:
	population_capacity -= amount
	print("Population capacity:", population_capacity, "(-", amount, " from ", source.name, ")")

func modify(var_name: String, amount: float) -> void:
	if not has_variable(var_name):
		push_error("Globals: Variable '%s' existiert nicht!" % var_name)
		return

	set(var_name, get(var_name) + amount)

	SignalBus.resource_changed.emit(var_name, get(var_name))

func has_variable(var_name: String) -> bool:
	for p in get_property_list():
		if p.name == var_name:
			return true
	return false
