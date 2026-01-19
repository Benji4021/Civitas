extends Node

@export var ground_tilemap_path: NodePath
@export var obstacles_tilemap_path: NodePath
@export var houses_parent_path: NodePath

@onready var ground: TileMapLayer = get_node(ground_tilemap_path)
@onready var obstacles: Node2D = get_node(obstacles_tilemap_path)
@onready var houses_parent: Node2D = get_node(houses_parent_path)

# Merkt belegte Tiles: tile -> house node
var occupied: Dictionary = {}  # key: Vector2i, value: Node

func _unhandled_input(_event):
	# Damit Drop überall klappt: wenn Mouse Button released und Drag aktiv ist,
	# lässt Godot normalerweise _drop_data in Controls laufen.
	# Bei TileMaps nutzen wir stattdessen GUI-Drop über ein Control-Overlay ODER
	# wir machen Drop über Drag&Drop in einem Control (empfohlen).
	pass
