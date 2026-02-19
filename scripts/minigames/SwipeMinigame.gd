extends Control
# ─────────────────────────────────────────────────────────────────────────────
# SwipeMinigame.gd – Modular Mini-Game Asset
# Dodge obstacles by swiping left or right.
# "The Lord will watch over your coming and going" – Psalm 121:8
# ─────────────────────────────────────────────────────────────────────────────

signal minigame_complete(result: Dictionary)
signal minigame_timeout(result: Dictionary)

@export var goal: int = 5
@export var prompt: String = "Dodge the obstacles!"
@export var time_limit: float = 15.0

var _dodges: int = 0
var _done: bool = false
var _obstacles: Array = ["🌿 Branch", "🪵 Log", "🌳 Tree", "🍃 Leaves"]
var _current_obstacle: String = ""
var _prog: ProgressBar
var _count_lbl: Label
var _dodge_display: Label
var _left_btn: Button
var _right_btn: Button

func _ready() -> void:
	_build_ui()
	_spawn_obstacle()
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

	_dodge_display = Label.new()
	_dodge_display.text = "🏃 ← Dodge → 🏃"
	_dodge_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_dodge_display.add_theme_font_size_override("font_size", 24)
	root.add_child(_dodge_display)

	_prog = ProgressBar.new()
	_prog.min_value = 0.0
	_prog.max_value = float(goal)
	_prog.value = 0.0
	_prog.custom_minimum_size = Vector2(0, 28)
	root.add_child(_prog)

	_count_lbl = Label.new()
	_count_lbl.text = "Dodged: 0 / %d" % goal
	_count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_count_lbl)

	var btn_container := HBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 20)
	root.add_child(btn_container)

	_left_btn = Button.new()
	_left_btn.text = "⬅️ Left"
	_left_btn.custom_minimum_size = Vector2(120, 60)
	btn_container.add_child(_left_btn)

	_right_btn = Button.new()
	_right_btn.text = "Right ➡️"
	_right_btn.custom_minimum_size = Vector2(120, 60)
	btn_container.add_child(_right_btn)

	_left_btn.pressed.connect(func(): _check_dodge("left"))
	_right_btn.pressed.connect(func(): _check_dodge("right"))

func _spawn_obstacle() -> void:
	_current_obstacle = _obstacles.pick_random()
	_dodge_display.text = "🏃 %s coming! ← Dodge → 🏃" % _current_obstacle

func _check_dodge(direction: String) -> void:
	if _done: return
	var needed_dir := ["left", "right"].pick_random()
	if direction == needed_dir:
		_dodges += 1
		_prog.value = _dodges
		_count_lbl.text = "Dodged: %d / %d" % [_dodges, goal]
		AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
		_dodge_display.text = "✨ Dodged! 🏃 ← Ready → 🏃"
		if _dodges >= goal:
			_done = true
			_left_btn.disabled = true
			_right_btn.disabled = true
			_dodge_display.text = "🏆 All dodged! Well done!"
			minigame_complete.emit({"root": self, "label": _count_lbl, "bar": _prog, "display": _dodge_display})
		else:
			await get_tree().create_timer(0.8).timeout
			_spawn_obstacle()
	else:
		AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
		_dodge_display.text = "💥 Hit! Try again. 🏃 ← Dodge → 🏃"
		await get_tree().create_timer(1.0).timeout
		_spawn_obstacle()

func _on_timeout() -> void:
	if not _done:
		_done = true
		_left_btn.disabled = true
		_right_btn.disabled = true
		_dodge_display.text = "Time's up! Keep trying!"
		minigame_timeout.emit({"root": self, "label": _count_lbl, "bar": _prog, "display": _dodge_display})