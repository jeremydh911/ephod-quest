extends Control
# ─────────────────────────────────────────────────────────────────────────────
# RhythmMinigame.gd – Modular Mini-Game Asset
# Tap on beat to score points.
# "Make a joyful noise to the Lord" – Psalm 100:1
# ─────────────────────────────────────────────────────────────────────────────

signal minigame_complete(result: Dictionary)
signal minigame_timeout(result: Dictionary)

@export var beat_duration: float = 1.0
@export var total_beats: int = 10
@export var goal_score: int = 7
@export var prompt: String = "Tap when the circle is big!"

var _beats_left: int
var _score: int = 0
var _on_beat: bool = false
var _beat_btn: Button
var _score_lbl: Label
var _prompt_lbl: Label
var _beat_timer: Timer
var _tw_holder: Array = [null]

func _ready() -> void:
	_beats_left = total_beats
	_build_ui()
	_start_rhythm()

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	_prompt_lbl = Label.new()
	_prompt_lbl.text = prompt
	_prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_prompt_lbl.add_theme_font_size_override("font_size", 18)
	root.add_child(_prompt_lbl)

	_beat_btn = Button.new()
	_beat_btn.text = "●"
	_beat_btn.custom_minimum_size = Vector2(160, 160)
	_beat_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_beat_btn.add_theme_font_size_override("font_size", 48)
	root.add_child(_beat_btn)

	_score_lbl = Label.new()
	_score_lbl.text = "Score: 0"
	_score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_score_lbl)

	_beat_btn.pressed.connect(_on_beat_pressed)

func _start_rhythm() -> void:
	_beat_timer = Timer.new()
	_beat_timer.wait_time = beat_duration
	add_child(_beat_timer)
	_beat_timer.timeout.connect(_on_beat_timeout)
	_beat_timer.start()
	_pulse()

func _pulse() -> void:
	_tw_holder[0] = create_tween()
	_on_beat = true
	_tw_holder[0].tween_property(_beat_btn, "scale", Vector2(1.25, 1.25), beat_duration * 0.4)
	_tw_holder[0].tween_property(_beat_btn, "scale", Vector2(1.0, 1.0), beat_duration * 0.4)
	_tw_holder[0].tween_callback(func(): _on_beat = false)

func _on_beat_timeout() -> void:
	if _beats_left <= 0: return
	_beats_left -= 1
	_pulse()
	if _beats_left <= 0:
		_beat_timer.stop()
		await get_tree().create_timer(beat_duration).timeout
		if _score >= goal_score:
			minigame_complete.emit({"root": self, "score_label": _score_lbl})
		else:
			minigame_timeout.emit({"root": self, "score_label": _score_lbl})

func _on_beat_pressed() -> void:
	if _on_beat:
		_score += 1
		_score_lbl.text = "Score: %d" % _score
		AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
	else:
		AudioManager.play_sfx("res://assets/audio/sfx/click.wav")