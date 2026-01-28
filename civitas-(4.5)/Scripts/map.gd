extends TileMap

const GRID_SIZE = 4
var TILE_LIST: Dictionary = {}

func _ready():
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var cell = Vector2i(x, y)
			TILE_LIST[cell] = {
				"type": "Ground",
				"occupied": false
			}
			
			# Paint tile index 0 at (x,y)
			set_cell(0, cell, 0, Vector2i(0, 0))

func try_place_house(cell: Vector2i):
	if not TILE_LIST.has(cell):
		return false

	if TILE_LIST[cell].occupied:
		return false
	
	if TILE_LIST[cell].type != "Ground":
		return false

	# Place your house
	var house = preload("res://Szenen/Buildings/TestHouse.tscn").instantiate()
	house.position = map_to_local(cell)
	add_child(house)

	TILE_LIST[cell].occupied = true
	
	return true
