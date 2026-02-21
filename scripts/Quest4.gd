extends "res://scripts/WorldBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# Quest4.gd  –  World 4: Eagle Plateau  (Tribe of Dan)
# Mini-game 1: Eagle Soar (hold/release altitude)
# Mini-game 2: Pattern Lock (ordered tap)
# "For the LORD gives wisdom; from his mouth come knowledge" – Proverbs 2:6
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key    = "dan"
	quest_id     = "dan_main"
	next_scene   = "res://scenes/Quest5.tscn"
	world_name   = "Eagle Plateau"
	# Genesis 49:17 – Dan shall be a serpent by the way, shrewd and alert
	music_path   = "res://assets/audio/music/caves_and_hills.wav"
	world_bounds = Rect2(-900, -700, 1800, 1400)
	super._ready()

func on_world_ready() -> void:
	super.on_world_ready()  # 3D sky + directional light – Psalm 19:1
	_build_terrain()
	_place_npcs()
	_place_chests()
	_show_world_intro()

# "They will soar on wings like eagles" – Isaiah 40:31
func _build_terrain() -> void:
	# "Dan will be a serpent by the roadside" – Genesis 49:17
	# Wide sky plateau
	_draw_tile(Rect2(-900, -700, 1800, 400),  Color(0.44, 0.62, 0.82, 0.50))  # sky
	# Ground rock plateau
	_draw_tile(Rect2(-800, -300, 1600, 800),  Color(0.52, 0.46, 0.36, 1))
	# Eagle perch outcrop (center-north)
	_draw_tile(Rect2(-120, -540, 240, 260),   Color(0.60, 0.52, 0.38, 1))
	_draw_tile(Rect2(-80,  -600, 160, 80),    Color(0.68, 0.58, 0.42, 1))  # top
	# Rock face with hidden pattern marks
	_draw_tile(Rect2(380,  -420, 300, 420),   Color(0.48, 0.40, 0.30, 1))
	# East riverbed
	_draw_tile(Rect2(680,  -100, 36, 320),    Color(0.36, 0.60, 0.82, 0.65))
	_draw_wall(Rect2(-920, -730, 20, 1480))
	_draw_wall(Rect2(900,  -730, 20, 1480))
	_draw_wall(Rect2(-920, -730, 1840, 20))
	_draw_wall(Rect2(-920,  730, 1840, 20))

func _draw_tile(r: Rect2, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(r.size.x, r.size.y)
	mesh_instance.mesh = plane
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.material_override = material
	mesh_instance.position = Vector3(r.position.x + r.size.x / 2, 0, r.position.y + r.size.y / 2)
	mesh_instance.rotation_degrees = Vector3(-90, 0, 0)
	add_child(mesh_instance)

func _draw_wall(r: Rect2) -> void:
	var sb := StaticBody3D.new()
	sb.position = Vector3(r.position.x + r.size.x / 2, r.size.y / 2, r.position.y + r.size.y / 2)
	var cs3d := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(r.size.x, r.size.y, 1)
	cs3d.shape = box
	sb.add_child(cs3d)
	add_child(sb)

func _place_npcs() -> void:
	var elder_name: String = _tribe_data.get("elder", "Elder Shuham") as String

	# Elder Shuham — main quest trigger
	var shuham := _spawn_npc(Vector3(-60, 0, 40), elder_name, "👴", Color("#2F4F4F"))
	shuham.dialogue_lines = [
		{"name": elder_name,
		 "text": "My child, shalom! Welcome to Eagle Plateau — land of Dan, the judge tribe. The Sapphire stone rests at the cliff's edge, blue as the sky."},
		{"name": elder_name,
		 "text": "Dan means 'judge'. They judged rightly, seeing what others missed. Wisdom comes from seeing clearly."},
		{"name": "You", "text": "Please, Elder " + elder_name.split(" ")[1] + " — what must I do?"},
		{"name": elder_name,
		 "text": "Soar with the eagle — hold to gain height, release to glide. Then unlock the pattern on the rock face."},
		{"name": elder_name,
		 "text": "God sees your heart. Are you ready?",
		 "callback": Callable(self, "_start_soar_mini")}
	]
	shuham.repeat_lines = [
		{"name": elder_name,
		 "text": "The eagle waits for your command. Soar high, my child."}
	]

func _spawn_npc(pos: Vector3, npc_name: String, emoji: String, color: Color) -> Area3D:
	var npc: Area3D = preload("res://scripts/NPC.gd").new()
	npc.position = pos
	npc.npc_name = npc_name
	# Add visual
	var body := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(0.8, 1.6, 0.8)
	body.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	body.material_override = material
	npc.add_child(body)
	var shape := CollisionShape3D.new()
	var cs := SphereShape3D.new()
	cs.radius = 0.5
	shape.shape = cs
	npc.add_child(shape)
	return npc

func _place_chests() -> void:
	_spawn_chest(Vector3(350, 0, -180), "dan_chest_proverbs",
		"verse", "", "Proverbs 2:6",
		"For the LORD gives wisdom; from his mouth come knowledge and understanding.")

func _spawn_chest(pos: Vector3, chest_id: String, reward_type: String, reward_id: String, reward_ref: String, reward_text: String) -> void:
	var chest: Area3D = preload("res://scripts/TreasureChest.gd").new()
	chest.position = pos
	chest.chest_id = chest_id
	chest.reward_type = reward_type
	chest.reward_id = reward_id
	chest.reward_text = reward_text
	add_child(chest)

func _show_world_intro() -> void:
	var elder: String = _tribe_data.get("elder", "Elder") as String
	show_dialogue([
		{"name": "❝ Proverbs 2:6 ❝",
		 "text": "For the LORD gives wisdom; from his mouth come knowledge and understanding."},
		{"name": "Eagle Plateau",
		 "text": "Eagles circle above the wide plateau. From here you can see for miles. " + elder + " waits at the eagle perch — still, patient, watching."}
	])
	update_quest_log("Find " + elder + "\nto begin your quest")

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
	var container: Control = _mini_game_container
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
	_mini_game_container.visible = false
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
	var container: Control = _mini_game_container
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
	_mini_game_container.visible = false
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
