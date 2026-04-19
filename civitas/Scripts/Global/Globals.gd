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
var ship_trades: Array = []
var ship_trades_day: int = -1
var crate_storage = {}
var daily_customers = []
var customers_day = -1


func _ready() -> void:
	# Terrain
	SignalBus.collect_resources.connect(_on_collect_resources)
	SignalBus.check_capacity.connect(_on_check_capacity)
	SignalBus.finish_farming.connect(_on_finish_farming)

	# Building
	SignalBus.resBuilding_added.connect(_on_resBuilding_added)
	SignalBus.resBuilding_removed.connect(_on_resBuilding_removed)
	SignalBus.mineBuilding_removed.connect(_on_mineBuilding_removed)
	SignalBus.mineBuilding_removed.connect(_on_mineBuilding_removed)
	SignalBus.lumberMillBuilding_removed.connect(_on_lumberMillBuilding_removed)
	SignalBus.lumberMillBuilding_removed.connect(_on_lumberMillBuilding_removed)
	SignalBus.building_added.connect(_on_building_added)
	SignalBus.building_removed.connect(_on_building_removed)

func _on_building_added(source: Node) -> void:
	print("Gebäude platziert: ", source.name)

func _on_building_removed(source: Node) -> void:
	print("Gebäude entfernt: ", source.name)

func _on_collect_resources(resource_type: String, amount: int, source: Node) -> void:
	modify(resource_type, amount)
	print(resource_type.capitalize(), ":", get(resource_type), "(+", amount, " from ", source.name, ")")

func can_afford(wood: int, stone_cost: int, money_cost: int) -> bool:
	return lumber >= wood and stone >= stone_cost and money >= money_cost

func missing(wood: int, stone_cost: int, money_cost: int) -> Dictionary:
	var m := {}
	if lumber < wood:
		m["wood"] = wood - lumber
	if stone < stone_cost:
		m["stone"] = stone_cost - stone
	if money < money_cost:
		m["money"] = money_cost - money
	return m

func spend(wood: int, stone_cost: int, money_cost: int) -> void:
	lumber -= wood
	stone -= stone_cost
	money -= money_cost
	SignalBus.resource_changed.emit("lumber", lumber)
	SignalBus.resource_changed.emit("stone", stone)
	SignalBus.resource_changed.emit("money", money)

func _on_resBuilding_added(amount: int, source: Node) -> void:
	population += amount
	SignalBus.resource_changed.emit("population", population)
	print("Population:", population, "(+", amount, " from ", source.name, ")")

func _on_resBuilding_removed(amount: int, source: Node) -> void:
	population -= amount
	SignalBus.resource_changed.emit("population", population)
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
	
func _on_check_capacity(resource_type: String, requester: Node) -> void:
	if resource_type == "lumber":
		if lumber_capacity != null:
			if lumber_capacity > 0:
				lumber_capacity -= 1
				SignalBus.break_terrain.emit(requester)
			return
		if start_capacity > 0:
			start_capacity -= 1
			SignalBus.break_terrain.emit(requester)
		return

	if resource_type == "stone":
		if stone_capacity != null:
			if stone_capacity > 0:
				stone_capacity -= 1
				SignalBus.break_terrain.emit(requester)
			return
		if start_capacity > 0:
			start_capacity -= 1
			SignalBus.break_terrain.emit(requester)
		return
	
func _on_finish_farming(resource_type: String) -> void:
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

	start_capacity += 1
