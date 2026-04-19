extends CanvasLayer

var dialog: AcceptDialog

func _ready() -> void:
	SignalBus.missing_resources_requested.connect(_on_missing_resources_requested)
	dialog = AcceptDialog.new()
	dialog.title = "Nicht genug Ressourcen"
	dialog.dialog_autowrap = true
	add_child(dialog)

func _on_missing_resources_requested(missing: Dictionary) -> void:
	if dialog == null:
		return
	dialog.dialog_text = build_missing_text(missing)
	dialog.popup_centered()

func build_missing_text(missing: Dictionary) -> String:
	var parts: Array[String] = []

	if missing.has("money"):
		parts.append("💰 Gold: %d" % int(missing["money"]))
	if missing.has("wood"):
		parts.append("🪵 Holz: %d" % int(missing["wood"]))
	if missing.has("stone"):
		parts.append("🪨 Stein: %d" % int(missing["stone"]))

	return "Dir fehlen:

" + "
".join(parts)
