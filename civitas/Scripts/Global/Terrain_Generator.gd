extends Node2D

@export var tree_scenes: Array[PackedScene] = []
@export var spawn_counts: Array[int] = [600, 550, 400, 450]

# Gesamtfläche wo gespawnt werden darf
@export var spawn_area_size := Vector2(800, 600)

# Bereich in der Mitte wo NICHT gespawnt wird (Startscreen)
@export var startscreen_size := Vector2(300, 200)


# Tiles die aktuell blockiert sind (optional für später)
var blocked_tiles: Dictionary = {}  # Vector2i -> true


func _ready():
	randomize()
	spawn_all_trees()


func set_blocked(tile: Vector2i, blocked: bool = true) -> void:
	if blocked:
		blocked_tiles[tile] = true
	else:
		blocked_tiles.erase(tile)


func is_tile_blocked(tile: Vector2i) -> bool:
	return blocked_tiles.has(tile)



func spawn_all_trees():
	print("=== GENERATOR START ===")
	print("Anzahl Baum-Typen: ", tree_scenes.size())

	# Prüfen ob Szenen zugewiesen
	for i in range(tree_scenes.size()):
		if tree_scenes[i]:
			print("✓ Typ ", i, ": ", tree_scenes[i].resource_path)
		else:
			print("✗ Typ ", i, ": NICHT ZUGEWIESEN!")

	if tree_scenes.is_empty() or tree_scenes[0] == null:
		print("FEHLER: Keine Baum-Szenen zugewiesen!")
		return

	print("Starte Spawning...")

	var total_spawned = 0


	# Für jeden Baum-Typ
	for type_index in range(tree_scenes.size()):
		var tree_scene = tree_scenes[type_index]
		if tree_scene == null:
			continue

		var count = spawn_counts[type_index] if type_index < spawn_counts.size() else spawn_counts[0]

		print("Spawning ", count, " von Typ ", type_index)

		for i in range(count):
			var tree = tree_scene.instantiate()

			var pos = get_valid_spawn_position()
			tree.position = pos

			add_child(tree)
			total_spawned += 1

	print("FERTIG! Gesamt: ", total_spawned, " Bäume gespawnt.")



# -------------------------------------------------
# 🔹 NEU: Position finden die NICHT im Startscreen liegt
# -------------------------------------------------
func get_valid_spawn_position() -> Vector2:
	var tries := 0
	var pos := Vector2.ZERO

	while tries < 50:
		pos = Vector2(
			randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
			randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
		)

		var inside_startscreen = \
			abs(pos.x) < startscreen_size.x / 2 and \
			abs(pos.y) < startscreen_size.y / 2

		if not inside_startscreen:
			return pos

		tries += 1

	# Fallback (Compiler braucht das)
	return pos
