extends CanvasLayer

func _ready() -> void:
	SignalBus.missing_resources_requested.connect(_on_missing_resources_requested)

func _on_missing_resources_requested(missing: Dictionary) -> void:
	var dlg := AcceptDialog.new()
	dlg.title = "Nicht genug Ressourcen"
	dlg.dialog_text = _build_missing_text(missing)
	add_child(dlg)
	dlg.popup_centered()
	dlg.confirmed.connect(dlg.queue_free)
	dlg.canceled.connect(dlg.queue_free)
	if dlg.has_signal("close_requested"):
		dlg.close_requested.connect(dlg.queue_free)

func _build_missing_text(missing: Dictionary) -> String:
	var parts: Array[String] = []
	if missing.has("money"):
		parts.append("💰 Geld: %d" % int(missing["money"]))
	if missing.has("wood"):
		parts.append("🪵 Holz: %d" % int(missing["wood"]))
	if missing.has("stone"):
		parts.append("🪨 Stein: %d" % int(missing["stone"]))

	return "Dir fehlen:

" + "
".join(parts)
