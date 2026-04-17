extends Node

var current_day: int = 1
var minutes_per_day: int = 1
var seconds_passed: float = 0.0

var wood_to_stone = Vector2i(1, 1) # e.g. 1 wood = 3 stone
var stone_to_wood = Vector2i(1, 1)

signal day_changed(new_day)

func _process(delta):
	seconds_passed += delta

	if seconds_passed >= minutes_per_day * 30:
		seconds_passed = 0
		current_day += 1
		generate_new_trades()
		emit_signal("day_changed", current_day)
		print("New Day:", current_day)

func get_day_progress() -> float:
	return seconds_passed / (minutes_per_day * 60.0)
	
func generate_new_trades():
	wood_to_stone = Vector2i(
		randi_range(1, 5), # wood amount
		randi_range(1, 5)  # stone amount
	)
	stone_to_wood = Vector2i(
		randi_range(1, 5),
		randi_range(1, 5)
	)
