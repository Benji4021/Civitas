extends Node

var current_day: int = 1
var minutes_per_day: int = 1
var seconds_passed: float = 0.0

var wood_to_stone = Vector2i(1, 1)
var stone_to_wood = Vector2i(1, 1)

var crates = {}

signal day_changed(new_day)
signal new_customers_generated(day)

var customer_times_sec = [10, 20, 30]
var customers_today = []

func _ready():
	randomize()

	for i in range(6):
		crates[i] = {
			"type": "",
			"amount": 0
		}

	generate_customers() # ✅ IMPORTANT FIX

func _process(delta):
	seconds_passed += delta

	# DAY CHANGE
	if seconds_passed >= minutes_per_day * 30:
		seconds_passed = 0
		current_day += 1

		generate_new_trades()
		generate_customers()

		emit_signal("day_changed", current_day)
		print("=== NEW DAY:", current_day, "===")

	# CUSTOMER SYSTEM
	for c in customers_today:
		if not c["spawned"] and seconds_passed >= c["time"]:
			c["spawned"] = true
			spawn_customer()

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

# -----------------------------
# CUSTOMER SYSTEM
# -----------------------------

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

	var crate_id = available.pick_random()
	var crate = Globals.crate_storage[crate_id]

	# BUY LOGIC
	var roll = randf()

	var buy_amount = 0
	if roll > 0.3:
		buy_amount = 1
	if roll > 0.85:
		buy_amount = 2

	buy_amount = min(buy_amount, crate.get("amount", 0))

	if buy_amount <= 0:
		print("[CUSTOMER] arrived but bought nothing")
		return

	# ECONOMY
	var price_per_unit = 5
	var money_earned = buy_amount * price_per_unit

	crate["amount"] -= buy_amount
	crate["pending_money"] += money_earned

	if crate["amount"] <= 0:
		crate["state"] = "sold"

	Globals.crate_storage[crate_id] = crate

	print("[CUSTOMER] bought",
		buy_amount,
		crate["resource"],
		"for", money_earned,
		"from crate", crate_id
	)
