extends Control
# ─────────────────────────────────────────────────────────────────────────────
# DialogueChoiceMinigame.gd – Modular Mini-Game Asset
# Choose wise responses to resolve conflicts.
# "A gentle answer turns away wrath" – Proverbs 15:1
# ─────────────────────────────────────────────────────────────────────────────

signal minigame_complete(result: Dictionary)
signal minigame_timeout(result: Dictionary)

@export var goal: int = 3
@export var prompt: String = "Choose wisely to bring peace!"

var _choices_made: int = 0
var _done: bool = false
var _scenarios: Array = [
	{
		"setup": "Traveler A: 'This well is mine!'\nTraveler B: 'No, the elders gave it to me!'",
		"options": [
			{"text": "Fight for the stronger claim", "wise": false},
			{"text": "Suggest sharing the water", "wise": true},
			{"text": "Call for an elder to decide", "wise": true},
			{"text": "Take the water by force", "wise": false}
		]
	},
	{
		"setup": "Traveler A: 'You damaged my cart!'\nTraveler B: 'It was an accident!'",
		"options": [
			{"text": "Demand full payment now", "wise": false},
			{"text": "Forgive and help repair", "wise": true},
			{"text": "Report to the authorities", "wise": true},
			{"text": "Retaliate with damage", "wise": false}
		]
	},
	{
		"setup": "Traveler A: 'You stole my goat!'\nTraveler B: 'I found it wandering!'",
		"options": [
			{"text": "Accuse and threaten", "wise": false},
			{"text": "Listen to both sides patiently", "wise": true},
			{"text": "Return the goat and discuss", "wise": true},
			{"text": "Keep the goat as payment", "wise": false}
		]
	},
	{
		"setup": "Traveler A: 'Your herd blocks the path!'\nTraveler B: 'This is the only road!'",
		"options": [
			{"text": "Force the herd aside", "wise": false},
			{"text": "Wait patiently for passage", "wise": true},
			{"text": "Find an alternative path together", "wise": true},
			{"text": "Drive the herd away angrily", "wise": false}
		]
	}
]
var _current_scenario: Dictionary = {}
var _prog: ProgressBar
var _count_lbl: Label
var _scenario_display: Label
var _choice_container: VBoxContainer

func _ready() -> void:
	_build_ui()
	_show_next_scenario()

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	add_child(root)

	var prompt_lbl := Label.new()
	prompt_lbl.text = prompt
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_lbl.add_theme_font_size_override("font_size", 18)
	root.add_child(prompt_lbl)

	_scenario_display = Label.new()
	_scenario_display.text = "Two travelers argue over water rights..."
	_scenario_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_scenario_display.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_scenario_display.add_theme_font_size_override("font_size", 16)
	root.add_child(_scenario_display)

	_prog = ProgressBar.new()
	_prog.min_value = 0.0
	_prog.max_value = float(goal)
	_prog.value = 0.0
	_prog.custom_minimum_size = Vector2(0, 28)
	root.add_child(_prog)

	_count_lbl = Label.new()
	_count_lbl.text = "Choices: 0 / %d" % goal
	_count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_count_lbl)

	_choice_container = VBoxContainer.new()
	_choice_container.add_theme_constant_override("separation", 8)
	root.add_child(_choice_container)

func _show_next_scenario() -> void:
	if _scenarios.is_empty() or _choices_made >= goal:
		return
	_current_scenario = _scenarios.pop_front()
	_scenario_display.text = _current_scenario["setup"]
	
	# Clear previous choices
	for child in _choice_container.get_children():
		child.queue_free()
	
	# Add new choices
	for option in _current_scenario["options"]:
		var btn := Button.new()
		btn.text = option["text"]
		btn.custom_minimum_size = Vector2(0, 50)
		btn.pressed.connect(func():
			if _done: return
			var wise: bool = option["wise"]
			if wise:
				_choices_made += 1
				_prog.value = _choices_made
				_count_lbl.text = "Choices: %d / %d" % [_choices_made, goal]
				AudioManager.play_sfx("res://assets/audio/sfx/sort_snap.wav")
				_scenario_display.text = "🤝 Wise choice! Peace advances..."
				if _choices_made >= goal:
					_done = true
					for child in _choice_container.get_children():
						child.disabled = true
					_scenario_display.text = "🤝 Peace Restored! Well done!"
					minigame_complete.emit({"root": self, "label": _count_lbl, "bar": _prog})
				else:
					await get_tree().create_timer(1.2).timeout
					_show_next_scenario()
			else:
				AudioManager.play_sfx("res://assets/audio/sfx/sort_wrong.wav")
				_scenario_display.text = "😠 Unwise choice! Conflict grows..."
				await get_tree().create_timer(1.5).timeout
				_show_next_scenario()
		)
		_choice_container.add_child(btn)