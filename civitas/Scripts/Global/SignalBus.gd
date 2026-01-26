extends Node

#Terrain
signal terrain_clicked(terrain: Node)
signal collect_resources(amount: int, source: Node)

#Building
signal resBuilding_added(amount: int, source: Node)
signal resBuilding_removed(amount: int, source: Node)

signal placed_resBuilding()
signal removed_resBuilding()
