extends Terrain

func _ready():
	super._ready()
	removal_time = 6.0
	drop_amount = 10
	drop_amount_max = 20
	resource_type = "stone"
