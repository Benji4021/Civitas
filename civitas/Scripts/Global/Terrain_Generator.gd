extends Node2D

@export var tree_scenes: Array[PackedScene] = []
@export var spawn_counts: Array[int] = [5, 5, 5, 5]
@export var spawn_area_size := Vector2(800, 600)

func _ready():
	randomize()
	spawn_all_trees()

func spawn_all_trees():
	# DEBUG: Zeige was zugewiesen wurde
	print("=== GENERATOR START ===")
	print("Anzahl Baum-Typen: ", tree_scenes.size())
	
	# Prüfe ob Szenen zugewiesen sind
	for i in range(tree_scenes.size()):
		if tree_scenes[i]:
			print("✓ Typ ", i, ": ", tree_scenes[i].resource_path)
		else:
			print("✗ Typ ", i, ": NICHT ZUGEWIESEN!")
	
	# Falls nichts zugewiesen ist, Fehler
	if tree_scenes.size() == 0 or tree_scenes[0] == null:
		print("FEHLER: Keine Baum-Szenen zugewiesen!")
		print("Bitte im Inspector die .tscn Dateien zuweisen!")
		return
	
	print("Starte Spawning...")
	
	var total_spawned = 0
	
	# Für jeden Baum-Typ
	for type_index in range(tree_scenes.size()):
		var tree_scene = tree_scenes[type_index]
		if tree_scene == null:
			continue
		
		# Anzahl für diesen Typ
		var count = spawn_counts[type_index] if type_index < spawn_counts.size() else spawn_counts[0]
		
		print("Spawning ", count, " von Typ ", type_index)
		
		# Bäume spawnen
		for i in range(count):
			var tree = tree_scene.instantiate()
			
			# Zufällige Position
			tree.position = Vector2(
				randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
				randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
			)
			
		
			# Dem Generator hinzufügen
			add_child(tree)
			total_spawned += 1
			
			print("  - Baum ", total_spawned, " bei: ", tree.position)
	
	print("FERTIG! Gesamt: ", total_spawned, " Bäume gespawnt.")
