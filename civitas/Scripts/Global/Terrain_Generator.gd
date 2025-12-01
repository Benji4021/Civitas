extends Node2D

@export var tree_scene: PackedScene
@export var amount := 20
@export var min_time := 1.0
@export var max_time := 5.0

func _ready():
	randomize()
	generate_trees()

func generate_trees():
	for i in range(amount):
		var tree = tree_scene.instantiate()

		# zufällige Position (Beispiel)
		tree.position = Vector2(
			randf_range(-300, 300),
			randf_range(-300, 300)
		)

		# zufällige Abbauzeit vergeben
		tree.removal_time = randf_range(min_time, max_time)

		add_child(tree)
