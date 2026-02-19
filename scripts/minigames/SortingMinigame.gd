extends Control
# ─────────────────────────────────────────────────────────────────────────────
# SortingMinigame.gd – Modular Mini-Game Asset
# Sort deeds into just/unjust piles.
# "Do not pervert justice" – Deuteronomy 16:19
# ─────────────────────────────────────────────────────────────────────────────

signal minigame_complete(result: Dictionary)
signal minigame_timeout(result: Dictionary)

@export var goal: int = 4
@export var prompt: String = "Balance the scales of justice!"
@export var time_limit: float = 15.0

var _sorted: int = 0
var _done: bool = false
var _deeds: Array = [
	"Sharing food with the hungry",
	"Returning lost property",
	"Speaking truth in court",
	"Showing mercy to enemies",
	"Stealing from the rich",
	"Lying to gain advantage",
	"Harming the innocent",
	"Breaking promises"
]
var _current_deed: String = ""
var _prog: ProgressBar
var _count_lbl: Label
var _scale_display: Label
var _just_btn: Button
var _unjust_btn: Button

func _ready() -> void:
	_build_ui()
	_show_next_deed()
	if time_limit > 0.0:
		get_tree().create_timer(time_limit).timeout.connect(_on_timeout)

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

	_scale_display = Label.new()
	_scale_display.text = "⚖️ Justice Scales ⚖️"
	_scale_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_scale_display.add_theme_font_size_override("font_size", 24)
	root.add_child(_scale_display)

	_prog = ProgressBar.new()
	_prog.min_value = 0.0
	_prog.max_value = float(goal)
	_prog.value = 0.0
	_prog.custom_minimum_size = Vector2(0, 28)
	root.add_child(_prog)

	_count_lbl = Label.new()
	_count_lbl.text = "Sorted: 0 / %d" % goal
	_count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_count_lbl)

	var btn_container := HBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 20)
	root.add_child(btn_container)

	_just_btn = Button.new()
	_just_btn.text = "Just Pile\n✅"
	_just_btn.custom_minimum_size = Vector2(120, 60)
	btn_container.add_child(_just_btn)

	_unjust_btn = Button.new()
	_unjust_btn.text = "Unjust Pile\n❌"
	_unjust_btn.custom_minimum_size = Vector2(120, 60)
	btn_container.add_child(_unjust_btn)

	_just_btn.pressed.connect(func(): _check_sort(true))
	_unjust_btn.pressed.connect(func(): _check_sort(false))

func _show_next_deed() -> void:
	if _deeds.is_empty():
		return
	_current_deed = _deeds.pop_front()
	_scale_display.text = "⚖️ \"%s\" ⚖️" % _current_deed

func _check_sort(is_just: bool) -> void:
	if _done or _current_deed.is_empty():
		return
	var correct := false
	if _current_deed in ["Sharing food with the hungry", "Returning lost property", "Speaking truth in court", "Showing mercy to enemies"]:
		correct = is_just
	else:
		correct = not is_just
	
	if correct:
		_sorted += 1
		_prog.value = _sorted
		_count_lbl.text = "Sorted: %d / %d" % [_sorted, goal]
		AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
		_scale_display.text = "⚖️ Balanced! ⚖️"
		if _sorted >= goal:
			_done = true
			_just_btn.disabled = true
			_unjust_btn.disabled = true
			_scale_display.text = "⚖️ Justice Restored! ⚖️"
			minigame_complete.emit({"root": self, "label": _count_lbl, "bar": _prog})
		else:
			await get_tree().create_timer(0.8).timeout
			_show_next_deed()
	else:
		AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
		_scale_display.text = "⚖️ Unbalanced! Try again. ⚖️"
		await get_tree().create_timer(1.0).timeout
		_show_next_deed()

func _on_timeout() -> void:
	if not _done:
		_done = true
		_just_btn.disabled = true
		_unjust_btn.disabled = true
		_scale_display.text = "Time's up! Justice prevails."
		minigame_timeout.emit({"root": self, "label": _count_lbl, "bar": _prog})