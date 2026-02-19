extends "res://scripts/QuestBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# Quest4.gd  –  Tribe of Dan
# Mini-game 1: Eagle Soar (hold/release altitude)
# Mini-game 2: Pattern Lock (ordered tap)
# Verse: Proverbs 2:6  |  Nature: Eagle vision / Isaiah 40:31
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key  = "dan"
	quest_id   = "dan_main"
	next_scene = "res://scenes/Quest5.tscn"
	music_path = "res://assets/audio/music/quest_theme.ogg"
	super._ready()

func on_quest_ready() -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder, "text": "My child, shalom. Stand still for a moment. Look up. Two eagles are circling — do you see them? They are not hurrying. They are watching."},
		{"name": elder, "text": "Dan was known for sharp eyes — seeing what others missed. The Sapphire stone waits on the far ledge. To reach it, you must fly with the eagle's patience."},
		{"name": "You",  "text": "Please, Elder Shuham — how do I soar?"},
		{"name": elder, "text": "Hold to glide on the warm air currents. Release to rise. The eagle does not flap constantly — it rests on what God has already placed beneath it.",
		 "callback": Callable(self, "_start_soar_mini")}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — EAGLE SOAR (hold/release altitude control)
# State lives as class-level fields; _process drives the physics.
# ─────────────────────────────────────────────────────────────────────────────
var _soar_active:    bool  = false
var _soar_done:      bool  = false
var _soar_holding:   bool  = false
var _soar_altitude:  float = 50.0
var _soar_collected: int   = 0
var _soar_timer:     float = 0.0
var _soar_decay:     float = 6.0
var _soar_alt_bar:   ProgressBar = null
var _soar_tgt_bar:   ProgressBar = null
var _soar_status:    Label       = null
var _soar_btn:       Button      = null
var _soar_result: Dictionary = {}
var _pattern_result: Dictionary = {}

func _start_soar_mini() -> void:
	var container: Node = $MiniGameContainer
	container.visible = true

	var prompt := Label.new()
	prompt.text = "Hold to glide — release for a moment to rise.\nCollect all 5 cloud wisdoms!"
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 17)
	container.add_child(prompt)

	_soar_alt_bar = ProgressBar.new()
	_soar_alt_bar.min_value  = 0.0
	_soar_alt_bar.max_value  = 100.0
	_soar_alt_bar.value      = 50.0
	_soar_alt_bar.custom_minimum_size = Vector2(0, 24)
	container.add_child(_soar_alt_bar)

	_soar_tgt_bar = ProgressBar.new()
	_soar_tgt_bar.min_value = 0.0
	_soar_tgt_bar.max_value = 5.0
	_soar_tgt_bar.value     = 0.0
	_soar_tgt_bar.custom_minimum_size = Vector2(0, 24)
	container.add_child(_soar_tgt_bar)

	_soar_status = Label.new()
	_soar_status.text = "Cloud wisdoms: 0 / 5"
	_soar_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(_soar_status)

	_soar_btn = Button.new()
	_soar_btn.text = "🦅 Hold to Soar"
	_soar_btn.custom_minimum_size = Vector2(0, 80)
	_soar_btn.add_theme_font_size_override("font_size", 22)
	container.add_child(_soar_btn)

	_soar_decay     = 4.5 if Global.selected_avatar == "noah_d" else 6.0
	_soar_altitude  = 50.0
	_soar_collected = 0
	_soar_timer     = 0.0
	_soar_holding   = false
	_soar_done      = false
	_soar_active    = true
	_soar_result    = {"active": true}

	_soar_btn.button_down.connect(func(): _soar_holding = true)
	_soar_btn.button_up.connect(func():   _soar_holding = false)

func _process(delta: float) -> void:
	if not _soar_active or _soar_done:
		return
	_soar_timer += delta
	if _soar_holding:
		_soar_altitude = maxf(_soar_altitude - _soar_decay * delta, 0.0)
	else:
		_soar_altitude = minf(_soar_altitude + 14.0 * delta, 100.0)
	if _soar_alt_bar:
		_soar_alt_bar.value = _soar_altitude
	# Collect wisdom in the sweet spot (40-70)
	if _soar_altitude >= 40.0 and _soar_altitude <= 70.0:
		if fmod(_soar_timer, 2.2) < delta * 1.5 and _soar_collected < 5:
			_soar_collected += 1
			if _soar_tgt_bar:
				_soar_tgt_bar.value = _soar_collected
			if _soar_status:
				_soar_status.text = "Cloud wisdoms: %d / 5" % _soar_collected
			AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
			if _soar_collected >= 5:
				_soar_done   = true
				_soar_active = false
				if _soar_btn:
					_soar_btn.disabled = true
					_soar_btn.text = "✦ You soared like an eagle!"
				on_minigame_complete({"soar_done": true})

func _after_soar() -> void:
	$MiniGameContainer.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder, "text": "That is the eagle's secret — rest on what God places beneath you. Now look closer at the rock face. There is a hidden pattern only the eagle's eye can see."},
		{"name": elder, "text": "Find and tap all four hidden marks in order. Deborah's training will help.",
		 "callback": Callable(self, "_start_pattern_mini")}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 2 — PATTERN LOCK (tap in correct sequence)
# ─────────────────────────────────────────────────────────────────────────────
func _start_pattern_mini() -> void:
	var container: Node = $MiniGameContainer
	container.visible = true
	for child in container.get_children(): child.queue_free()

	var prompt := Label.new()
	prompt.text = "Four marks are hidden in the rock face.\nTap them in the right order — use the eagle's focus."
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 16)
	container.add_child(prompt)

	var needed := 3 if Global.selected_avatar == "deborah_d" else 4

	var hint_lbl := Label.new()
	hint_lbl.text = "Find mark 1 first…"
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(hint_lbl)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 18)
	container.add_child(grid)

	var _next := [0]
	var _done := [false]
	_pattern_result = {"active": true}

	for i in range(needed):
		var mark_btn := Button.new()
		mark_btn.text = "?"
		mark_btn.custom_minimum_size = Vector2(110, 64)
		grid.add_child(mark_btn)
		var idx := i
		mark_btn.pressed.connect(func():
			if _done[0]: return
			if idx == _next[0]:
				mark_btn.text = "✦"
				mark_btn.modulate = Color(0.85, 0.7, 0.1, 1)
				mark_btn.disabled = true
				AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
				_next[0] += 1
				if _next[0] >= needed:
					_done[0] = true
					hint_lbl.text = "✦ Pattern complete!"
					on_minigame_complete({"pattern_done": true})
				else:
					hint_lbl.text = "Find mark %d next…" % (_next[0] + 1)
			else:
				hint_lbl.text = "Not that one — find mark %d first." % (_next[0] + 1)
				AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
		)

func _on_pattern_complete() -> void:
	$MiniGameContainer.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "You see what others cannot. That is the gift of Dan — discernment. Now receive the word God has prepared for your tribe.",
		"callback": Callable(self, "_show_quest_verse")
	}])

func _show_quest_verse() -> void:
	show_verse_scroll(
		_tribe_data.get("quest_verse_ref", ""),
		_tribe_data.get("quest_verse", "")
	)

# ─────────────────────────────────────────────────────────────────────────────
# CALLBACKS
# ─────────────────────────────────────────────────────────────────────────────
func on_minigame_complete(result: Dictionary) -> void:
	if result.has("soar_done"):
		await get_tree().create_timer(0.6).timeout
		_after_soar()
	elif result.has("pattern_done"):
		await get_tree().create_timer(0.5).timeout
		_on_pattern_complete()

func on_minigame_timeout(_result: Dictionary) -> void:
	pass
