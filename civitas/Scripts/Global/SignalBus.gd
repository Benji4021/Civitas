extends Node

# Terrain
signal terrain_clicked(terrain: Node)
signal collect_resources(resource_type: String, amount: int, source: Node)
signal break_terrain(requester: Node)
signal check_capacity(resource_type: String, requester: Node)
signal finish_farming(resource_type: String)

# Building (generic)
signal resBuilding_added(amount: int, source: Node)
signal resBuilding_removed(amount: int, source: Node)

signal placed_resBuilding()
signal removed_resBuilding()

signal building_added(source: Node)
signal building_removed(source: Node)
signal placed_building()

# Mine / LumberMill
signal mineBuilding_placed(amount: int, source: Node)
signal mineBuilding_removed(amount: int, source: Node)

signal lumberMillBuilding_placed(amount: int, source: Node)
signal lumberMillBuilding_removed(amount: int, source: Node)

# UI
signal resource_changed(resource_type: String, new_value: int)
signal missing_resources_requested(missing: Dictionary)
