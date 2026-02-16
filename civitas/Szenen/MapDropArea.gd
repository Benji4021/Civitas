extends Control

@export var ground_tilemap_path: NodePath = NodePath("../TileMapLayer")
@export var houses_parent_path: NodePath = NodePath("../Houses")

# Tile ersetzen (Boden “occupied”)
@export var occupied_source_id: int = 0
@export var occupied_atlas_coord: Vector2i = Vector2i(5, 0)
@export var occupied_alt: int = 0

# Physics Layer/Mask:
# Setz Hindernisse (Bäume/Steine) und Häuser so, dass ihre Collisions auf diesen Masken gefunden werden.

@onready var ground: TileMapLayer = get_node_or_null(ground_tilemap_path)
@onready var houses_parent: Node2D = get_node_or_null(houses_parent_path)

# Belegte Tiles (nur für Tile-Textur / “belegt”-Markierung)
var occupied_tiles: Dictionary = {}        # Vector2i -> true
var original_ground: Dictionary = {}       # Vector2i -> {"source":int,"atlas":Vector2i,"alt":int}

# Ghost
var ghost: Node2D = null
var ghost_area: Area2D = null
var dragging_data: Dictionary = {}

func _ready() -> void:
	if ground == null:
		push_error("MapDropArea: ground_tilemap_path falsch (z.B. ../TileMapLayer)")
		return
	if houses_parent == null:
		push_error("MapDropArea: houses_parent_path falsch (z.B. ../Houses)")
		return

	# Wichtig, damit Control Drops zuverlässig bekommt:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _process(_delta: float) -> void:
	if ghost == null or dragging_data.is_empty() or ground == null:
		return

	var tiles := _tiles_under_mouse(dragging_data)
	var center := _footprint_center_global(tiles)
	ghost.global_position = center

	var blocked := _ghost_collides()
	_set_modulate_recursive(ghost, Color(1, 0.25, 0.25, 0.55) if blocked else Color(1, 1, 1, 0.55))
	ghost.visible = true

	# Drag abgebrochen -> Ghost weg
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_clear_drag()


func _can_drop_data(_pos: Vector2, data) -> bool:
	var ok: bool = typeof(data) == TYPE_DICTIONARY \
		and data.get("type") == "building" \
		and (data.get("scene") is PackedScene)

	if not ok:
		return false

	dragging_data = (data as Dictionary).duplicate(true)
	_ensure_ghost_for(dragging_data)
	return true


func _drop_data(_pos: Vector2, data) -> void:
	if ground == null or houses_parent == null:
		return
	if typeof(data) != TYPE_DICTIONARY:
		return

	var payload: Dictionary = (data as Dictionary).duplicate(true)

	var tiles := _tiles_under_mouse(payload)
	var center := _footprint_center_global(tiles)

	# Blockiert durch Collision?
	if _ghost_collides():
		print("LOCKED BY COLLISION -> no placement")
		return


	# Tiles markieren + Haus platzieren
	_place_building(tiles, payload)
	_clear_drag()


func _clear_drag() -> void:
	dragging_data.clear()
	if ghost != null:
		ghost.visible = false


# -------------------------
# Ghost
# -------------------------
func _ensure_ghost_for(data: Dictionary) -> void:
	var scene: PackedScene = data.get("scene") as PackedScene
	if scene == null:
		return

	var scene_id := scene.resource_path
	if ghost != null and ghost.get_meta("scene_id", "") == scene_id:
		_apply_visuals_to_instance(ghost, data)
		ghost.visible = true
		return

	if ghost != null:
		ghost.queue_free()
		ghost = null
		ghost_area = null

	ghost = scene.instantiate() as Node2D
	if ghost == null:
		return

	ghost.set_meta("scene_id", scene_id)
	houses_parent.add_child(ghost) # <- zuerst in den Tree!

	ghost.z_as_relative = false
	ghost.z_index = 9999
	ghost.visible = true

	# JETZT PlacementArea holen (wie in deinem NodeTree!)
	ghost_area = ghost.get_node_or_null("PlacementArea") as Area2D
	if ghost_area == null:
		push_error("House Szene braucht PlacementArea (Area2D) als Child von TestHouse!")
		return

	ghost_area.monitoring = true
	ghost_area.monitorable = true

	_apply_visuals_to_instance(ghost, data)
	_set_modulate_recursive(ghost, Color(1, 1, 1, 0.55))


func _ghost_collides() -> bool:
	if ghost_area == null:
		return true

	var areas := ghost_area.get_overlapping_areas()
	var bodies := ghost_area.get_overlapping_bodies()

	# Debug (einmal kurz anschauen):
	# print("areas:", areas.size(), "bodies:", bodies.size())

	return areas.size() > 0 or bodies.size() > 0



func _apply_visuals_to_instance(inst: Node2D, data: Dictionary) -> void:
	# Optional: apply_data im Building script (Scale/Offset/Texture etc.)
	if inst.has_method("apply_data"):
		inst.call("apply_data", data)
		return

	# Fallback: Sprite2D Texture setzen
	if inst.has_node("Sprite2D") and data.has("world_texture"):
		var spr := inst.get_node("Sprite2D")
		if spr is Sprite2D:
			(spr as Sprite2D).texture = data["world_texture"]


func _set_modulate_recursive(node: Node, col: Color) -> void:
	if node is CanvasItem:
		(node as CanvasItem).modulate = col
	for c in node.get_children():
		_set_modulate_recursive(c, col)


# -------------------------
# Iso Tile helpers
# -------------------------
func _global_to_tile(global_pos: Vector2) -> Vector2i:
	var local_in_ground: Vector2 = ground.to_local(global_pos)
	return ground.local_to_map(local_in_ground)

func _tile_to_global(tile: Vector2i) -> Vector2:
	var local: Vector2 = ground.map_to_local(tile)
	return ground.to_global(local)

func _footprint_center_global(tiles: Array[Vector2i]) -> Vector2:
	var sum := Vector2.ZERO
	for t in tiles:
		sum += _tile_to_global(t)
	return sum / max(1, tiles.size())


# -------------------------
# Footprint (mehrere Tiles)
# -------------------------
func _origin_from_mouse_center(mouse_tile: Vector2i, footprint: Vector2i) -> Vector2i:
	# Zentriert Footprint auf Maus (für 2x2 / 1x2 etc.)
	var ox := mouse_tile.x - int((footprint.x - 1) / 2)
	var oy := mouse_tile.y - int((footprint.y - 1) / 2)
	return Vector2i(ox, oy)

func _get_footprint_tiles(origin: Vector2i, footprint: Vector2i) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	for y in range(footprint.y):
		for x in range(footprint.x):
			tiles.append(origin + Vector2i(x, y))
	return tiles

func _tiles_under_mouse(data: Dictionary) -> Array[Vector2i]:
	var mouse_tile := _global_to_tile(get_global_mouse_position())
	var fp: Vector2i = data.get("footprint", Vector2i.ONE)
	var origin := _origin_from_mouse_center(mouse_tile, fp)
	return _get_footprint_tiles(origin, fp)


# -------------------------
# Placement + Tile “occupied”
# -------------------------
func _place_building(tiles: Array[Vector2i], data: Dictionary) -> void:
	var scene: PackedScene = data.get("scene") as PackedScene
	if scene == null:
		push_error("place_building: scene ist null. Keys: " + str(data.keys()))
		return

	var inst := scene.instantiate() as Node2D
	if inst == null:
		return

	inst.global_position = _footprint_center_global(tiles)
	inst.z_index = 100

	_apply_visuals_to_instance(inst, data)
	houses_parent.add_child(inst)
	
	if inst.has_method("on_placed"):
		inst.call("on_placed")

	# Tiles belegen + Boden ersetzen
	for t in tiles:
		_set_ground_occupied(t, true)


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
		occupied_tiles[tile] = true
		_save_ground_if_needed(tile)
		ground.set_cell(tile, occupied_source_id, occupied_atlas_coord, occupied_alt)
	else:
		occupied_tiles.erase(tile)
		if not original_ground.has(tile):
			return
		var info: Dictionary = original_ground[tile]
		ground.set_cell(tile, int(info["source"]), info["atlas"], int(info["alt"]))
		original_ground.erase(tile)
