extends Node
class_name Building

enum BuildingType {
	ResidentialBuilding,
	Mine,
	Lumbermill,
	Windmill,
	Bank
}

var type: BuildingType

var cost_wood:   int = 0
var cost_stone:  int = 0
var cost_money:  int = 0
var capacity: int = 0

func _ready() -> void:
	SignalBus.placed_building.connect(_on_placed)

func _on_placed() -> void:
	if not Globals.can_afford(cost_wood, cost_stone, cost_money):
		var missing := Globals.missing(cost_wood, cost_stone, cost_money)
		var tmp := AcceptDialog.new()
		tmp.title = "Nicht genug Ressourcen"
		tmp.dialog_text = _build_missing_text(missing)
		get_tree().root.add_child(tmp)
		tmp.popup_centered()
		tmp.confirmed.connect(tmp.queue_free)
		# Gebäude wieder entfernen
		queue_free()
		return

	Globals.spend(cost_wood, cost_stone, cost_money)
	SignalBus.building_added.emit(self)

func _on_removed() -> void:
	SignalBus.building_removed.emit(self)

func _build_missing_text(missing: Dictionary) -> String:
	var parts: Array[String] = []
	if missing.has("money"): parts.append("💰 Geld:  %d" % missing["money"])
	if missing.has("wood"):  parts.append("🪵 Holz:  %d" % missing["wood"])
	if missing.has("stone"): parts.append("🪨 Stein: %d" % missing["stone"])
	return "Dir fehlen:\n\n" + "\n".join(parts)
