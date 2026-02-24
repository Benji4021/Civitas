extends Node

var ruler_name: String = ""
var kingdom_name: String = ""

var input_locked := false

var lumber := 50
var stone := 50
var money := 50

var population := 5

var lumber_capacity = null
var stone_capacity = null
var start_capacity = 1


func _ready() -> void:
	# Terrain
	SignalBus.collect_resources.connect(_on_collect_resources)

#	SignalBus.check_capacity.connect(_on_check_capacity)
#	SignalBus.finish_farming.connect(_on_finish_farming)

	# Building
	SignalBus.resBuilding_added.connect(_on_resBuilding_added)
	SignalBus.resBuilding_removed.connect(_on_resBuilding_removed)

#	SignalBus.mineBuilding_removed.connect(_on_mineBuilding_removed)
#	SignalBus.mineBuilding_removed.connect(_on_mineBuilding_removed)
#	SignalBus.lumberMillBuilding_removed.connect(_on_lumberMillBuilding_removed)
#	SignalBus.lumberMillBuilding_removed.connect(_on_lumberMillBuilding_removed)

	
	


func _on_collect_resources(resource_type: String, amount: int, source: Node) -> void:
	modify(resource_type, amount)
	print(
		resource_type.capitalize(), ":",
		get(resource_type),
		"(+", amount, " from ", source.name, ")"
	)


func _on_resBuilding_added(amount: int, source: Node) -> void:
	population += amount
	print("Population:", population, "(+", amount, " from ", source.name, ")")


func _on_resBuilding_removed(amount: int, source: Node) -> void:
	population -= amount
	print("Population:", population, "(-", amount, " from ", source.name, ")")
	
func _on_mineBuilding_placed(amount: int, source: Node) -> void:
	if stone_capacity == null:
		stone_capacity = amount
	else:
		stone_capacity += amount
	print("stone_capacity:", stone_capacity, "(+", amount, " from ", source.name, ")")

func _on_mineBuilding_removed(amount: int, source: Node) -> void:
	stone_capacity -= amount
	if stone_capacity <= 0:
		stone_capacity = null
	print("stone_capacity:", stone_capacity, "(-", amount, " from ", source.name, ")")
	
func _on_lumberMillBuilding_placed(amount: int, source: Node) -> void:
	if lumber_capacity == null:
		lumber_capacity = amount
	else:
		lumber_capacity += amount
	print("lumber_capacity:", lumber_capacity, "(+", amount, " from ", source.name, ")")

func _on_lumberMillBuilding_removed(amount: int, source: Node) -> void:
	lumber_capacity -= amount
	if lumber_capacity <= 0:
		lumber_capacity = null
	print("lumber_capacity:", lumber_capacity, "(-", amount, " from ", source.name, ")")

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
	
func _on_check_capacity(resource_type: String) -> bool:
	if resource_type == "lumber":
		# normal, wenn gesetzt
		if lumber_capacity != null:
			if lumber_capacity > 0:
				lumber_capacity -= 1
				return true
			return false

		# fallback, wenn nicht gesetzt
		if start_capacity > 0:
			start_capacity -= 1
			return true
		return false

	if resource_type == "stone":
		if stone_capacity != null:
			if stone_capacity > 0:
				stone_capacity -= 1
				return true
			return false

		if start_capacity > 0:
			start_capacity -= 1
			return true
		return false

	return false
	
func _on_finish_farming(resource_type: String) -> void:
	# Wenn noch kein spezielles Gebäude gesetzt ist: start_capacity wieder freigeben
	if resource_type == "lumber":
		if lumber_capacity == null:
			start_capacity += 1
		else:
			lumber_capacity += 1
		return

	if resource_type == "stone":
		if stone_capacity == null:
			start_capacity += 1
		else:
			stone_capacity += 1
		return

	# falls ein anderer Typ kommt -> Standard
	start_capacity += 1
	
