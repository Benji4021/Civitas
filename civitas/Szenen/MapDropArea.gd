extends Control

@export var ground_tilemap_path: NodePath = NodePath("../TileMapLayer")
@export var houses_parent_path: NodePath = NodePath("../Houses")

# Boden ersetzen
@export var occupied_source_id: int = 0
@export var occupied_atlas_coord: Vector2i = Vector2i(5, 0)
@export var occupied_alt: int = 0

# Collision Mask: Obstacles=Layer2, Buildings=Layer3
@export var placement_block_mask: int = (1 << 0) | (1 << 1)

@onready var ground: TileMapLayer = get_node_or_null(ground_tilemap_path)
@onready var houses_parent: Node2D = get_node_or_null(houses_parent_path)

var dragging_data: Dictionary = {}

# Ghost Instanz (vom gleichen PackedScene wie das Building)
var ghost: Node2D = null
var ghost_area: Area2D = null
var ghost_shape: Shape2D = null
var ghost_cs: CollisionShape2D = null
var ghost_scene_path: String = ""

# Tile-Status (nur für Textur)
var occupied_tiles: Dictionary = {}
var original_ground: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	if ground == null:
		push_error("MapDropArea: ground_tilemap_path falsch / TileMapLayer nicht gefunden.")
	if houses_parent == null:
		push_error("MapDropArea: houses_parent_path falsch / Houses nicht gefunden.")

func _process(_delta: float) -> void:
	if ground == null or houses_parent == null:
		return
	if ghost == null or dragging_data.is_empty():
		return

	# Ghost snappen
	var origin := _origin_under_mouse(dragging_data)
	ghost.global_position = _tile_to_global(origin)

	# Ghost Kollision -> rot/grün
	var blocked := _ghost_collides()
	_set_modulate_recursive(ghost, Color(1, 0.25, 0.25, 0.55) if blocked else Color(1, 1, 1, 0.55))

	# Drag abgebrochen
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_clear_drag()

# -------------------------
# Drag & Drop
# -------------------------
func _can_drop_data(_pos: Vector2, data) -> bool:
	var ok: bool = typeof(data) == TYPE_DICTIONARY \
		and data.get("type") == "building" \
		and (data.get("scene") is PackedScene)

	if not ok:
		return false

	dragging_data = (data as Dictionary).duplicate(true)
	_make_or_update_ghost(dragging_data)
	return true

func _drop_data(_pos: Vector2, data) -> void:
	if ghost == null:
		return
	if _ghost_collides():
		print("LOCKED BY COLLISION -> no placement")
		return

	var payload := (data as Dictionary).duplicate(true)

	var origin := _origin_under_mouse(payload)
	var tiles := _get_tiles(origin, payload)

	_place_building(origin, tiles, payload)
	_clear_drag()

func _clear_drag() -> void:
	dragging_data.clear()
	if ghost != null:
		ghost.visible = false

# -------------------------
# Ghost creation (ohne ensure_ghost_for name)
# -------------------------
func _make_or_update_ghost(data: Dictionary) -> void:
	var scene: PackedScene = data.get("scene")
	if scene == null:
		return

	var path := scene.resource_path
	var need_new := (ghost == null) or (ghost_scene_path != path)

	if need_new:
		if ghost != null:
			ghost.queue_free()

		ghost = scene.instantiate() as Node2D
		ghost_scene_path = path
		houses_parent.add_child(ghost)

		ghost.z_as_relative = false
		ghost.z_index = 200
		ghost.visible = true

		ghost_area = ghost.get_node_or_null("PlacementArea") as Area2D
		if ghost_area == null:
			push_error("Building Scene braucht PlacementArea (Area2D) als Child!")
			ghost.visible = false
			return

		ghost_cs = ghost_area.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if ghost_cs == null or ghost_cs.shape == null:
			push_error("PlacementArea braucht CollisionShape2D mit Shape!")
			ghost.visible = false
			return

		ghost_shape = ghost_cs.shape

		# Ghost soll alles blockierende sehen
		ghost_area.monitoring = true
		ghost_area.monitorable = true

	# Visuals anwenden (Texture etc.)
	_apply_visuals(ghost, data)
	ghost.visible = true # <-- WICHTIG
	_set_modulate_recursive(ghost, Color(1, 1, 1, 0.55))


# -------------------------
# Collision check (SOFORT korrekt)
# -------------------------
func _ghost_collides() -> bool:
	if ghost == null or ghost_area == null or ghost_cs == null or ghost_shape == null:
		return true

	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = ghost_shape
	params.transform = ghost_cs.global_transform
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = placement_block_mask

	# Ghost selbst ignorieren (Area RID reicht hier)
	params.exclude = [ghost_area.get_rid()]

	var hits: Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(params, 32)

	for hit: Dictionary in hits:
		var v = hit.get("collider") # Variant
		if v == null:
			continue

		# Collider kann Area2D oder PhysicsBody2D sein
		if v is CollisionObject2D:
			var co: CollisionObject2D = v as CollisionObject2D

			# 1) Gruppen am Collider selbst
			if co.is_in_group("obstacle") or co.is_in_group("building"):
				return true

			# 2) Gruppen am Parent (häufiger Fall!)
			var p := co.get_parent()
			if p != null and (p.is_in_group("obstacle") or p.is_in_group("building")):
				return true

			# 3) Optional: alles was auf blockierender Maske ist, blockt sowieso
			# (Wenn du Gruppen nicht 100% sauber pflegen willst, kannst du hier direkt true machen)
			return true

	return false


# -------------------------
# Placement
# -------------------------
func _place_building(origin: Vector2i, tiles: Array[Vector2i], data: Dictionary) -> void:
	var scene: PackedScene = data.get("scene")
	if scene == null:
		return

	var inst := scene.instantiate() as Node2D
	inst.global_position = _tile_to_global(origin)
	inst.z_index = 100
	houses_parent.add_child(inst)

	_apply_visuals(inst, data)

	# optional: nur beim echten Haus Event
	if inst.has_method("on_placed"):
		inst.call("on_placed")

	for t in tiles:
		_set_ground_occupied(t, true)

# -------------------------
# Iso Grid Helpers
# -------------------------
func _global_to_tile(pos: Vector2) -> Vector2i:
	if ground == null:
		return Vector2i.ZERO
	return ground.local_to_map(ground.to_local(pos))

func _tile_to_global(tile: Vector2i) -> Vector2:
	if ground == null:
		return Vector2.ZERO
	return ground.to_global(ground.map_to_local(tile))

func _origin_under_mouse(data: Dictionary) -> Vector2i:
	var mouse_tile := _global_to_tile(get_global_mouse_position())
	var fp: Vector2i = data.get("footprint", Vector2i.ONE)
	return Vector2i(
		mouse_tile.x - int((fp.x - 1) / 2),
		mouse_tile.y - int((fp.y - 1) / 2)
	)

func _get_tiles(origin: Vector2i, data: Dictionary) -> Array[Vector2i]:
	var fp: Vector2i = data.get("footprint", Vector2i.ONE)
	var arr: Array[Vector2i] = []
	for y in range(fp.y):
		for x in range(fp.x):
			arr.append(origin + Vector2i(x, y))
	return arr

# -------------------------
# Tile replace
# -------------------------
func _set_ground_occupied(tile: Vector2i, on: bool) -> void:
	if on:
		if not original_ground.has(tile):
			original_ground[tile] = {
				"source": ground.get_cell_source_id(tile),
				"atlas": ground.get_cell_atlas_coords(tile),
				"alt": ground.get_cell_alternative_tile(tile)
			}
		ground.set_cell(tile, occupied_source_id, occupied_atlas_coord, occupied_alt)
		occupied_tiles[tile] = true
	else:
		if not original_ground.has(tile):
			return
		var info = original_ground[tile]
		ground.set_cell(tile, info["source"], info["atlas"], info["alt"])
		original_ground.erase(tile)
		occupied_tiles.erase(tile)

# -------------------------
# Visual Helpers
# -------------------------
func _apply_visuals(inst: Node2D, data: Dictionary) -> void:
	if inst.has_method("apply_data"):
		inst.call("apply_data", data)
	elif inst.has_node("Sprite2D") and data.has("world_texture"):
		var spr := inst.get_node("Sprite2D")
		if spr is Sprite2D:
			(spr as Sprite2D).texture = data["world_texture"]

func _set_modulate_recursive(node: Node, col: Color) -> void:
	if node is CanvasItem:
		(node as CanvasItem).modulate = col
	for c in node.get_children():
		_set_modulate_recursive(c, col)
