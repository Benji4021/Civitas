extends Terrain

func _ready():
	super._ready()
	removal_time = 4.0
	drop_amount_min = 10
	drop_amount_max = 20
	resource_type = "lumber"
