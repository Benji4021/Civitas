extends Node2D

@export var tree_scenes: Array[PackedScene] = []
@export var spawn_counts: Array[int] = [600, 600, 400, 450]

# Gesamtfläche wo gespawnt werden darf
@export var spawn_area_size := Vector2(800, 590)

# Bereich in der Mitte wo NICHT gespawnt wird (Startscreen)
@export var startscreen_size := Vector2(300, 200)

# Spawn-Einstellungen für Animation
@export var spawn_duration: float = 3.0  # Wie lange der gesamte Spawn-Vorgang dauert
@export var max_spawns_per_frame: int = 5  # Max. Bäume pro Frame für Performance
@export var spawn_delay_per_row: float = 0.01  # Verzögerung zwischen Y-Reihen

# Tiles die aktuell blockiert sind
var blocked_tiles: Dictionary = {}
var total_trees_to_spawn := 0
var trees_spawned := 0


func _ready():
	randomize()
	# Starte animiertes Spawning
	call_deferred("start_animated_spawn")


func start_animated_spawn():
	print("=== GENERATOR START (ANIMATED) ===")
	
	# Berechne Gesamtanzahl
	total_trees_to_spawn = 0
	for i in range(min(tree_scenes.size(), spawn_counts.size())):
		if tree_scenes[i]:
			total_trees_to_spawn += spawn_counts[i]
	
	print("Gesamt Bäume: ", total_trees_to_spawn)
	
	# Starte Coroutine für animiertes Spawning
	spawn_trees_animated()


func spawn_trees_animated():
	# Erstelle temporäre Liste aller zu spawnenden Bäume
	var spawn_queue = []
	
	# Für jeden Baum-Typ
	for type_index in range(tree_scenes.size()):
		var tree_scene = tree_scenes[type_index]
		if tree_scene == null:
			continue
		
		var count = spawn_counts[type_index] if type_index < spawn_counts.size() else spawn_counts[0]
		
		for i in range(count):
			# Berechne Zielposition (jetzt aber mit Y-Priorisierung)
			var y_pos = randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
			var x_pos = randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2)
			
			# Prüfe Startscreen
			var inside_startscreen = \
				abs(x_pos) < startscreen_size.x / 2 and \
				abs(y_pos) < startscreen_size.y / 2
				
			if not inside_startscreen:
				# Füge mit Y-Position als Priorität hinzu (niedrigere Y zuerst)
				spawn_queue.append({
					"type_index": type_index,
					"position": Vector2(x_pos, y_pos),
					"y_value": y_pos
				})
	
	# Sortiere nach Y-Position (von oben nach unten)
	spawn_queue.sort_custom(func(a, b): return a.y_value < b.y_value)
	
	print("Starte animiertes Spawning von ", spawn_queue.size(), " Bäumen...")
	
	# Starte animierten Spawn-Prozess
	await spawn_with_animation(spawn_queue)


func spawn_with_animation(spawn_queue: Array):
	var start_time = Time.get_ticks_msec()
	var trees_this_frame = 0
	
	# Berechne Zeit zwischen Spawns basierend auf Dauer und Anzahl
	var total_spawn_time = spawn_duration * 1000  # in ms
	var time_per_tree = total_spawn_time / max(1, spawn_queue.size())
	
	# Alternative: Progressives Spawning (am Anfang schneller, am Ende langsamer)
	var next_spawn_time = 0.0
	var current_y_group = null
	var y_group_delay = 0.0
	
	for tree_data in spawn_queue:
		var current_time = Time.get_ticks_msec() - start_time
		
		# Gruppiere nach Y-Position für Welleneffekt
		var y_group = int(tree_data.y_value / 10.0)  # Gruppiere in 10er Schritten
		
		if current_y_group != y_group:
			current_y_group = y_group
			y_group_delay += spawn_delay_per_row
			# Kleine Pause zwischen Y-Gruppen für Welleneffekt
			if y_group_delay > 0:
				await get_tree().create_timer(y_group_delay * 0.5).timeout
		
		# Warte, wenn wir zu viele Bäume in diesem Frame spawnen
		trees_this_frame += 1
		if trees_this_frame >= max_spawns_per_frame:
			trees_this_frame = 0
			await get_tree().process_frame
		
		# Spawn den Baum
		spawn_single_tree(tree_data.type_index, tree_data.position)
		
		# Kleine Verzögerung für animierten Effekt
		var delay = time_per_tree / 1000.0  # in Sekunden
		if delay > 0:
			await get_tree().create_timer(delay * randf_range(0.5, 1.5)).timeout
	
	print("FERTIG! ", trees_spawned, " Bäume gespawnt.")


func spawn_single_tree(type_index: int, position: Vector2):
	var tree_scene = tree_scenes[type_index]
	if tree_scene == null:
		return
	
	var tree = tree_scene.instantiate()
	tree.position = position
	
	# Optional: Starte mit Skalierung 0 für Fade-in Effekt
	tree.scale = Vector2.ZERO
	add_child(tree)
	
	# Animation für schöneren Effekt
	var tween = create_tween()
	tween.tween_property(tree, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	trees_spawned += 1
	
	# Fortschritt anzeigen
	if trees_spawned % 100 == 0:
		print("Fortschritt: ", trees_spawned, "/", total_trees_to_spawn)


# Alternative: Spawn mit sichtbarem "Scan-Line" Effekt
func spawn_with_scanline_effect():
	print("Starte Scan-Line Spawning...")
	
	# Teile den Bereich in horizontale Streifen auf
	var strip_height = 20.0  # Höhe jedes Streifens
	var start_y = -spawn_area_size.y / 2
	var end_y = spawn_area_size.y / 2
	
	# Gehe von oben nach unten
	var current_y = start_y
	
	while current_y < end_y:
		# Spawne alle Bäume für diesen Streifen
		spawn_in_strip(current_y, current_y + strip_height)
		
		# Warte für Scan-Line Effekt
		await get_tree().create_timer(0.05).timeout
		current_y += strip_height


func spawn_in_strip(min_y: float, max_y: float):
	# Für jeden Baum-Typ
	for type_index in range(tree_scenes.size()):
		var tree_scene = tree_scenes[type_index]
		if tree_scene == null:
			continue
		
		var count_for_strip = int(spawn_counts[type_index] * (max_y - min_y) / spawn_area_size.y)
		
		for i in range(count_for_strip):
			var pos = Vector2(
				randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
				randf_range(min_y, max_y)
			)
			
			var inside_startscreen = \
				abs(pos.x) < startscreen_size.x / 2 and \
				abs(pos.y) < startscreen_size.y / 2
			
			if not inside_startscreen:
				var tree = tree_scene.instantiate()
				tree.position = pos
				tree.scale = Vector2.ZERO
				add_child(tree)
				
				# Zufällige leichte Verzögerung für natürlicheren Look
				var delay = randf_range(0.0, 0.1)
				var tween = create_tween()
				tween.set_delay(delay)
				tween.tween_property(tree, "scale", Vector2.ONE, 0.2)\
					.set_trans(Tween.TRANS_QUAD)\
					.set_ease(Tween.EASE_OUT)


func set_blocked(tile: Vector2i, blocked: bool = true) -> void:
	if blocked:
		blocked_tiles[tile] = true
	else:
		blocked_tiles.erase(tile)


func is_tile_blocked(tile: Vector2i) -> bool:
	return blocked_tiles.has(tile)


# Backup: Originale nicht-animierte Version (deaktiviert)
func spawn_all_trees():
	print("Diese Funktion ist deaktiviert. Verwende animiertes Spawning.")
