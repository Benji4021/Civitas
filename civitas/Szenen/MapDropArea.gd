extends Control

@export var ground_tilemap_path: NodePath = NodePath("../TileMapLayer")
@export var houses_parent_path: NodePath = NodePath("../Houses")
<<<<<<< Updated upstream
@export var obstacle_spawner_path: NodePath = NodePath("../ObstacleSpawner")
=======

# Boden-Tile ersetzen (belegt)
@export var occupied_source_id: int = 0
@export var occupied_atlas_coord: Vector2i = Vector2i(5, 0)
@export var occupied_alt: int = 0
>>>>>>> Stashed changes

@onready var ground = get_node_or_null(ground_tilemap_path)
@onready var houses_parent: Node2D = get_node_or_null(houses_parent_path)

<<<<<<< Updated upstream
# Belegung: jedes Tile -> Hausnode
var occupied: Dictionary = {} # Vector2i -> Node2D
=======
# Original-Boden speichern, damit man später zurücksetzen könnte
var original_ground: Dictionary = {} # Vector2i -> {"source":int, "atlas":Vector2i, "alt":int}
>>>>>>> Stashed changes

# Drag state
var dragging_data: Dictionary = {}
var ghost_node: Node2D = null
var ghost_area: Area2D = null

func _ready() -> void:
	if ground == null:
		push_error("MapDropArea: ground_tilemap_path falsch (z.B. ../TileMapLayer)")
		set_process(false)
		return
	if houses_parent == null:
		push_error("MapDropArea: houses_parent_path falsch (z.B. ../Houses)")
		set_process(false)
		return

func _process(_delta: float) -> void:
	if ghost_node == null or dragging_data.is_empty():
		return

	var tiles := _tiles_under_mouse(dragging_data)
	ghost_node.global_position = _footprint_center_global(tiles)

	var blocked := _ghost_collides()
	_set_modulate_recursive(ghost_node, Color(1, 0.25, 0.25, 0.55) if blocked else Color(1, 1, 1, 0.55))
	ghost_node.visible = true

func _can_drop_data(_pos, data) -> bool:
	var ok: bool = typeof(data) == TYPE_DICTIONARY \
		and data.get("type") == "building" \
		and data.get("scene") is PackedScene

	if not ok:
		return false

	dragging_data = data.duplicate(true)
	_ensure_ghost_for_scene(dragging_data)
	return true

func _drop_data(_pos, data) -> void:
	if ghost_node == null:
		return

	var payload: Dictionary = data.duplicate(true)
	dragging_data.clear()

	var tiles := _tiles_under_mouse(payload)
	ghost_node.global_position = _footprint_center_global(tiles)

	if _ghost_collides():
		print("LOCKED BY COLLISION -> no placement")
		ghost_node.visible = false
		return

	_place_building(tiles, payload)
	ghost_node.visible = false

# -----------------------
# Ghost setup
# -----------------------

func _ensure_ghost_for_scene(data: Dictionary) -> void:
	var scene: PackedScene = data["scene"]

	# Ghost neu, wenn anderer Gebäudetyp
	if ghost_node != null and ghost_node.get_meta("scene_id") == scene.resource_path:
		return

	if ghost_node != null:
		ghost_node.queue_free()
		ghost_node = null
		ghost_area = null

	ghost_node = scene.instantiate()
	ghost_node.set_meta("scene_id", scene.resource_path)
	houses_parent.add_child(ghost_node)
	ghost_node.z_as_relative = false
	ghost_node.z_index = 9999
	ghost_node.visible = true

	# Texture setzen falls die Szene keinen eigenen Sprite hat
	if ghost_node.has_method("apply_data"):
		ghost_node.apply_data(data)
	elif ghost_node.has_node("Sprite2D") and data.has("world_texture"):
		var spr: Sprite2D = ghost_node.get_node("Sprite2D")
		spr.texture = data["world_texture"]

	# PlacementArea finden
	ghost_area = ghost_node.get_node_or_null("PlacementArea")
	if ghost_area == null:
		push_error("Building Scene hat keine PlacementArea (Area2D). Bitte in House.tscn hinzufügen!")
		# Damit du trotzdem nicht dauernd crasht:
		ghost_node.visible = false

func _ghost_collides() -> bool:
	if ghost_area == null:
		return true  # ohne PlacementArea lieber blocken als falsch platzieren

	var areas := ghost_area.get_overlapping_areas()
	var bodies := ghost_area.get_overlapping_bodies()
	return (areas.size() > 0) or (bodies.size() > 0)

# -----------------------
# Tile helpers (Iso)
# -----------------------

func _global_to_tile(global_pos: Vector2) -> Vector2i:
	var local_in_ground: Vector2 = ground.to_local(global_pos)
	return ground.local_to_map(local_in_ground)

func _origin_from_mouse_center(mouse_tile: Vector2i, footprint: Vector2i) -> Vector2i:
	return Vector2i(
		mouse_tile.x - int((footprint.x - 1) / 2),
		mouse_tile.y - int((footprint.y - 1) / 2)
	)

func _get_footprint_tiles(origin: Vector2i, footprint: Vector2i) -> Array[Vector2i]:
	var res: Array[Vector2i] = []
	for y in range(footprint.y):
		for x in range(footprint.x):
			res.append(origin + Vector2i(x, y))
	return res

func _tiles_under_mouse(data: Dictionary) -> Array[Vector2i]:
	var mouse_tile := _global_to_tile(get_global_mouse_position())
	var fp: Vector2i = data.get("footprint", Vector2i.ONE)
	var origin := _origin_from_mouse_center(mouse_tile, fp)
	return _get_footprint_tiles(origin, fp)

func _tile_to_global(tile: Vector2i) -> Vector2:
	var local: Vector2 = ground.map_to_local(tile)
	return ground.to_global(local)

func _footprint_center_global(tiles: Array[Vector2i]) -> Vector2:
	var sum := Vector2.ZERO
	for t in tiles:
		sum += _tile_to_global(t)
	return sum / max(1, tiles.size())

# -----------------------
# Placement + Boden ersetzen
# -----------------------

func _place_building(tiles: Array[Vector2i], data: Dictionary) -> void:
	var scene: PackedScene = data["scene"]
	var inst: Node2D = scene.instantiate()

	inst.global_position = _footprint_center_global(tiles)
	inst.z_as_relative = false
	inst.z_index = 100

	if inst.has_method("apply_data"):
		inst.apply_data(data)
	elif inst.has_node("Sprite2D") and data.has("world_texture"):
		var spr: Sprite2D = inst.get_node("Sprite2D")
		spr.texture = data["world_texture"]

	houses_parent.add_child(inst)

	# Boden-Tiles optisch ersetzen
	for t in tiles:
<<<<<<< Updated upstream
		occupied[t] = inst
=======
		_set_ground_occupied(t, true)
>>>>>>> Stashed changes

func _save_ground_if_needed(tile: Vector2i) -> void:
	if original_ground.has(tile):
		return
	var src: int = ground.get_cell_source_id(tile)
	var atlas: Vector2i = ground.get_cell_atlas_coords(tile)
	var alt: int = 0
	if ground.has_method("get_cell_alternative_tile"):
		alt = ground.get_cell_alternative_tile(tile)
	original_ground[tile] = {"source": src, "atlas": atlas, "alt": alt}

func _set_ground_occupied(tile: Vector2i, on: bool) -> void:
	if on:
		_save_ground_if_needed(tile)
		ground.set_cell(tile, occupied_source_id, occupied_atlas_coord, occupied_alt)
	else:
		if not original_ground.has(tile):
			return
		var info: Dictionary = original_ground[tile]
		ground.set_cell(tile, int(info["source"]), info["atlas"], int(info["alt"]))
		original_ground.erase(tile)

func _set_modulate_recursive(node: Node, col: Color) -> void:
	if node is CanvasItem:
		(node as CanvasItem).modulate = col
	for c in node.get_children():
		_set_modulate_recursive(c, col)
