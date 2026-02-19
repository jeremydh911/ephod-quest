extends "res://scripts/QuestBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# Quest2.gd  –  Tribe of Judah
# Mini-game 1: Praise Roar (rhythm tap)
# Mini-game 2: Group Praise Bubble (hold-button fill)
# Verse: Psalm 100:1-2  |  Nature: Lion roar / Revelation 5:5
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key  = "judah"
	quest_id   = "judah_main"
	next_scene = "res://scenes/Quest3.tscn"
	music_path = "res://assets/audio/music/quest_theme.ogg"
	super._ready()

func on_quest_ready() -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder, "text": "Shalom, shalom! Welcome to the hillside of Judah. At dawn the tribe gathers here — not in silence, but in praise. The Emerald stone rests beyond the lion's path."},
		{"name": elder, "text": "Judah means 'praise'. When the people of Israel marched, Judah led — not with swords, but with song. Bold praise opens the way."},
		{"name": "You",  "text": "Please, Elder Shelah — what must I do?"},
		{"name": elder, "text": "Listen for the lion's heartbeat. When it pulses — roar with it. Tap boldly and without hesitation.",
		 "callback": Callable(self, "_start_roar_mini")}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — PRAISE ROAR (rhythm tap)
# ─────────────────────────────────────────────────────────────────────────────
var _roar_result: Dictionary = {}

func _start_roar_mini() -> void:
	$MiniGameContainer.visible = true
	var goal := 5 if Global.selected_avatar == "david_j" else 6
	_roar_result = build_rhythm_minigame(
		$MiniGameContainer, 0.7, 12, goal,
		"The lion's pulse is building —\ntap boldly when the circle ROARS!")

func _after_roar() -> void:
	$MiniGameContainer.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder, "text": "The whole hillside heard you! Now — hold the Praise button and let the sound grow until it fills the valley."},
		{"name": elder, "text": "Judah's roar helps the other tribes too. \"Judah Roars — Reuben Climbs\" — that is the co-op gift.",
		 "callback": Callable(self, "_start_bubble_mini")}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 2 — GROUP PRAISE BUBBLE (hold-button fill)
# Bubble state lives as class fields; _process() drives the fill each frame.
# ─────────────────────────────────────────────────────────────────────────────
var _bubble_holding:    bool  = false
var _bubble_progress:   float = 0.0
var _bubble_done:       bool  = false
var _bubble_active:     bool  = false
var _bubble_fill_speed: float = 18.0
var _bubble_prog_bar:   ProgressBar = null
var _bubble_btn:        Button      = null

func _start_bubble_mini() -> void:
	var container: Node = $MiniGameContainer
	container.visible = true
	for child in container.get_children(): child.queue_free()

	var prompt := Label.new()
	prompt.text = "Hold the Praise button — keep holding until the bubble fills!"
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 18)
	container.add_child(prompt)

	_bubble_prog_bar = ProgressBar.new()
	_bubble_prog_bar.min_value = 0.0
	_bubble_prog_bar.max_value = 100.0
	_bubble_prog_bar.value     = 0.0
	_bubble_prog_bar.custom_minimum_size = Vector2(0, 32)
	container.add_child(_bubble_prog_bar)

	_bubble_btn = Button.new()
	_bubble_btn.text = "♪ Praise! ♪"
	_bubble_btn.custom_minimum_size = Vector2(0, 80)
	_bubble_btn.add_theme_font_size_override("font_size", 26)
	container.add_child(_bubble_btn)

	_bubble_fill_speed = 22.0 if Global.selected_avatar == "abigail_j" else 18.0
	_bubble_holding    = false
	_bubble_progress   = 0.0
	_bubble_done       = false
	_bubble_active     = true

	_bubble_btn.button_down.connect(func(): _bubble_holding = true)
	_bubble_btn.button_up.connect(func():   _bubble_holding = false)

func _process(delta: float) -> void:
	if not _bubble_active or _bubble_done:
		return
	if _bubble_holding:
		_bubble_progress = minf(_bubble_progress + _bubble_fill_speed * delta, 100.0)
	else:
		_bubble_progress = maxf(_bubble_progress - 8.0 * delta, 0.0)
	if _bubble_prog_bar:
		_bubble_prog_bar.value = _bubble_progress
	if _bubble_progress >= 100.0:
		_bubble_done   = true
		_bubble_active = false
		if _bubble_btn:
			_bubble_btn.disabled = true
			_bubble_btn.text = "✦ Praise fills the valley!"
		on_minigame_complete({"bubble_done": true})

func _on_bubble_complete() -> void:
	$MiniGameContainer.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "God sees your heart! The praise bubble fills the valley. Now — receive the word of Judah.",
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
	if result == _roar_result:
		_after_roar()
	elif result.has("bubble_done"):
		_on_bubble_complete()

func on_minigame_timeout(result: Dictionary) -> void:
	if result == _roar_result:
		var elder: String = _tribe_data.get("elder", "Elder")
		show_dialogue([{"name": elder,
			"text": "Let's try again. The lion roars on the beat — wait for it, then answer boldly."}])
		get_tree().create_timer(1.2).timeout.connect(func():
			for child in $MiniGameContainer.get_children(): child.queue_free()
			_roar_result = build_rhythm_minigame(
				$MiniGameContainer, 0.7, 12, 6, "Try again — tap boldly with the pulse!"),
			CONNECT_ONE_SHOT)
