extends Node

var current_day: int = 1
var minutes_per_day: int = 5
var seconds_passed: float = 0.0
var is_paused := false

var wood_to_stone = Vector2i(1, 1)
var stone_to_wood = Vector2i(1, 1)

var crates = {}

signal day_changed(new_day)
signal new_customers_generated(day)
signal crate_updated(crate_id)

var customer_times_sec = [70, 150, 260]
var customers_today = []

func _ready():
	randomize()

	for i in range(6):
		crates[i] = {
			"type": "",
			"amount": 0
		}

	generate_customers()


func _process(delta):
	if is_paused:
		return

	seconds_passed += delta

	# ✅ DAY CHANGE
	if seconds_passed >= minutes_per_day * 60:
		is_paused = true

		var old_day = current_day
		current_day += 1

		emit_signal("day_changed", current_day)
		get_tree().call_group("day_transition", "start_transition", old_day, current_day)

		print("=== DAY TRANSITION START ===")

	# ✅ CUSTOMER SYSTEM (runs EVERY FRAME)
	for c in customers_today:
		if not c["spawned"] and seconds_passed >= c["time"]:
			c["spawned"] = true
			spawn_customer()


func resume_after_transition():
	print("=== TRANSITION DONE → NEW DAY START ===")

	seconds_passed = 0

	generate_new_trades()
	generate_customers()

	is_paused = false



func get_day_progress() -> float:
	return seconds_passed / (minutes_per_day * 60.0)

func generate_new_trades():
	wood_to_stone = Vector2i(
		randi_range(1, 5),
		randi_range(1, 5)
	)

	stone_to_wood = Vector2i(
		randi_range(1, 5),
		randi_range(1, 5)
	)

func generate_customers():
	customers_today.clear()

	for t in customer_times_sec:
		customers_today.append({
			"time": t,
			"spawned": false
		})

	new_customers_generated.emit(current_day)

func spawn_customer():
	var available = []

	for id in Globals.crate_storage.keys():
		var c = Globals.crate_storage[id]
		if c.get("state", "") == "listed":
			available.append(id)

	if available.is_empty():
		print("[CUSTOMER] arrived but nothing available")
		return

	var roll = randf()
	var crates_to_buy = 0

	if roll > 0.3:
		crates_to_buy = 1
	if roll > 0.85:
		crates_to_buy = 2

	crates_to_buy = min(crates_to_buy, available.size())

	if crates_to_buy <= 0:
		print("[CUSTOMER] arrived but bought nothing")
		return

	print("[CUSTOMER] wants to buy", crates_to_buy, "crates")

	for i in range(crates_to_buy):
		if available.is_empty():
			break

		var crate_id = available.pick_random()
		available.erase(crate_id)

		var crate = Globals.crate_storage[crate_id]

		var amount = crate.get("amount", 0)
		var price_per_unit = 5
		var money_earned = amount * price_per_unit

		crate["pending_money"] += money_earned
		crate["state"] = "sold"

		Globals.crate_storage[crate_id] = crate

		print("[CUSTOMER] bought FULL crate",
			crate_id,
			"| amount:", amount,
			"| earned:", money_earned
		)
		
		emit_signal("crate_updated", crate_id)
