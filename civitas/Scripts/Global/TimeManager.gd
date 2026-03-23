extends Node

var current_day : int = 1
var minutes_per_day : int = 1
var seconds_passed : float = 0.0

signal day_changed(new_day)

func _process(delta):
	seconds_passed += delta
	
	if seconds_passed >= minutes_per_day * 30:
		seconds_passed = 0
		current_day += 1
		emit_signal("day_changed", current_day)

func get_day_progress() -> float:
	return seconds_passed / (minutes_per_day * 60.0)
