extends Control
# ─────────────────────────────────────────────────────────────────────────────
# TapMinigame.gd – Modular Mini-Game Asset
# Tap a button to reach a goal within time limit.
# "Trust in the Lord with all your heart" – Proverbs 3:5
# ─────────────────────────────────────────────────────────────────────────────

signal minigame_complete(result: Dictionary)
signal minigame_timeout(result: Dictionary)

@export var goal: int = 10
@export var prompt: String = "Tap the button as fast as you can!"
@export var time_limit: float = 15.0

var _taps: int = 0
var _done: bool = false
var _prog: ProgressBar
var _count_lbl: Label
var _tap_btn: Button
var _prompt_lbl: Label

func _ready() -> void:
	_build_ui()
	_start_timer()

func _build_ui() -> void:
	var root := VBoxContainer.new()
	add_child(root)

	_prompt_lbl = Label.new()
	_prompt_lbl.text = prompt
	_prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_prompt_lbl.add_theme_font_size_override("font_size", 18)
	root.add_child(_prompt_lbl)

	_prog = ProgressBar.new()
	_prog.min_value = 0.0
	_prog.max_value = float(goal)
	_prog.value = 0.0
	_prog.custom_minimum_size = Vector2(0, 28)
	root.add_child(_prog)

	_count_lbl = Label.new()
	_count_lbl.text = "0 / %d" % goal
	_count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_count_lbl)

	_tap_btn = Button.new()
	_tap_btn.text = "Tap!"
	_tap_btn.custom_minimum_size = Vector2(220, 70)
	_tap_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	root.add_child(_tap_btn)

	_tap_btn.pressed.connect(_on_tap)

func _on_tap() -> void:
	if _done: return
	_taps += 1
	_prog.value = _taps
	_count_lbl.text = "%d / %d" % [_taps, goal]
	AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
	if _taps >= goal:
		_done = true
		_tap_btn.disabled = true
		_tap_btn.text = "✦ Done!"
		minigame_complete.emit({"button": _tap_btn, "label": _count_lbl, "bar": _prog, "root": self})

func _start_timer() -> void:
	if time_limit > 0.0:
		get_tree().create_timer(time_limit).timeout.connect(_on_timeout)

func _on_timeout() -> void:
	if not _done:
		_done = true
		_tap_btn.disabled = true
		_tap_btn.text = "Keep trying next time!"
		minigame_timeout.emit({"button": _tap_btn, "label": _count_lbl, "bar": _prog, "root": self})