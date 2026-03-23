extends Control

@onready var progress_bar = $PanelContainer/TextureProgressBar
@onready var label_day1 = $PanelContainer/Label
@onready var label_day2 = $PanelContainer/Label2

var animation_duration = 10.0  # 5 Sekunden für langsameren, sanfteren Übergang
var elapsed = 0.0
var is_animating = false
var test_timer: Timer

func _ready():
	print("DayTransitionOverlay: _ready() aufgerufen")
	
	# UI initialisieren mit "Tag" statt "TAG"
	label_day1.text = "Tag 1"
	label_day2.text = "Tag 2"
	
	# Start-Zustand:
	# Tag 1: voll sichtbar
	# Tag 2: unsichtbar
	label_day1.modulate = Color(1, 1, 1, 1)  # Alpha = 1 (voll sichtbar)
	label_day2.modulate = Color(1, 1, 1, 0)  # Alpha = 0 (unsichtbar)
	
	# Fortschrittsbalken zurücksetzen
	progress_bar.value = 0
	
	# Overlay erstmal verstecken
	hide()
	
	# Timer starten
	start_test_timer()
	
	print("DayTransitionOverlay: Initialisierung abgeschlossen")

func start_test_timer():
	print("Starte Test-Timer für ", animation_duration, " Sekunden...")
	
	# Vorhandenen Timer löschen
	if test_timer:
		test_timer.queue_free()
	
	# Neuen Timer erstellen
	test_timer = Timer.new()
	test_timer.wait_time = animation_duration
	test_timer.one_shot = true
	test_timer.timeout.connect(_on_test_timeout)
	add_child(test_timer)
	test_timer.start()
	
	print("Timer gestartet, wartet ", animation_duration, " Sekunden...")

func _on_test_timeout():
	print("TIMER ABGELAUFEN! Starte Transition...")
	start_transition()

func start_transition():
	print("start_transition() wird ausgeführt")
	
	# Overlay anzeigen
	show()
	print("Overlay angezeigt")
	
	# Werte zurücksetzen
	is_animating = true
	elapsed = 0.0
	progress_bar.value = 0.0
	
	# Startwerte für die Überblendung
	label_day1.modulate.a = 1.0  # Tag 1 startet voll sichtbar
	label_day2.modulate.a = 0.0  # Tag 2 startet unsichtbar
	
	print("Animation gestartet: Tag 1 Alpha = 1.0, Tag 2 Alpha = 0.0")

func _process(delta):
	if is_animating:
		elapsed += delta
		var progress = elapsed / animation_duration
		progress_bar.value = progress * 100.0
		
		# Mit Smooth-Step für weicheren Übergang
		var smooth_progress = smoothstep(0.0, 1.0, progress)
		
		# Tag 1 verblasst, Tag 2 erscheint
		label_day1.modulate.a = 1.0 - smooth_progress
		label_day2.modulate.a = smooth_progress
		
		# Fortschritt ausgeben (alle 10% bei langsamer Animation)
		if int(progress * 10) > int((elapsed - delta) / animation_duration * 10):
			print("Fortschritt: ", int(progress * 100), "% - Tag1: ", label_day1.modulate.a, " Tag2: ", label_day2.modulate.a)
		
		if elapsed >= animation_duration:
			print("Animation abgeschlossen!")
			is_animating = false
			
			# END-Zustand:
			# Tag 1: komplett weg (Alpha = 0)
			# Tag 2: voll sichtbar (Alpha = 1)
			label_day1.modulate.a = 0.0  # Tag 1 ist weg
			label_day2.modulate.a = 1.0  # Tag 2 voll da
			
			print("FERTIG - Tag 1 weg, Tag 2 sichtbar")
			_on_transition_finished()

func _on_transition_finished():
	print("Transition finished! Tag 1 ist verschwunden, Tag 2 ist da")
	print("Das Overlay bleibt sichtbar mit Tag 2")
	# Hier wird NICHT ausgeblendet - Tag 2 bleibt als Ergebnis sichtbar!
