extends Control

signal transition_finished

@onready var progress_bar = $PanelContainer/TextureProgressBar
@onready var label_day1 = $PanelContainer/Label
@onready var label_day2 = $PanelContainer/Label2

var animation_duration = 8.0
var elapsed = 0.0
var is_animating = false

func _ready():
	hide()
	print("DayTransitionOverlay: _ready() aufgerufen")

	label_day1.text = "Tag 1"
	label_day2.text = "Tag 2"

	label_day1.modulate = Color(1, 1, 1, 1)
	label_day2.modulate = Color(1, 1, 1, 0)

	progress_bar.value = 0

	print("DayTransitionOverlay: Initialisierung abgeschlossen")

func start_transition(old_day: int, new_day: int):
	print("start_transition() wird ausgeführt")

	label_day1.text = "Tag " + str(old_day)
	label_day2.text = "Tag " + str(new_day)

	show()
	print("Overlay angezeigt")

	is_animating = true
	elapsed = 0.0
	progress_bar.value = 0.0

	label_day1.modulate.a = 1.0
	label_day2.modulate.a = 0.0

	print("Animation gestartet: Tag 1 Alpha = 1.0, Tag 2 Alpha = 0.0")

func _process(delta):
	if is_animating:
		elapsed += delta
		var progress = elapsed / animation_duration
		progress_bar.value = progress * 100.0

		var smooth_progress = smoothstep(0.0, 1.0, progress)

		label_day1.modulate.a = 1.0 - smooth_progress
		label_day2.modulate.a = smooth_progress

		if elapsed >= animation_duration:
			print("Animation abgeschlossen!")
			is_animating = false

			label_day1.modulate.a = 0.0
			label_day2.modulate.a = 1.0

			_on_transition_finished()

func _on_transition_finished():
	print("Transition finished! Tag 1 ist verschwunden, Tag 2 ist da")
	emit_signal("transition_finished")
