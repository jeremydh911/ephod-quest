extends Control
# ─────────────────────────────────────────────────────────────────────────────
# QuestBase.gd  –  Twelve Stones / Ephod Quest

const VisualEnvironment := preload("res://scripts/VisualEnvironment.gd")
# Shared quest framework. All 12 quest scripts extend this class.
#
# Flow per quest:
#   1. Fade in → elder greeting dialogue
#   2. Player explores map (optional: find an interactable)
#   3. Main mini-game triggers
#   4. Verse scroll appears + optional memorisation input
#   5. Nature fact popup
#   6. Stone collected → celebration SFX + glow
#   7. Fade out → next scene
#
# "He guides me along the right paths for his name's sake" – Psalm 23:3
# ─────────────────────────────────────────────────────────────────────────────

# ── Subclass fills these ──────────────────────────────────────────────────────
@export var tribe_key:        String = ""        # "reuben", "judah" …
@export var quest_id:         String = ""        # "reuben_main", "judah_main" …
@export var next_scene:       String = ""        # path to next scene
@export var music_path:       String = "res://assets/audio/music/sacred_spark.wav"

# ── UI nodes (built here; subclass may add more) ──────────────────────────────
var _canvas:          CanvasLayer
var _dialogue_panel:  PanelContainer
var _dialogue_name:   Label
var _dialogue_text:   Label
var _dialogue_btn:    Button
var _verse_panel:     PanelContainer
var _verse_ref:       Label
var _verse_text:      Label
var _verse_input:     LineEdit
var _verse_btn:       Button
var _nature_panel:    PanelContainer
var _nature_text:     Label
var _nature_verse:    Label
var _nature_btn:      Button
var _stone_label:     Label
var _fade_rect:       ColorRect

# ── Internal state ────────────────────────────────────────────────────────────
var _dialogue_queue:  Array = []
var _tribe_data:      Dictionary = {}
var _stone_collected: bool = false
var _verse_queue:     Array = []
var _mini_game_container: Control  # cached ref – never null after _ready()

# ─────────────────────────────────────────────────────────────────────────────
var _dialogue_portrait: Control   # portrait panel updated per speaker

func _ready() -> void:
	_tribe_data = Global.get_tribe_data(tribe_key)
	# Build atmospheric visual environment first (sky, terrain, glow, particles)
	# "The whole earth is full of his glory" – Isaiah 6:3
	if tribe_key != "":
		VisualEnvironment.build(self, tribe_key)
	_build_ui()
	# Cache (or create) the MiniGameContainer – Philippians 4:13
	var _existing := get_node_or_null("MiniGameContainer")
	if _existing != null:
		_mini_game_container = _existing as Control
	else:
		var _vb := VBoxContainer.new()
		_vb.name = "MiniGameContainer"
		_vb.set_anchors_preset(Control.PRESET_FULL_RECT)
		_vb.add_theme_constant_override("separation", 14)
		_vb.visible = false
		add_child(_vb)
		_mini_game_container = _vb as Control
	AudioManager.play_music(music_path)
	_fade_in()
	await get_tree().create_timer(0.6).timeout
	on_quest_ready()   # subclass entry point

# ── Override in subclass ──────────────────────────────────────────────────────
func on_quest_ready() -> void:
	pass   # subclass starts elder dialogue here

# ─────────────────────────────────────────────────────────────────────────────
# UI BUILDER
# ─────────────────────────────────────────────────────────────────────────────
func _build_ui() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = 10
	add_child(_canvas)

	# ── Fade overlay ─────────────────────────────────────────────────────────
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 1)
	_fade_rect.anchors_preset = Control.PRESET_FULL_RECT
	_canvas.add_child(_fade_rect)

	# ── Dialogue panel ───────────────────────────────────────────────────────
	# Rich card with parchment texture, tribe-coloured portrait, name + text + button
	# "Let your conversation be always full of grace" – Colossians 4:6
	var tribe_hex: String = (_tribe_data.get("color", "8B6F47") as String)
	_dialogue_panel = PanelContainer.new()
	_dialogue_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_dialogue_panel.offset_top    = -210.0
	_dialogue_panel.offset_bottom = -12.0
	_dialogue_panel.offset_left   =  60.0
	_dialogue_panel.offset_right  = -60.0

	# Parchment texture panel — warm, tactile, biblical
	# "Your word is a lamp to my feet" – Psalm 119:105
	const PARCHMENT_TEX := "res://assets/sprites/ui/panel_parchment.jpg"
	if ResourceLoader.exists(PARCHMENT_TEX):
		var dp_tex := StyleBoxTexture.new()
		dp_tex.texture               = load(PARCHMENT_TEX) as Texture2D
		dp_tex.texture_margin_left   = 130.0
		dp_tex.texture_margin_right  = 130.0
		dp_tex.texture_margin_top    =  70.0
		dp_tex.texture_margin_bottom =  70.0
		dp_tex.content_margin_left   =  18.0
		dp_tex.content_margin_right  =  18.0
		dp_tex.content_margin_top    =  14.0
		dp_tex.content_margin_bottom =  14.0
		_dialogue_panel.add_theme_stylebox_override("panel", dp_tex)
	else:
		# Fallback: warm cream flat box
		var dp_style := StyleBoxFlat.new()
		var tribe_col := Color("#" + tribe_hex)
		dp_style.bg_color                   = Color(0.96, 0.90, 0.76, 0.97)
		dp_style.corner_radius_top_left     = 14
		dp_style.corner_radius_top_right    = 14
		dp_style.corner_radius_bottom_left  = 14
		dp_style.corner_radius_bottom_right = 14
		dp_style.border_width_left   = 2
		dp_style.border_width_top    = 2
		dp_style.border_width_right  = 2
		dp_style.border_width_bottom = 2
		dp_style.border_color = tribe_col.lightened(0.3)
		dp_style.shadow_size  = 6
		dp_style.shadow_offset = Vector2(0, 3)
		dp_style.shadow_color  = Color(0, 0, 0, 0.30)
		dp_style.content_margin_left   = 18
		dp_style.content_margin_right  = 18
		dp_style.content_margin_top    = 14
		dp_style.content_margin_bottom = 14
		_dialogue_panel.add_theme_stylebox_override("panel", dp_style)
	_canvas.add_child(_dialogue_panel)
	_dialogue_panel.visible = false

	# HBox: portrait left | content right
	var dhbox := HBoxContainer.new()
	dhbox.add_theme_constant_override("separation", 14)
	_dialogue_panel.add_child(dhbox)

	# Tribal initial badge — animated, gem-coloured, tribe-specific
	# "Each stone engraved like a seal with one of the twelve tribes" – Exodus 28:21
	_dialogue_portrait = VisualEnvironment.make_tribe_initial(tribe_key, 72.0)
	dhbox.add_child(_dialogue_portrait)

	var dvb := VBoxContainer.new()
	dvb.add_theme_constant_override("separation", 6)
	dvb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dhbox.add_child(dvb)

	_dialogue_name = Label.new()
	_dialogue_name.add_theme_font_size_override("font_size", 16)
	_dialogue_name.modulate = Color(0.35, 0.18, 0.04, 1)   # dark brown — readable on parchment
	dvb.add_child(_dialogue_name)

	_dialogue_text = Label.new()
	_dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_text.add_theme_font_size_override("font_size", 18)
	_dialogue_text.modulate = Color(0.12, 0.08, 0.04, 1)   # near-black — readable on parchment
	dvb.add_child(_dialogue_text)

	_dialogue_btn = Button.new()
	_dialogue_btn.text = "Continue…"
	_dialogue_btn.custom_minimum_size = Vector2(140, 44)
	_dialogue_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	_dialogue_btn.pressed.connect(_advance_dialogue)
	dvb.add_child(_dialogue_btn)

	# ── Verse scroll panel ───────────────────────────────────────────────────
	_verse_panel = _make_panel(Color(0.98, 0.95, 0.84, 0.97), Vector2(700, 300))
	_verse_panel.set_anchors_preset(Control.PRESET_CENTER)
	_verse_panel.offset_left   = -360.0
	_verse_panel.offset_right  =  360.0
	_verse_panel.offset_top    = -180.0
	_verse_panel.offset_bottom =  180.0
	_canvas.add_child(_verse_panel)
	_verse_panel.visible = false

	var vvb := VBoxContainer.new()
	vvb.add_theme_constant_override("separation", 12)
	_verse_panel.add_child(vvb)

	# Tribe initial badge centered above verse title
	var _vi_row := HBoxContainer.new()
	_vi_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vvb.add_child(_vi_row)
	_vi_row.add_child(VisualEnvironment.make_tribe_initial(tribe_key, 56.0))

	var scroll_title := Label.new()
	scroll_title.text = "✦ A Word for You ✦"
	scroll_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scroll_title.add_theme_font_size_override("font_size", 22)
	scroll_title.modulate = Color(0.6, 0.4, 0.05, 1)
	vvb.add_child(scroll_title)

	_verse_ref = Label.new()
	_verse_ref.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_verse_ref.add_theme_font_size_override("font_size", 16)
	_verse_ref.modulate = Color(0.55, 0.38, 0.08, 1)
	vvb.add_child(_verse_ref)

	_verse_text = Label.new()
	_verse_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_verse_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_verse_text.add_theme_font_size_override("font_size", 17)
	vvb.add_child(_verse_text)

	var mem_label := Label.new()
	mem_label.text = "Type the first few words to memorise it (or tap Skip):"
	mem_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mem_label.add_theme_font_size_override("font_size", 13)
	mem_label.modulate = Color(0.4, 0.4, 0.4, 1)
	vvb.add_child(mem_label)

	_verse_input = LineEdit.new()
	_verse_input.placeholder_text = "Begin typing the verse…"
	_verse_input.custom_minimum_size = Vector2(0, 44)
	vvb.add_child(_verse_input)

	_verse_btn = Button.new()
	_verse_btn.text = "Skip for now"
	_verse_btn.custom_minimum_size = Vector2(0, 44)
	_verse_btn.pressed.connect(_on_verse_done)
	vvb.add_child(_verse_btn)

	_verse_input.text_submitted.connect(func(_t): _on_verse_done())

	# ── Nature fact panel ────────────────────────────────────────────────────
	_nature_panel = _make_panel(Color(0.88, 0.97, 0.88, 0.97), Vector2(700, 320))
	_nature_panel.set_anchors_preset(Control.PRESET_CENTER)
	_nature_panel.offset_left   = -360.0
	_nature_panel.offset_right  =  360.0
	_nature_panel.offset_top    = -190.0
	_nature_panel.offset_bottom =  190.0
	_canvas.add_child(_nature_panel)
	_nature_panel.visible = false

	var nvb := VBoxContainer.new()
	nvb.add_theme_constant_override("separation", 12)
	_nature_panel.add_child(nvb)

	var nature_title := Label.new()
	nature_title.text = "🌿 God's Creation Speaks"
	nature_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nature_title.add_theme_font_size_override("font_size", 22)
	nature_title.modulate = Color(0.15, 0.5, 0.15, 1)
	nvb.add_child(nature_title)

	_nature_text = Label.new()
	_nature_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_nature_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_nature_text.add_theme_font_size_override("font_size", 16)
	nvb.add_child(_nature_text)

	var nv_sep := HSeparator.new()
	nvb.add_child(nv_sep)

	_nature_verse = Label.new()
	_nature_verse.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_nature_verse.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_nature_verse.add_theme_font_size_override("font_size", 15)
	_nature_verse.modulate = Color(0.15, 0.4, 0.12, 1)
	nvb.add_child(_nature_verse)

	_nature_btn = Button.new()
	_nature_btn.text = "Thank you, God! ✦"
	_nature_btn.custom_minimum_size = Vector2(0, 48)
	_nature_btn.pressed.connect(_on_nature_done)
	nvb.add_child(_nature_btn)

	# ── Stone collected label ────────────────────────────────────────────────
	_stone_label = Label.new()
	_stone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stone_label.add_theme_font_size_override("font_size", 28)
	_stone_label.modulate = Color(1.0, 0.85, 0.0, 0.0)
	_stone_label.anchors_preset = Control.PRESET_CENTER
	_stone_label.offset_left   = -300.0
	_stone_label.offset_right  =  300.0
	_stone_label.offset_top    = -50.0
	_stone_label.offset_bottom =  50.0
	_canvas.add_child(_stone_label)

# ─────────────────────────────────────────────────────────────────────────────
# DIALOGUE SYSTEM  –  "Let your conversation be always full of grace" Col 4:6
# ─────────────────────────────────────────────────────────────────────────────
## Queue up and play elder dialogue lines.
## Each entry: { "name": String, "text": String, "callback": Callable (optional) }
func show_dialogue(lines: Array) -> void:
	_dialogue_queue = lines.duplicate()
	_dialogue_panel.visible = true
	_slide_dialogue_in()
	_advance_dialogue()

func _slide_dialogue_in() -> void:
	# Panel slides up from below screen edge — inviting, not jarring
	_dialogue_panel.offset_top    = 80.0
	_dialogue_panel.offset_bottom = 280.0
	var tw := create_tween()
	tw.tween_property(_dialogue_panel, "offset_top",    -210.0, 0.38) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.parallel().tween_property(_dialogue_panel, "offset_bottom", -12.0, 0.38) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _advance_dialogue() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	if _dialogue_queue.is_empty():
		_dialogue_panel.visible = false
		return
	var line: Dictionary = _dialogue_queue.pop_front()
	var speaker: String = line.get("name", "") as String
	_dialogue_name.text = speaker
	_dialogue_text.text = line.get("text", "") as String
	_dialogue_btn.text  = "Continue…" if _dialogue_queue.size() > 0 else "I understand ✦"
	# Lofi voice murmur – elder warmth vs child brightness
	# "A gentle answer turns away wrath" – Proverbs 15:1
	AudioManager.play_voice(speaker)
	# Update portrait emoji: elder = 👴, player/you = 🧒
	if _dialogue_portrait != null:
		var lbl: Label = _dialogue_portrait.get_child(0) as Label
		if lbl != null:
			lbl.text = "👴" if speaker.to_lower() != "you" else "🧒"
	if line.has("callback") and line["callback"] is Callable:
		# Fire callback after this line is dismissed
		var cb: Callable = line["callback"]
		_dialogue_btn.pressed.disconnect(_advance_dialogue)
		_dialogue_btn.pressed.connect(func():
			_dialogue_btn.pressed.connect(_advance_dialogue)
			_advance_dialogue()
			cb.call()
		, CONNECT_ONE_SHOT)

# ─────────────────────────────────────────────────────────────────────────────
# VERSE SCROLL  –  "Your word is a lamp to my feet" – Psalm 119:105
# ─────────────────────────────────────────────────────────────────────────────
func show_verses(entries: Array) -> void:
	_verse_queue = entries.duplicate()
	_show_next_verse()

func show_verse_scroll(ref: String, text: String) -> void:
	show_verses([{"ref": ref, "text": text}])

func _show_next_verse() -> void:
	if _verse_queue.is_empty():
		_show_nature_or_collect()
		return
	var entry: Dictionary = _verse_queue.pop_front()
	_verse_ref.text  = entry.get("ref", "")
	_verse_text.text = "\"" + entry.get("text", "") + "\""
	_verse_input.text = ""
	_verse_btn.text  = "Skip for now"
	_verse_panel.visible = true
	AudioManager.play_sfx("res://assets/audio/sfx/verse_reveal.wav")
	_verse_panel.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_verse_panel, "modulate:a", 1.0, 0.5)

func _on_verse_done() -> void:
	var typed: String = _verse_input.text.strip_edges().to_lower()
	var verse_start: String = _verse_text.text.substr(1, 20).to_lower()
	if typed.length() >= 8 and verse_start.begins_with(typed.substr(0, min(typed.length(), 8))):
		# Close enough — award memorisation
		Global.add_verse(tribe_key, _verse_ref.text)
		AudioManager.play_sfx("res://assets/audio/sfx/heart_badge.wav")
		_verse_btn.text = "✦ Memorised! Well done ✦"
		await get_tree().create_timer(1.2).timeout
	AudioManager.play_sfx("res://assets/audio/sfx/ui_close.wav")
	_verse_panel.visible = false
	_show_next_verse()

# ─────────────────────────────────────────────────────────────────────────────
# NATURE FACT  –  "Look at the birds… your heavenly Father feeds them" Mt 6:26
# ─────────────────────────────────────────────────────────────────────────────
func show_nature_fact() -> void:
	_nature_text.text  = _tribe_data.get("nature_fact",  "")
	var ref: String    = _tribe_data.get("nature_verse_ref", "")
	var nv:  String    = _tribe_data.get("nature_verse", "")
	_nature_verse.text = ref + "  —  \"" + nv + "\""
	_nature_panel.visible = true
	AudioManager.play_sfx("res://assets/audio/sfx/ui_open.wav")
	_nature_panel.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_nature_panel, "modulate:a", 1.0, 0.5)

func _show_nature_or_collect() -> void:
	show_nature_fact()

func _on_nature_done() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/ui_close.wav")
	_nature_panel.visible = false
	_collect_stone()

# ─────────────────────────────────────────────────────────────────────────────
# STONE COLLECTION  –  "Twelve stones… one for each of the tribes" Joshua 4:20
# ─────────────────────────────────────────────────────────────────────────────
func _collect_stone() -> void:
	if _stone_collected:
		return
	_stone_collected = true
	Global.add_stone(tribe_key)
	Global.complete_quest(quest_id)
	AudioManager.play_sfx("res://assets/audio/sfx/stone_unlock.wav")

	var stone_name: String = _tribe_data.get("stone_name", "Stone")
	var tribe_display: String = _tribe_data.get("display", tribe_key.capitalize())
	_stone_label.text = "✦ %s Stone Collected!\nTribe of %s" % [stone_name, tribe_display]

	# Glow in
	var tw := create_tween()
	tw.tween_property(_stone_label, "modulate:a", 1.0, 0.5)
	tw.tween_interval(2.0)
	tw.tween_callback(_go_next)

func _go_next() -> void:
	_fade_out_and_change(next_scene if next_scene != "" else "res://scenes/Finale.tscn")

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME HELPERS  –  subclass calls these
# ─────────────────────────────────────────────────────────────────────────────
## Create a tap-counter mini-game button in the scene.
## Returns a dict with "button", "label", "progress_bar" (all Node refs).
func build_tap_minigame(parent: Node, goal: int,
		prompt: String, time_limit: float = 15.0) -> Dictionary:
	var minigame = preload("res://scenes/minigames/TapMinigame.tscn").instantiate()
	minigame.goal = goal
	minigame.prompt = prompt
	minigame.time_limit = time_limit
	parent.add_child(minigame)
	minigame.minigame_complete.connect(func(result): on_minigame_complete(result))
	minigame.minigame_timeout.connect(func(result): on_minigame_timeout(result))
	return {"root": minigame}

## Build a rhythm tap mini-game. Pulses a circle, player must tap when it's big.
## Returns result dict. on_minigame_complete called when score >= goal.
func build_rhythm_minigame(parent: Node, beat_duration: float,
		total_beats: int, goal_score: int, prompt: String) -> Dictionary:
	var minigame = preload("res://scenes/minigames/RhythmMinigame.tscn").instantiate()
	minigame.beat_duration = beat_duration
	minigame.total_beats = total_beats
	minigame.goal_score = goal_score
	minigame.prompt = prompt
	parent.add_child(minigame)
	minigame.minigame_complete.connect(func(result): on_minigame_complete(result))
	minigame.minigame_timeout.connect(func(result): on_minigame_timeout(result))
	return {"root": minigame}

## Build a swipe dodge mini-game. Player swipes left/right to dodge obstacles.
## Returns result dict. on_minigame_complete called when dodges >= goal.
func build_swipe_minigame(parent: Node, goal: int,
		prompt: String, time_limit: float = 15.0) -> Dictionary:
	var minigame = preload("res://scenes/minigames/SwipeMinigame.tscn").instantiate()
	minigame.goal = goal
	minigame.prompt = prompt
	minigame.time_limit = time_limit
	parent.add_child(minigame)
	minigame.minigame_complete.connect(func(result): on_minigame_complete(result))
	minigame.minigame_timeout.connect(func(result): on_minigame_timeout(result))
	return {"root": minigame}

## Build a sorting mini-game. Player sorts items into categories.
## Returns result dict. on_minigame_complete called when all sorted.
func build_sorting_minigame(parent: Node, goal: int,
		prompt: String, time_limit: float = 15.0) -> Dictionary:
	var minigame = preload("res://scenes/minigames/SortingMinigame.tscn").instantiate()
	minigame.goal = goal
	minigame.prompt = prompt
	minigame.time_limit = time_limit
	parent.add_child(minigame)
	minigame.minigame_complete.connect(func(result): on_minigame_complete(result))
	minigame.minigame_timeout.connect(func(result): on_minigame_timeout(result))
	return {"root": minigame}

## Build a dialogue choice mini-game. Player chooses responses to resolve conflict.
## Returns result dict. on_minigame_complete called when all choices made.
func build_dialogue_choice_minigame(parent: Node, goal: int,
		prompt: String) -> Dictionary:
	var minigame = preload("res://scenes/minigames/DialogueChoiceMinigame.tscn").instantiate()
	minigame.goal = goal
	minigame.prompt = prompt
	parent.add_child(minigame)
	minigame.minigame_complete.connect(func(result): on_minigame_complete(result))
	minigame.minigame_timeout.connect(func(result): on_minigame_timeout(result))
	return {"root": minigame}

## Build a simple tower defense mini-game. Player places towers, waves attack.
## Returns result dict. on_minigame_complete called when all waves defeated.
func build_tower_defense_minigame(parent: Node, goal: int,
		prompt: String, time_limit: float = 25.0) -> Dictionary:
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	parent.add_child(root)

	var prompt_lbl := Label.new()
	prompt_lbl.text = prompt
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_lbl.add_theme_font_size_override("font_size", 18)
	root.add_child(prompt_lbl)

	var stronghold_display := Label.new()
	stronghold_display.text = "🏰 Stronghold Defense 🏰"
	stronghold_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stronghold_display.add_theme_font_size_override("font_size", 24)
	root.add_child(stronghold_display)

	var prog := ProgressBar.new()
	prog.min_value = 0.0
	prog.max_value = float(goal)
	prog.value     = 0.0
	prog.custom_minimum_size = Vector2(0, 28)
	root.add_child(prog)

	var wave_lbl := Label.new()
	wave_lbl.text = "Wave: 1 / %d" % goal
	wave_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(wave_lbl)

	var btn_container := HBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 15)
	root.add_child(btn_container)

	var place_btn := Button.new()
	place_btn.text = "Place Tower\n🏹"
	place_btn.custom_minimum_size = Vector2(120, 60)
	btn_container.add_child(place_btn)

	var defend_btn := Button.new()
	defend_btn.text = "Defend!\n⚔️"
	defend_btn.custom_minimum_size = Vector2(120, 60)
	btn_container.add_child(defend_btn)

	var towers := [0]
	var waves_defeated := [0]
	var done   := [false]
	var invaders := ["🐺 Wolf", "🦌 Deer", "🐻 Bear", "🦊 Fox"]
	var current_invader := [""]
	var result := {"root": root, "wave_label": wave_lbl, "bar": prog}

	var spawn_invader := func():
		current_invader[0] = invaders.pick_random()
		stronghold_display.text = "🏰 %s approaches! 🏰" % current_invader[0]

	var check_defense := func():
		if done[0]: return
		var defended: bool = (towers[0] as int) > 0  # Simple: having towers helps
		if defended:
			waves_defeated[0] += 1
			prog.value = waves_defeated[0]
			wave_lbl.text = "Wave: %d / %d" % [waves_defeated[0] + 1, goal]
			AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
			stronghold_display.text = "🏰 Wave defeated! 🏰"
			if waves_defeated[0] >= goal:
				done[0] = true
				place_btn.disabled = true
				defend_btn.disabled = true
				stronghold_display.text = "🏰 Stronghold Secured! 🏰"
				on_minigame_complete(result)
			else:
				towers[0] = max(0, towers[0] - 1)  # Towers wear down
				await get_tree().create_timer(0.8).timeout
				spawn_invader.call()
		else:
			AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
			stronghold_display.text = "🏰 Breached! Place more towers. 🏰"
			await get_tree().create_timer(1.0).timeout
			spawn_invader.call()

	place_btn.pressed.connect(func():
		towers[0] += 1
		AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
		stronghold_display.text = "🏰 Tower placed! (%d towers) 🏰" % towers[0]
	)

	defend_btn.pressed.connect(check_defense)

	# Start first invader
	spawn_invader.call()

	# Time limit
	if time_limit > 0.0:
		get_tree().create_timer(time_limit).timeout.connect(func():
			if not done[0]:
				done[0] = true
				place_btn.disabled = true
				defend_btn.disabled = true
				stronghold_display.text = "Time's up! Defense holds."
				on_minigame_timeout(result)
		)
	return result

## Build an endurance mini-game. Player must sustain effort over time.
## Returns result dict. on_minigame_complete called when time completed.
func build_endurance_minigame(parent: Node, prompt: String) -> Dictionary:
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	parent.add_child(root)

	var prompt_lbl := Label.new()
	prompt_lbl.text = prompt
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_lbl.add_theme_font_size_override("font_size", 18)
	root.add_child(prompt_lbl)

	var race_display := Label.new()
	race_display.text = "🏃‍♂️ Endurance Race 🏃‍♂️"
	race_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	race_display.add_theme_font_size_override("font_size", 24)
	root.add_child(race_display)

	var prog := ProgressBar.new()
	prog.min_value = 0.0
	prog.max_value = 20.0  # 20 seconds
	prog.value     = 0.0
	prog.custom_minimum_size = Vector2(0, 28)
	root.add_child(prog)

	var time_lbl := Label.new()
	time_lbl.text = "Time: 0 / 20 s"
	time_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(time_lbl)

	var run_btn := Button.new()
	run_btn.text = "Keep Running!\n🏃‍♂️"
	run_btn.custom_minimum_size = Vector2(200, 80)
	run_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	root.add_child(run_btn)

	var time_elapsed := [0.0]
	var done   := [false]
	var stamina := [100.0]
	var result := {"root": root, "time_label": time_lbl, "bar": prog}

	var update_display := func():
		time_lbl.text = "Time: %.1f / 20 s" % time_elapsed[0]
		prog.value = time_elapsed[0]
		if stamina[0] < 50:
			race_display.text = "🏃‍♂️ Tired... Keep going! 🏃‍♂️"
		elif stamina[0] < 25:
			race_display.text = "🏃‍♂️ Exhausted! Persevere! 🏃‍♂️"
		else:
			race_display.text = "🏃‍♂️ Running strong! 🏃‍♂️"

	var timer := Timer.new()
	timer.wait_time = 0.1
	add_child(timer)
	timer.timeout.connect(func():
		if done[0]: return
		time_elapsed[0] += 0.1
		stamina[0] -= 0.5  # Stamina drains over time
		update_display.call()
		if time_elapsed[0] >= 20.0:
			done[0] = true
			timer.stop()
			run_btn.disabled = true
			race_display.text = "🏆 Race Complete! 🏆"
			on_minigame_complete(result)
		elif stamina[0] <= 0:
			done[0] = true
			timer.stop()
			run_btn.disabled = true
			race_display.text = "💨 Too exhausted! Rest and try again."
			on_minigame_timeout(result)
	)

	run_btn.pressed.connect(func():
		if done[0]: return
		stamina[0] = min(100.0, stamina[0] + 2.0)  # Restore some stamina
		AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
		update_display.call()
	)

	timer.start()
	return result

## Build a harvesting mini-game. Player collects crops and shares bread.
## Returns result dict. on_minigame_complete called when all shared.
func build_harvesting_minigame(parent: Node, goal: int,
		prompt: String, time_limit: float = 18.0) -> Dictionary:
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	parent.add_child(root)

	var prompt_lbl := Label.new()
	prompt_lbl.text = prompt
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_lbl.add_theme_font_size_override("font_size", 18)
	root.add_child(prompt_lbl)

	var valley_display := Label.new()
	valley_display.text = "🌾 Fertile Valley 🌾"
	valley_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	valley_display.add_theme_font_size_override("font_size", 24)
	root.add_child(valley_display)

	var prog := ProgressBar.new()
	prog.min_value = 0.0
	prog.max_value = float(goal)
	prog.value     = 0.0
	prog.custom_minimum_size = Vector2(0, 28)
	root.add_child(prog)

	var share_lbl := Label.new()
	share_lbl.text = "Shared: 0 / %d" % goal
	share_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(share_lbl)

	var btn_container := HBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 15)
	root.add_child(btn_container)

	var harvest_btn := Button.new()
	harvest_btn.text = "Harvest\n🌾"
	harvest_btn.custom_minimum_size = Vector2(100, 60)
	btn_container.add_child(harvest_btn)

	var share_btn := Button.new()
	share_btn.text = "Share Bread\n🍞"
	share_btn.custom_minimum_size = Vector2(120, 60)
	btn_container.add_child(share_btn)

	var crops := [0]
	var shared := [0]
	var done   := [false]
	var visitors := ["Traveler", "Family", "Elder", "Child"]
	var current_visitor := [""]
	var result := {"root": root, "share_label": share_lbl, "bar": prog}

	var greet_visitor := func():
		current_visitor[0] = visitors.pick_random()
		valley_display.text = "🌾 %s approaches hungry! 🌾" % current_visitor[0]

	var check_share := func():
		if done[0] or crops[0] <= 0: return
		crops[0] -= 1
		shared[0] += 1
		prog.value = shared[0]
		share_lbl.text = "Shared: %d / %d" % [shared[0], goal]
		AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
		valley_display.text = "🌾 Bread shared! %s blessed! 🌾" % current_visitor[0]
		if shared[0] >= goal:
			done[0] = true
			harvest_btn.disabled = true
			share_btn.disabled = true
			valley_display.text = "🌾 Abundance shared! Blessing flows! 🌾"
			on_minigame_complete(result)
		else:
			await get_tree().create_timer(0.8).timeout
			greet_visitor.call()

	harvest_btn.pressed.connect(func():
		crops[0] += 1
		AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
		valley_display.text = "🌾 Crop harvested! (%d crops) 🌾" % crops[0]
	)

	share_btn.pressed.connect(check_share)

	# Start first visitor
	greet_visitor.call()

	# Time limit
	if time_limit > 0.0:
		get_tree().create_timer(time_limit).timeout.connect(func():
			if not done[0]:
				done[0] = true
				harvest_btn.disabled = true
				share_btn.disabled = true
				valley_display.text = "Time's up! Harvest shared."
				on_minigame_timeout(result)
		)
	return result

## Build a honey dance mini-game. Player follows bee's waggle pattern.
## Returns result dict. on_minigame_complete called when all dances followed.
func build_honey_dance_minigame(parent: Node, goal: int,
		prompt: String) -> Dictionary:
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	parent.add_child(root)

	var prompt_lbl := Label.new()
	prompt_lbl.text = prompt
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_lbl.add_theme_font_size_override("font_size", 18)
	root.add_child(prompt_lbl)

	var dance_display := Label.new()
	dance_display.text = "🐝 Honey Dance 🐝"
	dance_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dance_display.add_theme_font_size_override("font_size", 24)
	root.add_child(dance_display)

	var prog := ProgressBar.new()
	prog.min_value = 0.0
	prog.max_value = float(goal)
	prog.value     = 0.0
	prog.custom_minimum_size = Vector2(0, 28)
	root.add_child(prog)

	var dance_lbl := Label.new()
	dance_lbl.text = "Dances: 0 / %d" % goal
	dance_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(dance_lbl)

	var pattern_container := HBoxContainer.new()
	pattern_container.add_theme_constant_override("separation", 10)
	root.add_child(pattern_container)

	var left_btn := Button.new()
	left_btn.text = "⬅️"
	left_btn.custom_minimum_size = Vector2(80, 80)
	pattern_container.add_child(left_btn)

	var right_btn := Button.new()
	right_btn.text = "➡️"
	right_btn.custom_minimum_size = Vector2(80, 80)
	pattern_container.add_child(right_btn)

	var up_btn := Button.new()
	up_btn.text = "⬆️"
	up_btn.custom_minimum_size = Vector2(80, 80)
	pattern_container.add_child(up_btn)

	var down_btn := Button.new()
	down_btn.text = "⬇️"
	down_btn.custom_minimum_size = Vector2(80, 80)
	pattern_container.add_child(down_btn)

	var dances_completed := [0]
	var done   := [false]
	var current_pattern := []
	var player_pattern := []
	var directions := ["left", "right", "up", "down"]
	var result := {"root": root, "dance_label": dance_lbl, "bar": prog}

	var show_pattern := func(pattern: Array):
		dance_display.text = "🐝 Watch: " + " ".join(pattern.map(func(d): return {"left":"⬅️","right":"➡️","up":"⬆️","down":"⬇️"}[d])) + " 🐝"

	var generate_pattern := func():
		current_pattern.clear()
		player_pattern.clear()
		var length: int = (dances_completed[0] as int) + 2  # Patterns get longer
		for i in range(length):
			current_pattern.append(directions.pick_random())
		show_pattern.call(current_pattern)
		await get_tree().create_timer(2.0).timeout
		dance_display.text = "🐝 Your turn! Repeat the dance! 🐝"

	var check_dance := func(direction: String):
		if done[0] or current_pattern.is_empty(): return
		player_pattern.append(direction)
		if player_pattern.size() == current_pattern.size():
			var correct := true
			for i in range(current_pattern.size()):
				if player_pattern[i] != current_pattern[i]:
					correct = false
					break
			if correct:
				dances_completed[0] += 1
				prog.value = dances_completed[0]
				dance_lbl.text = "Dances: %d / %d" % [dances_completed[0], goal]
				AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
				dance_display.text = "🐝 Perfect dance! 🐝"
				if dances_completed[0] >= goal:
					done[0] = true
					left_btn.disabled = true
					right_btn.disabled = true
					up_btn.disabled = true
					down_btn.disabled = true
					dance_display.text = "🐝 All dances learned! Sweet success! 🐝"
					on_minigame_complete(result)
				else:
					await get_tree().create_timer(1.5).timeout
					generate_pattern.call()
			else:
				AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
				dance_display.text = "🐝 Wrong step! Watch again... 🐝"
				await get_tree().create_timer(1.5).timeout
				show_pattern.call(current_pattern)
				await get_tree().create_timer(2.0).timeout
				dance_display.text = "🐝 Your turn! Repeat the dance! 🐝"
				player_pattern.clear()

	left_btn.pressed.connect(func(): check_dance.call("left"))
	right_btn.pressed.connect(func(): check_dance.call("right"))
	up_btn.pressed.connect(func(): check_dance.call("up"))
	down_btn.pressed.connect(func(): check_dance.call("down"))

	# Start first pattern
	generate_pattern.call()
	return result

## Build an astronomy puzzle mini-game. Player arranges constellation pieces.
## Returns result dict. on_minigame_complete called when puzzle solved.
func build_astronomy_puzzle_minigame(parent: Node, goal: int,
		prompt: String, time_limit: float = 20.0) -> Dictionary:
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	parent.add_child(root)

	var prompt_lbl := Label.new()
	prompt_lbl.text = prompt
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_lbl.add_theme_font_size_override("font_size", 18)
	root.add_child(prompt_lbl)

	var sky_display := Label.new()
	sky_display.text = "🌌 Night Sky 🌌"
	sky_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sky_display.add_theme_font_size_override("font_size", 24)
	root.add_child(sky_display)

	var prog := ProgressBar.new()
	prog.min_value = 0.0
	prog.max_value = float(goal)
	prog.value     = 0.0
	prog.custom_minimum_size = Vector2(0, 28)
	root.add_child(prog)

	var piece_lbl := Label.new()
	piece_lbl.text = "Pieces: 0 / %d" % goal
	piece_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(piece_lbl)

	var btn_container := GridContainer.new()
	btn_container.columns = 4
	root.add_child(btn_container)

	var pieces_placed := [0]
	var done   := [false]
	var star_positions := ["⭐", "✨", "🌟", "💫", "🌠", "🌌", "🌃", "🌙"]
	var current_puzzle := []
	var result := {"root": root, "piece_label": piece_lbl, "bar": prog}

	var generate_puzzle := func():
		current_puzzle.clear()
		var shuffled := star_positions.duplicate()
		shuffled.shuffle()
		for i in range(goal):
			current_puzzle.append(shuffled[i])
		sky_display.text = "🌌 Arrange: " + " ".join(current_puzzle) + " 🌌"

	var check_placement := func(piece: String, position: int):
		if done[0]: return
		var correct_position := star_positions.find(piece)
		if position == correct_position:
			pieces_placed[0] += 1
			prog.value = pieces_placed[0]
			piece_lbl.text = "Pieces: %d / %d" % [pieces_placed[0], goal]
			AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
			sky_display.text = "🌌 Star aligned! 🌌"
			if pieces_placed[0] >= goal:
				done[0] = true
				for child in btn_container.get_children():
					child.disabled = true
				sky_display.text = "🌌 Constellation Complete! 🌌"
				on_minigame_complete(result)
			else:
				await get_tree().create_timer(0.5).timeout
				generate_puzzle.call()
		else:
			AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
			sky_display.text = "🌌 Wrong position! Try again. 🌌"

	# Create position buttons
	for i in range(goal):
		var btn := Button.new()
		btn.text = "%d" % (i + 1)
		btn.custom_minimum_size = Vector2(60, 60)
		var pos := i
		btn.pressed.connect(func(): check_placement.call(current_puzzle[pos] if pos < current_puzzle.size() else "?", pos))
		btn_container.add_child(btn)

	# Start puzzle
	generate_puzzle.call()

	# Time limit
	if time_limit > 0.0:
		get_tree().create_timer(time_limit).timeout.connect(func():
			if not done[0]:
				done[0] = true
				for child in btn_container.get_children():
					child.disabled = true
				sky_display.text = "Time's up! Stars aligned."
				on_minigame_timeout(result)
		)
	return result

## Build a time management mini-game. Player schedules activities.
## Returns result dict. on_minigame_complete called when all scheduled.
func build_time_management_minigame(parent: Node, goal: int,
		prompt: String) -> Dictionary:
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	parent.add_child(root)

	var prompt_lbl := Label.new()
	prompt_lbl.text = prompt
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_lbl.add_theme_font_size_override("font_size", 18)
	root.add_child(prompt_lbl)

	var schedule_display := Label.new()
	schedule_display.text = "📅 Tribal Schedule 📅"
	schedule_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	schedule_display.add_theme_font_size_override("font_size", 24)
	root.add_child(schedule_display)

	var prog := ProgressBar.new()
	prog.min_value = 0.0
	prog.max_value = float(goal)
	prog.value     = 0.0
	prog.custom_minimum_size = Vector2(0, 28)
	root.add_child(prog)

	var task_lbl := Label.new()
	task_lbl.text = "Tasks: 0 / %d" % goal
	task_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(task_lbl)

	var time_slots := ["Dawn", "Morning", "Noon", "Afternoon", "Evening", "Night"]
	var activities := [
		"Prayer", "Work", "Study", "Rest", "Teach", "Gather",
		"Worship", "Plan", "Help", "Celebrate", "Prepare", "Reflect"
	]
	
	var current_task := [""]
	var tasks_scheduled := [0]
	var done   := [false]
	var result := {"root": root, "task_label": task_lbl, "bar": prog}

	var assign_task := func():
		if activities.is_empty():
			return
		current_task[0] = activities.pop_front()
		schedule_display.text = "📅 Schedule: %s 📅" % current_task[0]

	var check_schedule := func(time: String):
		if done[0] or current_task[0].is_empty(): return
		var correct := false
		if current_task[0] == "Prayer" and time == "Dawn":
			correct = true
		elif current_task[0] == "Work" and time == "Morning":
			correct = true
		elif current_task[0] == "Study" and time == "Afternoon":
			correct = true
		elif current_task[0] == "Rest" and time == "Evening":
			correct = true
		elif current_task[0] == "Teach" and time == "Noon":
			correct = true
		elif current_task[0] == "Gather" and time == "Night":
			correct = true
		
		if correct:
			tasks_scheduled[0] += 1
			prog.value = tasks_scheduled[0]
			task_lbl.text = "Tasks: %d / %d" % [tasks_scheduled[0], goal]
			AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
			schedule_display.text = "📅 Well timed! 📅"
			if tasks_scheduled[0] >= goal:
				done[0] = true
				schedule_display.text = "📅 Schedule Complete! 📅"
				on_minigame_complete(result)
			else:
				await get_tree().create_timer(0.8).timeout
				assign_task.call()
		else:
			AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
			schedule_display.text = "📅 Poor timing! Try again. 📅"
			await get_tree().create_timer(1.0).timeout
			assign_task.call()

	# Create time slot buttons
	var btn_container := HBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 8)
	root.add_child(btn_container)
	
	for slot in time_slots:
		var btn := Button.new()
		btn.text = slot
		btn.custom_minimum_size = Vector2(80, 50)
		var time_slot: String = slot as String
		btn.pressed.connect(func(): check_schedule.call(time_slot))
		btn_container.add_child(btn)

	# Start first task
	assign_task.call()
	return result

# ─────────────────────────────────────────────────────────────────────────────
# SAILING MINI-GAME (Zebulun)
# Guide ship through waves by tapping to steer
# ─────────────────────────────────────────────────────────────────────────────
func build_sailing_minigame(parent: Node, prompt: String, time_limit: float) -> Control:
	var result := {"success": false}
	var root := Control.new()
	root.custom_minimum_size = Vector2(520, 300)
	parent.add_child(root)

	# Ship position and movement
	var ship_pos := Vector2(50, 150)
	var ship_speed := 2.0
	var wave_offset := 0.0
	var steering := 0.0  # -1 left, 0 straight, 1 right
	var obstacles_hit := 0
	var max_obstacles := 3

	# UI elements
	var prompt_lbl := Label.new()
	prompt_lbl.text = prompt
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.add_theme_font_size_override("font_size", 14)
	root.add_child(prompt_lbl)

	var ship_rect := ColorRect.new()
	ship_rect.color = Color(0.8, 0.6, 0.4, 1)  # Brown ship
	ship_rect.custom_minimum_size = Vector2(20, 10)
	root.add_child(ship_rect)

	var wave_rect := ColorRect.new()
	wave_rect.color = Color(0.3, 0.6, 0.9, 0.7)  # Blue waves
	wave_rect.custom_minimum_size = Vector2(520, 300)
	wave_rect.z_index = -1
	root.add_child(wave_rect)

	var obstacle_rects: Array[ColorRect] = []
	for i in range(5):
		var obs := ColorRect.new()
		obs.color = Color(0.8, 0.2, 0.2, 1)  # Red obstacles
		obs.custom_minimum_size = Vector2(15, 15)
		obs.position = Vector2(600 + i * 120, randf_range(50, 250))
		root.add_child(obs)
		obstacle_rects.append(obs)

	var timer_bar := ProgressBar.new()
	timer_bar.max_value = time_limit
	timer_bar.value = time_limit
	timer_bar.custom_minimum_size = Vector2(200, 20)
	timer_bar.position = Vector2(160, 10)
	root.add_child(timer_bar)

	var steer_left_btn := Button.new()
	steer_left_btn.text = "⬅️"
	steer_left_btn.custom_minimum_size = Vector2(60, 60)
	steer_left_btn.position = Vector2(10, 200)
	root.add_child(steer_left_btn)

	var steer_right_btn := Button.new()
	steer_right_btn.text = "➡️"
	steer_right_btn.custom_minimum_size = Vector2(60, 60)
	steer_right_btn.position = Vector2(450, 200)
	root.add_child(steer_right_btn)

	# Game logic
	var time_left := time_limit
	var game_active := true

	var update_game := func(delta: float) -> void:
		if not game_active:
			return

		time_left -= delta
		timer_bar.value = time_left

		if time_left <= 0:
			game_active = false
			result["success"] = obstacles_hit == 0
			on_minigame_complete(result)
			return

		# Update steering
		steering = 0
		if steer_left_btn.button_pressed:
			steering = -1
		elif steer_right_btn.button_pressed:
			steering = 1

		# Move ship
		ship_pos.x += ship_speed
		ship_pos.y += steering * 1.5 + sin(wave_offset) * 0.5
		ship_pos.y = clamp(ship_pos.y, 20, 280)
		ship_rect.position = ship_pos
		wave_offset += 0.1

		# Move obstacles
		for obs in obstacle_rects:
			obs.position.x -= 3.0
			if obs.position.x < -20:
				obs.position.x = 600
				obs.position.y = randf_range(50, 250)

			# Check collision
			if ship_rect.get_rect().intersects(obs.get_rect().grow(-2)):
				obstacles_hit += 1
				obs.position.x = 600
				obs.position.y = randf_range(50, 250)
				AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
				if obstacles_hit >= max_obstacles:
					game_active = false
					result["success"] = false
					on_minigame_complete(result)
					return

		# Win condition: reach end without hitting obstacles
		if ship_pos.x >= 550:
			game_active = false
			result["success"] = true
			on_minigame_complete(result)

	var timer := Timer.new()
	timer.wait_time = 0.016  # ~60 FPS
	timer.timeout.connect(func(): update_game.call(0.016))
	root.add_child(timer)
	timer.start()

	return root

# ─────────────────────────────────────────────────────────────────────────────
# HOSPITALITY MINI-GAME (Zebulun)
# Match travelers' needs with available gifts
# ─────────────────────────────────────────────────────────────────────────────
func build_hospitality_minigame(parent: Node, prompt: String, time_limit: float) -> Control:
	var result := {"success": false}
	var root := Control.new()
	root.custom_minimum_size = Vector2(520, 300)
	parent.add_child(root)

	# Game data
	var travelers := [
		{"name": "Weary Pilgrim", "need": "Food", "icon": "🍞"},
		{"name": "Cold Traveler", "need": "Shelter", "icon": "🏠"},
		{"name": "Thirsty Merchant", "need": "Water", "icon": "💧"},
		{"name": "Lost Shepherd", "need": "Guidance", "icon": "🗺️"},
		{"name": "Sick Stranger", "need": "Healing", "icon": "💊"}
	]

	var gifts := ["🍞", "🏠", "💧", "🗺️", "💊"]
	var current_traveler := 0
	var matches_made := 0
	var goal_matches := 4

	# UI elements
	var prompt_lbl := Label.new()
	prompt_lbl.text = prompt
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.add_theme_font_size_override("font_size", 14)
	root.add_child(prompt_lbl)

	var traveler_panel := _make_panel(Color(0.9, 0.8, 0.7, 1), Vector2(200, 80))
	traveler_panel.position = Vector2(20, 50)
	root.add_child(traveler_panel)

	var traveler_name := Label.new()
	traveler_name.text = travelers[0]["name"]
	traveler_name.add_theme_font_size_override("font_size", 12)
	traveler_panel.add_child(traveler_name)

	var traveler_need := Label.new()
	traveler_need.text = "Needs: " + travelers[0]["need"]
	traveler_need.position = Vector2(0, 25)
	traveler_need.add_theme_font_size_override("font_size", 12)
	traveler_panel.add_child(traveler_need)

	var traveler_icon := Label.new()
	traveler_icon.text = travelers[0]["icon"]
	traveler_icon.position = Vector2(150, 10)
	traveler_icon.add_theme_font_size_override("font_size", 24)
	traveler_panel.add_child(traveler_icon)

	var gifts_container := HBoxContainer.new()
	gifts_container.position = Vector2(250, 100)
	gifts_container.add_theme_constant_override("separation", 10)
	root.add_child(gifts_container)

	var gift_buttons: Array[Button] = []
	for gift in gifts:
		var btn := Button.new()
		btn.text = gift
		btn.custom_minimum_size = Vector2(50, 50)
		btn.add_theme_font_size_override("font_size", 20)
		gifts_container.add_child(btn)
		gift_buttons.append(btn)

	var progress_bar := ProgressBar.new()
	progress_bar.max_value = goal_matches
	progress_bar.value = 0
	progress_bar.custom_minimum_size = Vector2(200, 20)
	progress_bar.position = Vector2(160, 10)
	root.add_child(progress_bar)

	var timer_bar := ProgressBar.new()
	timer_bar.max_value = time_limit
	timer_bar.value = time_limit
	timer_bar.custom_minimum_size = Vector2(200, 20)
	timer_bar.position = Vector2(160, 35)
	root.add_child(timer_bar)

	var status_lbl := Label.new()
	status_lbl.position = Vector2(20, 200)
	status_lbl.add_theme_font_size_override("font_size", 14)
	root.add_child(status_lbl)

	# Game logic
	var time_left := time_limit
	var game_active := true

	var check_match := func(selected_gift: String) -> void:
		if not game_active:
			return

		var current_need: String = travelers[current_traveler]["need"] as String
		var correct_gift: String = ""
		match current_need:
			"Food": correct_gift = "🍞"
			"Shelter": correct_gift = "🏠"
			"Water": correct_gift = "💧"
			"Guidance": correct_gift = "🗺️"
			"Healing": correct_gift = "💊"

		if selected_gift == correct_gift:
			matches_made += 1
			progress_bar.value = matches_made
			status_lbl.text = "✅ Well done! Hospitality shown."
			AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")

			if matches_made >= goal_matches:
				game_active = false
				result["success"] = true
				on_minigame_complete(result)
				return

			# Next traveler
			current_traveler = (current_traveler + 1) % travelers.size()
			traveler_name.text = travelers[current_traveler]["name"]
			traveler_need.text = "Needs: " + travelers[current_traveler]["need"]
			traveler_icon.text = travelers[current_traveler]["icon"]
		else:
			status_lbl.text = "❌ That's not what they need. Try again."
			AudioManager.play_sfx("res://assets/audio/sfx/click.wav")

	var update_game := func(delta: float) -> void:
		if not game_active:
			return

		time_left -= delta
		timer_bar.value = time_left

		if time_left <= 0:
			game_active = false
			result["success"] = matches_made >= goal_matches
			on_minigame_complete(result)

	# Connect buttons
	for i in range(gift_buttons.size()):
		var gift: String = gifts[i]
		gift_buttons[i].pressed.connect(func(): check_match.call(gift))

	var timer := Timer.new()
	timer.wait_time = 0.016  # ~60 FPS
	timer.timeout.connect(func(): update_game.call(0.016))
	root.add_child(timer)
	timer.start()

	return root

# ─────────────────────────────────────────────────────────────────────────────
# GROWTH MINI-GAME (Joseph)
# Tend garden by watering plants and removing weeds
# ─────────────────────────────────────────────────────────────────────────────
func build_growth_minigame(parent: Node, prompt: String, time_limit: float) -> Control:
	var result := {"success": false}
	var root := Control.new()
	root.custom_minimum_size = Vector2(520, 300)
	parent.add_child(root)

	# Garden state
	var plants := []  # Array of plant dicts: {pos, growth, watered, weeded}
	var weeds := []   # Array of weed dicts: {pos, size}
	var growth_score := 0
	var goal_growth := 8

	# Initialize garden
	for i in range(6):
		plants.append({
			"pos": Vector2(80 + i * 70, 180),
			"growth": 0.0,
			"watered": false,
			"weeded": false
		})

	for i in range(4):
		weeds.append({
			"pos": Vector2(120 + i * 100, 200),
			"size": 1.0
		})

	# UI elements
	var prompt_lbl := Label.new()
	prompt_lbl.text = prompt
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.add_theme_font_size_override("font_size", 14)
	root.add_child(prompt_lbl)

	var garden_bg := ColorRect.new()
	garden_bg.color = Color(0.4, 0.6, 0.3, 1)  # Green soil
	garden_bg.custom_minimum_size = Vector2(480, 150)
	garden_bg.position = Vector2(20, 120)
	root.add_child(garden_bg)

	var plant_rects: Array[ColorRect] = []
	for plant in plants:
		var rect := ColorRect.new()
		rect.color = Color(0.2, 0.5, 0.2, 1)  # Dark green stem
		rect.custom_minimum_size = Vector2(8, 20)
		rect.position = plant["pos"]
		root.add_child(rect)
		plant_rects.append(rect)

	var weed_rects: Array[ColorRect] = []
	for weed in weeds:
		var rect := ColorRect.new()
		rect.color = Color(0.6, 0.3, 0.1, 1)  # Brown weed
		rect.custom_minimum_size = Vector2(12, 12)
		rect.position = weed["pos"]
		root.add_child(rect)
		weed_rects.append(rect)

	var water_btn := Button.new()
	water_btn.text = "💧 Water"
	water_btn.custom_minimum_size = Vector2(80, 50)
	water_btn.position = Vector2(50, 50)
	root.add_child(water_btn)

	var weed_btn := Button.new()
	weed_btn.text = "✂️ Weed"
	weed_btn.custom_minimum_size = Vector2(80, 50)
	weed_btn.position = Vector2(150, 50)
	root.add_child(weed_btn)

	var progress_bar := ProgressBar.new()
	progress_bar.max_value = goal_growth
	progress_bar.value = 0
	progress_bar.custom_minimum_size = Vector2(200, 20)
	progress_bar.position = Vector2(160, 10)
	root.add_child(progress_bar)

	var timer_bar := ProgressBar.new()
	timer_bar.max_value = time_limit
	timer_bar.value = time_limit
	timer_bar.custom_minimum_size = Vector2(200, 20)
	timer_bar.position = Vector2(160, 35)
	root.add_child(timer_bar)

	var status_lbl := Label.new()
	status_lbl.position = Vector2(250, 50)
	status_lbl.add_theme_font_size_override("font_size", 12)
	root.add_child(status_lbl)

	# Game logic
	var time_left := time_limit
	var game_active := true
	var selected_action := ""  # "water" or "weed"

	var perform_action := func(action: String, target_pos: Vector2) -> void:
		if not game_active:
			return

		if action == "water":
			for i in range(plants.size()):
				var plant: Dictionary = plants[i]
				if (plant["pos"] as Vector2).distance_to(target_pos) < 30:
					if not plant["watered"]:
						plant["watered"] = true
						status_lbl.text = "💧 Plant watered!"
						AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
						break
		elif action == "weed":
			for i in range(weeds.size()):
				var weed: Dictionary = weeds[i]
				if (weed["pos"] as Vector2).distance_to(target_pos) < 20:
					weeds.remove_at(i)
					weed_rects[i].queue_free()
					weed_rects.remove_at(i)
					status_lbl.text = "✂️ Weed removed!"
					AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
					break

	var update_game := func(delta: float) -> void:
		if not game_active:
			return

		time_left -= delta
		timer_bar.value = time_left

		if time_left <= 0:
			game_active = false
			result["success"] = growth_score >= goal_growth
			on_minigame_complete(result)
			return

		# Grow plants that are watered and weeded
		for i in range(plants.size()):
			var plant: Dictionary = plants[i]
			if plant["watered"] and plant["weeded"]:
				plant["growth"] += delta * 0.5
				plant_rects[i].size.y = 20 + plant["growth"] * 30
				if plant["growth"] >= 1.0 and not plant.get("counted", false):
					plant["counted"] = true
					growth_score += 1
					progress_bar.value = growth_score
					if growth_score >= goal_growth:
						game_active = false
						result["success"] = true
						on_minigame_complete(result)
						return

		# Grow weeds
		for i in range(weeds.size()):
			var weed: Dictionary = weeds[i]
			weed["size"] += delta * 0.2
			weed_rects[i].size = Vector2(12 + weed["size"] * 8, 12 + weed["size"] * 8)

	# Connect buttons
	water_btn.pressed.connect(func(): selected_action = "water")
	weed_btn.pressed.connect(func(): selected_action = "weed")

	# Click handling for garden
	var garden_click := func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and selected_action != "":
			perform_action.call(selected_action, event.position - garden_bg.position)
			selected_action = ""

	garden_bg.gui_input.connect(garden_click)

	var timer := Timer.new()
	timer.wait_time = 0.016  # ~60 FPS
	timer.timeout.connect(func(): update_game.call(0.016))
	root.add_child(timer)
	timer.start()

	return root

# ─────────────────────────────────────────────────────────────────────────────
# FORGIVENESS MINI-GAME (Joseph)
# Choose between holding onto anger or extending forgiveness
# ─────────────────────────────────────────────────────────────────────────────
func build_forgiveness_minigame(parent: Node, prompt: String, time_limit: float) -> Control:
	var result := {"success": false}
	var root := Control.new()
	root.custom_minimum_size = Vector2(520, 300)
	parent.add_child(root)

	# Story elements
	var story_parts := [
		"Your brother wronged you deeply. He took what was yours and caused you great pain.",
		"Years later, you have power over him. He stands before you, vulnerable and afraid.",
		"The path of anger calls: 'Punish him! Make him pay for what he did!'",
		"The path of forgiveness whispers: 'Show mercy. God has been merciful to you.'",
		"What will you choose?"
	]

	var current_part := 0
	var choices_made := 0
	var forgiveness_score := 0

	# UI elements
	var prompt_lbl := Label.new()
	prompt_lbl.text = prompt
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.add_theme_font_size_override("font_size", 14)
	root.add_child(prompt_lbl)

	var story_panel := _make_panel(Color(0.9, 0.8, 0.7, 1), Vector2(480, 120))
	story_panel.position = Vector2(20, 40)
	root.add_child(story_panel)

	var story_text := Label.new()
	story_text.text = story_parts[0]
	story_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_text.custom_minimum_size = Vector2(460, 100)
	story_text.add_theme_font_size_override("font_size", 12)
	story_panel.add_child(story_text)

	var choice_container := HBoxContainer.new()
	choice_container.position = Vector2(40, 180)
	choice_container.add_theme_constant_override("separation", 20)
	root.add_child(choice_container)

	var anger_btn := Button.new()
	anger_btn.text = "🔥 Hold Anger"
	anger_btn.custom_minimum_size = Vector2(120, 60)
	anger_btn.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2, 1))
	choice_container.add_child(anger_btn)

	var forgive_btn := Button.new()
	forgive_btn.text = "💙 Forgive"
	forgive_btn.custom_minimum_size = Vector2(120, 60)
	forgive_btn.add_theme_color_override("font_color", Color(0.2, 0.4, 0.8, 1))
	choice_container.add_child(forgive_btn)

	var progress_bar := ProgressBar.new()
	progress_bar.max_value = 3
	progress_bar.value = 0
	progress_bar.custom_minimum_size = Vector2(200, 20)
	progress_bar.position = Vector2(160, 10)
	root.add_child(progress_bar)

	var timer_bar := ProgressBar.new()
	timer_bar.max_value = time_limit
	timer_bar.value = time_limit
	timer_bar.custom_minimum_size = Vector2(200, 20)
	timer_bar.position = Vector2(160, 35)
	root.add_child(timer_bar)

	var heart_icon := Label.new()
	heart_icon.text = "💔"
	heart_icon.position = Vector2(20, 250)
	heart_icon.add_theme_font_size_override("font_size", 24)
	root.add_child(heart_icon)

	# Game logic
	var time_left := time_limit
	var game_active := true

	var make_choice := func(forgiving: bool) -> void:
		if not game_active:
			return

		choices_made += 1
		progress_bar.value = choices_made

		if forgiving:
			forgiveness_score += 1
			story_text.text = "You choose mercy. The burden lifts from your heart. 💙"
			heart_icon.text = "💙"
			AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
		else:
			story_text.text = "You choose anger. The wound festers in your soul. 🔥"
			heart_icon.text = "💔"
			AudioManager.play_sfx("res://assets/audio/sfx/click.wav")

		# Next scenario
		await get_tree().create_timer(2.0).timeout

		if choices_made >= 3:
			game_active = false
			result["success"] = forgiveness_score >= 2
			on_minigame_complete(result)
			return

		current_part = (current_part + 1) % story_parts.size()
		story_text.text = story_parts[current_part]

	var update_game := func(delta: float) -> void:
		if not game_active:
			return

		time_left -= delta
		timer_bar.value = time_left

		if time_left <= 0:
			game_active = false
			result["success"] = forgiveness_score >= 2
			on_minigame_complete(result)

	# Connect buttons
	anger_btn.pressed.connect(func(): make_choice.call(false))
	forgive_btn.pressed.connect(func(): make_choice.call(true))

	var timer := Timer.new()
	timer.wait_time = 0.016  # ~60 FPS
	timer.timeout.connect(func(): update_game.call(0.016))
	root.add_child(timer)
	timer.start()

	return root

# ─────────────────────────────────────────────────────────────────────────────
# PRECISION MINI-GAME (Benjamin)
# Hit targets with precision by clicking in the exact center
# ─────────────────────────────────────────────────────────────────────────────
func build_precision_minigame(parent: Node, prompt: String, time_limit: float) -> Control:
	var result := {"success": false}
	var root := Control.new()
	root.custom_minimum_size = Vector2(520, 300)
	parent.add_child(root)

	# Target data
	var targets := []  # Array of target dicts: {pos, hit, center_pos}
	var targets_hit := 0
	var goal_hits := 6

	# Initialize targets
	for i in range(8):
		var pos := Vector2(100 + (i % 4) * 100, 120 + (i / 4) * 100)
		targets.append({
			"pos": pos,
			"hit": false,
			"center_pos": pos + Vector2(20, 20)  # Center of 40x40 target
		})

	# UI elements
	var prompt_lbl := Label.new()
	prompt_lbl.text = prompt
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.add_theme_font_size_override("font_size", 14)
	root.add_child(prompt_lbl)

	var target_rects: Array[ColorRect] = []
	for target in targets:
		var rect := ColorRect.new()
		rect.color = Color(0.8, 0.2, 0.2, 1)  # Red target
		rect.custom_minimum_size = Vector2(40, 40)
		rect.position = target["pos"]
		root.add_child(rect)
		target_rects.append(rect)

		# Center dot
		var center := ColorRect.new()
		center.color = Color(1, 1, 1, 1)  # White center
		center.custom_minimum_size = Vector2(4, 4)
		center.position = target["center_pos"] - Vector2(2, 2)
		root.add_child(center)

	var progress_bar := ProgressBar.new()
	progress_bar.max_value = goal_hits
	progress_bar.value = 0
	progress_bar.custom_minimum_size = Vector2(200, 20)
	progress_bar.position = Vector2(160, 10)
	root.add_child(progress_bar)

	var timer_bar := ProgressBar.new()
	timer_bar.max_value = time_limit
	timer_bar.value = time_limit
	timer_bar.custom_minimum_size = Vector2(200, 20)
	timer_bar.position = Vector2(160, 35)
	root.add_child(timer_bar)

	var status_lbl := Label.new()
	status_lbl.position = Vector2(20, 270)
	status_lbl.add_theme_font_size_override("font_size", 12)
	root.add_child(status_lbl)

	# Game logic
	var time_left := time_limit
	var game_active := true

	var check_hit := func(click_pos: Vector2) -> void:
		if not game_active:
			return

		for i in range(targets.size()):
			var target: Dictionary = targets[i]
			if target["hit"]:
				continue

			var distance: float = (target["center_pos"] as Vector2).distance_to(click_pos)
			if distance <= 8:  # Within 8 pixels of center
				target["hit"] = true
				targets_hit += 1
				progress_bar.value = targets_hit
				target_rects[i].color = Color(0.2, 0.8, 0.2, 1)  # Green when hit
				status_lbl.text = "🎯 Perfect hit! +" + str(targets_hit)
				AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")

				if targets_hit >= goal_hits:
					game_active = false
					result["success"] = true
					on_minigame_complete(result)
					return
			elif distance <= 25:  # Close but not center
				status_lbl.text = "📍 Close! Aim for the center."
				AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
			else:
				status_lbl.text = "❌ Too far from center."

	var update_game := func(delta: float) -> void:
		if not game_active:
			return

		time_left -= delta
		timer_bar.value = time_left

		if time_left <= 0:
			game_active = false
			result["success"] = targets_hit >= goal_hits
			on_minigame_complete(result)

	# Click handling
	var click_handler := func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			check_hit.call(event.position)

	root.gui_input.connect(click_handler)

	var timer := Timer.new()
	timer.wait_time = 0.016  # ~60 FPS
	timer.timeout.connect(func(): update_game.call(0.016))
	root.add_child(timer)
	timer.start()

	return root

# ─────────────────────────────────────────────────────────────────────────────
# PROTECTION MINI-GAME (Benjamin)
# Block threats from reaching protected characters
# ─────────────────────────────────────────────────────────────────────────────
func build_protection_minigame(parent: Node, prompt: String, time_limit: float) -> Control:
	var result := {"success": false}
	var root := Control.new()
	root.custom_minimum_size = Vector2(520, 300)
	parent.add_child(root)

	# Game objects
	var protector_pos := Vector2(260, 250)  # Bottom center
	var protected_ones := [
		{"pos": Vector2(200, 180), "safe": true},
		{"pos": Vector2(320, 180), "safe": true}
	]
	var threats := []  # Array of threat dicts: {pos, speed, direction}
	var threats_blocked := 0
	var max_threats := 8

	# UI elements
	var prompt_lbl := Label.new()
	prompt_lbl.text = prompt
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.add_theme_font_size_override("font_size", 14)
	root.add_child(prompt_lbl)

	var protector_rect := ColorRect.new()
	protector_rect.color = Color(0.2, 0.4, 0.8, 1)  # Blue protector
	protector_rect.custom_minimum_size = Vector2(20, 20)
	protector_rect.position = protector_pos
	root.add_child(protector_rect)

	var protected_rects: Array[ColorRect] = []
	for protected in protected_ones:
		var rect := ColorRect.new()
		rect.color = Color(0.8, 0.6, 0.2, 1)  # Gold protected ones
		rect.custom_minimum_size = Vector2(15, 15)
		rect.position = protected["pos"]
		root.add_child(rect)
		protected_rects.append(rect)

	var threat_rects: Array[ColorRect] = []

	var move_left_btn := Button.new()
	move_left_btn.text = "⬅️"
	move_left_btn.custom_minimum_size = Vector2(60, 60)
	move_left_btn.position = Vector2(10, 200)
	root.add_child(move_left_btn)

	var move_right_btn := Button.new()
	move_right_btn.text = "➡️"
	move_right_btn.custom_minimum_size = Vector2(60, 60)
	move_right_btn.position = Vector2(450, 200)
	root.add_child(move_right_btn)

	var progress_bar := ProgressBar.new()
	progress_bar.max_value = max_threats
	progress_bar.value = 0
	progress_bar.custom_minimum_size = Vector2(200, 20)
	progress_bar.position = Vector2(160, 10)
	root.add_child(progress_bar)

	var timer_bar := ProgressBar.new()
	timer_bar.max_value = time_limit
	timer_bar.value = time_limit
	timer_bar.custom_minimum_size = Vector2(200, 20)
	timer_bar.position = Vector2(160, 35)
	root.add_child(timer_bar)

	var status_lbl := Label.new()
	status_lbl.position = Vector2(20, 270)
	status_lbl.add_theme_font_size_override("font_size", 12)
	root.add_child(status_lbl)

	# Game logic
	var time_left := time_limit
	var game_active := true
	var threat_spawn_timer := 0.0

	var spawn_threat := func() -> void:
		var threat := {
			"pos": Vector2(randf_range(50, 470), -10),
			"speed": randf_range(1.5, 3.0),
			"direction": Vector2(randf_range(-0.5, 0.5), 1).normalized()
		}
		threats.append(threat)

		var rect := ColorRect.new()
		rect.color = Color(0.8, 0.2, 0.2, 1)  # Red threat
		rect.custom_minimum_size = Vector2(12, 12)
		rect.position = threat["pos"]
		root.add_child(rect)
		threat_rects.append(rect)

	var update_game := func(delta: float) -> void:
		if not game_active:
			return

		time_left -= delta
		timer_bar.value = time_left

		if time_left <= 0:
			game_active = false
			result["success"] = threats_blocked >= max_threats
			on_minigame_complete(result)
			return

		# Spawn threats
		threat_spawn_timer += delta
		if threat_spawn_timer >= 2.0 and threats.size() < 5:
			threat_spawn_timer = 0.0
			spawn_threat.call()

		# Move protector
		if move_left_btn.button_pressed:
			protector_pos.x -= 3.0
		if move_right_btn.button_pressed:
			protector_pos.x += 3.0
		protector_pos.x = clamp(protector_pos.x, 20, 480)
		protector_rect.position = protector_pos

		# Move threats
		for i in range(threats.size() - 1, -1, -1):
			var threat: Dictionary = threats[i]
			threat["pos"] += threat["direction"] * threat["speed"]
			threat_rects[i].position = threat["pos"]

			# Check if blocked by protector
			if protector_rect.get_rect().intersects(threat_rects[i].get_rect().grow(-2)):
				threats.remove_at(i)
				threat_rects[i].queue_free()
				threat_rects.remove_at(i)
				threats_blocked += 1
				progress_bar.value = threats_blocked
				status_lbl.text = "🛡️ Threat blocked! +" + str(threats_blocked)
				AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")

				if threats_blocked >= max_threats:
					game_active = false
					result["success"] = true
					on_minigame_complete(result)
					return
				continue

			# Check if reached protected ones
			for protected in protected_ones:
				if threat["pos"].distance_to(protected["pos"]) < 20:
					protected["safe"] = false
					game_active = false
					result["success"] = false
					status_lbl.text = "💔 Protected one harmed!"
					AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
					on_minigame_complete(result)
					return

			# Remove threats that go off screen
			if threat["pos"].y > 320:
				threats.remove_at(i)
				threat_rects[i].queue_free()
				threat_rects.remove_at(i)

	var timer := Timer.new()
	timer.wait_time = 0.016  # ~60 FPS
	timer.timeout.connect(func(): update_game.call(0.016))
	root.add_child(timer)
	timer.start()

	return root

# ── Override these in the subclass for custom reactions ──────────────────────
func on_minigame_complete(_result: Dictionary) -> void:
	pass

func on_minigame_timeout(_result: Dictionary) -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/timeout_gentle.wav")

# ─────────────────────────────────────────────────────────────────────────────
# FADE HELPERS
# ─────────────────────────────────────────────────────────────────────────────
func _fade_in() -> void:
	_fade_rect.color = Color(0, 0, 0, 1)
	_fade_rect.visible = true
	var tw := create_tween()
	tw.tween_property(_fade_rect, "color:a", 0.0, 0.7)
	await tw.finished
	_fade_rect.visible = false

func _fade_out_and_change(target: String) -> void:
	_fade_rect.visible = true
	var tw := create_tween()
	tw.tween_property(_fade_rect, "color:a", 1.0, 0.6)
	await tw.finished
	var result := get_tree().change_scene_to_file(target)
	if result != OK:
		push_error("[QuestBase] Scene change failed: %s  err=%d" % [target, result])

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────
func _make_panel(bg: Color, _min_size: Vector2) -> PanelContainer:
	var pc := PanelContainer.new()
	var ss := StyleBoxFlat.new()
	ss.bg_color = bg
	ss.set_corner_radius_all(14)
	ss.set_expand_margin_all(8.0)
	pc.add_theme_stylebox_override("panel", ss)
	return pc
