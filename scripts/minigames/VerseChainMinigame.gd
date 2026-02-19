extends Control
# ─────────────────────────────────────────────────────────────────────────────
# VerseChainMinigame.gd – Modular Mini-Game Asset
# Connect verses across tribes by matching themes.
# "All Scripture is God-breathed" – 2 Timothy 3:16
# ─────────────────────────────────────────────────────────────────────────────

signal minigame_complete(result: Dictionary)
signal minigame_timeout(result: Dictionary)

@export var goal: int = 5
@export var prompt: String = "Connect verses from different tribes that share a theme!"

var _chains_made: int = 0
var _done: bool = false
var _current_verse: Dictionary = {}
var _options: Array = []
var _prog: ProgressBar
var _count_lbl: Label
var _verse_display: Label
var _option_buttons: Array = []

func _ready() -> void:
	_build_ui()
	_start_chain()

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

	_verse_display = Label.new()
	_verse_display.text = "Select a starting verse..."
	_verse_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_verse_display.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_verse_display.add_theme_font_size_override("font_size", 16)
	root.add_child(_verse_display)

	_prog = ProgressBar.new()
	_prog.min_value = 0.0
	_prog.max_value = float(goal)
	_prog.value = 0.0
	_prog.custom_minimum_size = Vector2(0, 28)
	root.add_child(_prog)

	_count_lbl = Label.new()
	_count_lbl.text = "Chains: 0 / %d" % goal
	_count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_count_lbl)

	var options_container := VBoxContainer.new()
	options_container.add_theme_constant_override("separation", 8)
	root.add_child(options_container)

	for i in 4:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 50)
		btn.pressed.connect(func(): _on_option_selected(btn))
		options_container.add_child(btn)
		_option_buttons.append(btn)

func _start_chain() -> void:
	_load_random_verse()
	_load_options()

func _load_random_verse() -> void:
	var all_entries = VerseVault.get_all_entries()
	_current_verse = all_entries.pick_random()
	_verse_display.text = "%s (%s)\n\"%s\"" % [_current_verse.get("ref", ""), _current_verse.get("tribe", "").capitalize(), _current_verse.get("text", "")]

func _load_options() -> void:
	var all_entries = VerseVault.get_all_entries()
	var theme = _get_theme(_current_verse)
	var matching = all_entries.filter(func(e): return _get_theme(e) == theme and e != _current_verse)
	var non_matching = all_entries.filter(func(e): return _get_theme(e) != theme and e != _current_verse)
	
	_options = []
	_options.append_array(matching.slice(0, 2))  # 2 correct
	_options.append_array(non_matching.slice(0, 2))  # 2 incorrect
	_options.shuffle()
	
	for i in _option_buttons.size():
		if i < _options.size():
			var opt = _options[i]
			_option_buttons[i].text = "%s (%s)" % [opt.get("ref", ""), opt.get("tribe", "").capitalize()]
			_option_buttons[i].visible = true
		else:
			_option_buttons[i].visible = false

func _get_theme(verse: Dictionary) -> String:
	var text = verse.get("text", "").to_lower()
	if "trust" in text or "heart" in text: return "trust"
	if "peace" in text or "still" in text: return "peace"
	if "light" in text or "shine" in text: return "light"
	if "wisdom" in text or "understanding" in text: return "wisdom"
	if "good" in text or "blessing" in text: return "goodness"
	return "other"

func _on_option_selected(button: Button) -> void:
	if _done: return
	var selected_index = _option_buttons.find(button)
	if selected_index == -1: return
	var selected_verse = _options[selected_index]
	var is_correct = _get_theme(selected_verse) == _get_theme(_current_verse)
	
	if is_correct:
		_chains_made += 1
		_prog.value = _chains_made
		_count_lbl.text = "Chains: %d / %d" % [_chains_made, goal]
		AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
		_verse_display.text = "✨ Connected! %s" % _verse_display.text
		if _chains_made >= goal:
			_done = true
			for btn in _option_buttons:
				btn.disabled = true
			_verse_display.text = "🎉 All chains complete! Scripture weaves together!"
			minigame_complete.emit({"root": self, "chains": _chains_made})
		else:
			await get_tree().create_timer(1.5).timeout
			_start_chain()
	else:
		AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
		_verse_display.text = "❌ Not a match. Try another verse."
		await get_tree().create_timer(1.0).timeout
		_load_options()