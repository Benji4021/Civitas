extends Control

@export var ground_tilemap_path: NodePath = NodePath("../TileMapLayer")
@export var houses_parent_path: NodePath = NodePath("../Houses")
@export var obstacle_spawner_path: NodePath = NodePath("../ObstacleSpawner")
@export var occupied_source_id: int = 0
@export var occupied_atlas_coord: Vector2i = Vector2i(0, 0)
@export var occupied_alt: int = 0  # meistens 0


@onready var ground = get_node_or_null(ground_tilemap_path)
@onready var houses_parent: Node2D = get_node_or_null(houses_parent_path)
@onready var obstacle_spawner = get_node_or_null(obstacle_spawner_path)

# Belegung: jedes Tile -> Hausnode
var occupied: Dictionary = {} # Vector2i -> Node2D
var original_ground: Dictionary = {} # Vector2i -> {"source":int, "atlas":Vector2i, "alt":int}


# Ghost
var ghost_node: Node2D = null
var dragging_data: Dictionary = {}

func _ready():
	if ground == null:
		push_error("MapDropArea: ground_tilemap_path falsch (z.B. ../TileMapLayer)")
		return
	if houses_parent == null:
		push_error("MapDropArea: houses_parent_path falsch (z.B. ../Houses)")
		return

func _process(_delta):
	if dragging_data.is_empty() or ghost_node == null or ground == null:
		if ghost_node != null:
			ghost_node.visible = false
		return

	var tiles: Array[Vector2i] = _tiles_under_mouse(dragging_data)

	ghost_node.global_position = _footprint_center_global(tiles)

	var can_place: bool = not _is_blocked_tiles(tiles)
	ghost_node.modulate = Color(1,1,1,0.55) if can_place else Color(1,0.25,0.25,0.55)

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragging_data.clear()
		ghost_node.visible = false

func _can_drop_data(_pos, data):
	var ok: bool = typeof(data) == TYPE_DICTIONARY \
		and data.get("type") == "building" \
		and data.get("scene") is PackedScene

	if ok:
		dragging_data = data.duplicate(true)

		# Ghost erstellen / ersetzen wenn anderes Gebäude
		var scene: PackedScene = dragging_data["scene"] as PackedScene

		if ghost_node == null or ghost_node.get_meta("scene_id") != scene.resource_path:
			if ghost_node != null:
				ghost_node.queue_free()

			ghost_node = scene.instantiate()
			ghost_node.set_meta("scene_id", scene.resource_path)
			houses_parent.add_child(ghost_node)
			ghost_node.z_as_relative = false
			ghost_node.z_index = 9999

		# gleiche Daten wie beim echten Haus anwenden
		if ghost_node.has_method("apply_data"):
			ghost_node.apply_data(dragging_data)
		elif ghost_node.has_node("Sprite2D") and dragging_data.has("world_texture"):
			var spr: Sprite2D = ghost_node.get_node("Sprite2D")
			spr.texture = dragging_data["world_texture"]

		_set_modulate_recursive(ghost_node, Color(1,1,1,0.55))
		ghost_node.visible = true

	return ok

func _drop_data(_pos, data):
	dragging_data.clear()
	if ghost_node != null:
		ghost_node.visible = false

	if typeof(data) != TYPE_DICTIONARY:
		return

	var payload: Dictionary = data.duplicate(true)  # <- COPY

	print("DROP keys:", payload.keys())

	if not payload.has("scene") or not (payload["scene"] is PackedScene):
		push_error("DROP: scene fehlt/ist falsch. Keys: " + str(payload.keys()))
		return

	dragging_data.clear()
	ghost_node.visible = false

	var tiles: Array[Vector2i] = _tiles_under_mouse(payload)


	if _is_blocked_tiles(tiles):
		print("BLOCKED -> no placement. tiles:", tiles)
		return

	_place_building(tiles, payload)  # <- payload verwenden!


# -----------------------
# Tile / Iso Helpers
# -----------------------

func _global_to_tile(global_pos: Vector2) -> Vector2i:
	var local_in_ground: Vector2 = ground.to_local(global_pos)
	return ground.local_to_map(local_in_ground)

func _tile_to_global(tile: Vector2i) -> Vector2:
	var local: Vector2 = ground.map_to_local(tile)
	return ground.to_global(local)

# -----------------------
# Footprint Helpers
# -----------------------

func _get_footprint_tiles(origin: Vector2i, footprint: Vector2i) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	for y in range(footprint.y):
		for x in range(footprint.x):
			tiles.append(origin + Vector2i(x, y))
	return tiles

func _footprint_center_global(tiles: Array[Vector2i]) -> Vector2:
	var sum: Vector2 = Vector2.ZERO
	for t in tiles:
		sum += _tile_to_global(t)
	return sum / max(1, tiles.size())

func _is_blocked_tiles(tiles: Array[Vector2i]) -> bool:
	for t in tiles:
		if occupied.has(t):
			print("blockiert")
			return true
		if obstacle_spawner != null and obstacle_spawner.has_method("is_tile_blocked"):
			if obstacle_spawner.is_tile_blocked(t):
				return true
	return false

# -----------------------
# Placement
# -----------------------

func _place_building(tiles: Array[Vector2i], data: Dictionary):
	var scene: PackedScene = data["scene"] as PackedScene
	var inst: Node2D = scene.instantiate()

	inst.global_position = _footprint_center_global(tiles)
	inst.z_index = 100

	if inst.has_method("apply_data"):
		inst.apply_data(data)
	elif inst.has_node("Sprite2D") and data.has("world_texture"):
		var spr: Sprite2D = inst.get_node("Sprite2D")
		spr.texture = data["world_texture"]

	houses_parent.add_child(inst)

	for t in tiles:
		occupied[t] = inst
		_set_ground_occupied(t, true)

func _set_modulate_recursive(node: Node, col: Color) -> void:
	if node is CanvasItem:
		(node as CanvasItem).modulate = col
	for c in node.get_children():
		_set_modulate_recursive(c, col)

func _origin_from_mouse_center(mouse_tile: Vector2i, footprint: Vector2i) -> Vector2i:
	# verschiebt origin so, dass footprint um die Maus zentriert wirkt
	var ox := mouse_tile.x - int((footprint.x - 1) / 2)
	var oy := mouse_tile.y - int((footprint.y - 1) / 2)
	return Vector2i(ox, oy)
	
func _tiles_under_mouse(data: Dictionary) -> Array[Vector2i]:
	var global_pos: Vector2 = get_global_mouse_position()
	var mouse_tile: Vector2i = _global_to_tile(global_pos)

	var fp: Vector2i = data.get("footprint", Vector2i.ONE)
	var origin_tile: Vector2i = _origin_from_mouse_center(mouse_tile, fp)

	return _get_footprint_tiles(origin_tile, fp)

func _save_ground_if_needed(tile: Vector2i) -> void:
	if original_ground.has(tile):
		return

	# TileMapLayer / TileMap: Infos lesen
	var src: int = ground.get_cell_source_id(tile)
	var atlas: Vector2i = ground.get_cell_atlas_coords(tile)
	var alt: int = 0
	if ground.has_method("get_cell_alternative_tile"):
		alt = ground.get_cell_alternative_tile(tile)

	original_ground[tile] = {"source": src, "atlas": atlas, "alt": alt}


func _set_ground_occupied(tile: Vector2i, on: bool) -> void:
	if on:
		_save_ground_if_needed(tile)
		# Boden ersetzen
		ground.set_cell(tile, occupied_source_id, occupied_atlas_coord, occupied_alt)
	else:
		# Boden zurücksetzen
		if not original_ground.has(tile):
			return
		var info: Dictionary = original_ground[tile]
		ground.set_cell(tile, int(info["source"]), info["atlas"], int(info["alt"]))
		original_ground.erase(tile)
