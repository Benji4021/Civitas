extends Terrain

func _ready():
	super._ready()
	removal_time = 2.0
	drop_amount_min = 5
	drop_amount_max = 10
	resource_type = "lumber"
