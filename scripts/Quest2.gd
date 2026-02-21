extends "res://scripts/WorldBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# Quest2.gd  –  World 2: Golden Hillside  (Tribe of Judah)
#
# WORLD LAYOUT (top-down, free exploration):
#   [Start Meadow]   Golden grass; Elder Shelah under olive tree.
#   [Lion Rock]      Rock formation east; praise stones scattered.
#   [Cave Passage]   Under Lion Rock; Chest "Revelation".
#   [Hillside Crest] High ground north; Chest "Psalm 34".
#   [Valley Floor]   Open praise ground south; the main ritual.
#   [Sunrise Ledge]  West cliff; Chest "Matthew" + view point.
#   [Trade Path]     South trail; Wandering Trader NPC.
#
# SIDE QUESTS (2):
#   judah_praise_stones  — collect 5 glowing praise stones
#   judah_merchants      — share bread with 3 traders
#
# HIDDEN CHESTS (4):
#   judah_chest_rev    Revelation 5:5
#   judah_chest_psalm  Psalm 34:1
#   judah_chest_matt   Matthew 5:9
#   judah_chest_song   Song of Solomon 2:1
#
# MAIN QUEST:
#   Speak with Elder Shelah → Praise Roar rhythm tap →
#   Bubble hold-fill → Verse (Psalm 100:1-2) → Emerald stone
#
# "Shout for joy to the LORD, all the earth." – Psalm 100:1
# ─────────────────────────────────────────────────────────────────────────────

var _quest_state: int = 0  # 0: not started, 1: roar, 2: done

func _ready() -> void:
	tribe_key    = "judah"
	quest_id     = "judah_main"
	next_scene   = "res://scenes/Quest3.tscn"
	world_name   = "Golden Hillside"
	# Revelation 5:5 – the Lion of the tribe of Judah
	music_path   = "res://assets/audio/music/lion_of_the_dawn.wav"
	world_bounds = Rect2(-900, -700, 1800, 1400)
	super._ready()


func on_world_ready() -> void:
	super.on_world_ready()  # 3D sky + directional light – Psalm 19:1
	_build_terrain()
	_place_npcs()
	_place_chests()
	_place_side_quest_objects()
	_show_world_intro()

# ─────────────────────────────────────────────────────────────────────────────
# TERRAIN
# "The earth is the LORD's, and everything in it" – Psalm 24:1
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# "The sceptre will not depart from Judah" – Genesis 49:10
	# Golden grass plateau (player start)
	_draw_tile(Rect2(-420, -100, 680, 300), Color(0.72, 0.62, 0.22, 1))
	# Rolling hillside base
	_draw_tile(Rect2(-900, 180, 1800, 540), Color(0.58, 0.46, 0.20, 1))
	# Lion Rock formation
	_draw_tile(Rect2(260, -480, 300, 380),  Color(0.54, 0.46, 0.36, 1))
	_draw_tile(Rect2(310, -600, 180, 140),  Color(0.60, 0.52, 0.38, 1))  # rock top
	# Cave passage under lion rock
	_draw_tile(Rect2(220, -220, 160, 120),  Color(0.10, 0.08, 0.06, 1))
	# Hillside crest
	_draw_tile(Rect2(-260, -680, 480, 80),  Color(0.66, 0.58, 0.30, 1))
	# Sunrise ledge (west)
	_draw_tile(Rect2(-880, -560, 200, 360), Color(0.62, 0.50, 0.28, 1))
	# Valley floor (south - praise ground)
	_draw_tile(Rect2(-600, 80, 700, 120),   Color(0.68, 0.58, 0.28, 1))
	# Trade path (south)
	_draw_tile(Rect2(-400, 180, 820, 30),   Color(0.52, 0.44, 0.24, 0.7))
	# Stream (north-east)
	_draw_tile(Rect2(480, -360, 28, 260),   Color(0.36, 0.60, 0.82, 0.70))
	# Boundary walls
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
	mesh_instance.rotation_degrees = Vector3(-90, 0, 0)  # Rotate to horizontal
	add_child(mesh_instance)

func _draw_wall(r: Rect2) -> void:
	var sb := StaticBody3D.new()
	sb.position = Vector3(r.position.x + r.size.x / 2, r.size.y / 2, r.position.y + r.size.y / 2)
	var cs3d := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(r.size.x, r.size.y, 1)  # Assuming thin wall
	cs3d.shape = box
	sb.add_child(cs3d)
	add_child(sb)

# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder Shelah — main quest giver
	_spawn_npc(
		Vector3(-80, 0, -30),
		"Elder Shelah",
		[
			{"name": "Elder Shelah",
			 "text": "Shalom, shalom! You stand on the hillside of Judah. At dawn the tribe gathers here — not in silence, but in praise. The Emerald stone rests beyond the lion's path, my child."},
			{"name": "Elder Shelah",
			 "text": "Judah means 'praise'. When the people of Israel marched, Judah led — not with swords, but with song. Bold praise opens the way."},
			{"name": "You", "text": "Please, Elder Shelah — what must I do?"},
			{"name": "Elder Shelah",
			 "text": "Listen for the lion's heartbeat. When it pulses — roar with it. Tap boldly and without hesitation."},
			{"name": "Elder Shelah",
			 "text": "God sees your heart. Are you ready?",
			 "callback": Callable(self, "_start_main_quest_sequence")}
		],
		[{"name": "Elder Shelah",
		  "text": "The lion roars at dawn — praise fills the hillside from end to end. \"Shouting for joy to the LORD\" — Psalm 100:1."}]
	)

	# Praise Leader — judah_praise_stones side quest
	_spawn_npc(
		Vector3(100, 0, 100),
		"Praise Leader Adah",
		[
			{"name": "Adah",
			 "text": "Please, traveller — five glowing praise stones have rolled off the pathway. Without them our sunrise circle is incomplete. Can you help?"},
			{"name": "Adah",
			 "text": "Each stone catches the light of dawn. Look near the rocks and between the tall grasses.",
			 "callback": Callable(func():
				SideQuestManager.give_quest("judah_praise_stones")
				update_quest_log("Side Quest: Find 5\npraise stones")
			)}
		],
		[{"name": "Adah",
		  "text": "Thank you, thank you! The circle shines again. 'Praise him, all his angels' — Psalm 148:2."}],
		"judah_praise_stones"
	)

	# Wandering Trader — judah_merchants side quest
	_spawn_npc(
		Vector3(-300, 0, 220),
		"Wandering Trader Ezra",
		[
			{"name": "Ezra",
			 "text": "Shalom! Long journey — very hungry. Two others are resting down the path. If you find bread to share between us, we would bless you."},
			{"name": "Ezra",
			 "text": "Judah's tribe has always been generous with their harvest.",
			 "callback": Callable(func():
				SideQuestManager.give_quest("judah_merchants")
				update_quest_log("Side Quest: Share bread\nwith 3 traders")
			)}
		],
		[{"name": "Ezra",
		  "text": "God multiplies the bread shared in love. 'He who gives to the poor lends to the LORD' — Proverbs 19:17."}],
		"judah_merchants"
	)

func _spawn_npc(pos: Vector3, npc_name: String, dialogue_lines: Array, repeat_lines: Array, give_side_quest: String = "") -> Area3D:
	var npc: Area3D = preload("res://scripts/NPC.gd").new()
	npc.position = pos
	npc.npc_name = npc_name
	npc.dialogue_lines = dialogue_lines
	npc.repeat_lines = repeat_lines
	npc.give_side_quest = give_side_quest
	# Add visual
	var body := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(0.8, 1.6, 0.8)
	body.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.6, 0.4, 1).darkened(0.15)
	body.material_override = material
	npc.add_child(body)
	var shape := CollisionShape3D.new()
	var cs := SphereShape3D.new()
	cs.radius = 0.5
	shape.shape = cs
	npc.add_child(shape)
	return npc

# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	_spawn_chest(Vector3(350, 0, -180), "judah_chest_rev",
		"verse", "Revelation 5:5", "Revelation 5:5",
		"See, the Lion of the tribe of Judah, the Root of David, has triumphed.")

	_spawn_chest(Vector3(-200, 0, -660), "judah_chest_psalm",
		"verse", "Psalm 34:1", "Psalm 34:1",
		"I will extol the LORD at all times; his praise will always be on my lips.")

	_spawn_chest(Vector3(-820, 0, -420), "judah_chest_matt",
		"verse", "Matthew 5:9", "Matthew 5:9",
		"Blessed are the peacemakers, for they will be called children of God.")

	_spawn_chest(Vector3(520, 0, 60), "judah_chest_song",
		"verse", "Song of Solomon 2:1", "Song of Solomon 2:1",
		"I am a rose of Sharon, a lily of the valleys.")

func _spawn_chest(pos: Vector3, cid: String, rtype: String, rid: String, rref: String, rtext: String) -> void:
	var c: Area3D = preload("res://scripts/TreasureChest.gd").new()
	c.position = pos
	c.chest_id = cid
	c.reward_type = rtype
	c.reward_id = rid
	c.reward_text = rtext
	c.starts_hidden = true
	var shape := CollisionShape3D.new()
	var cs := SphereShape3D.new()
	cs.radius = 0.5
	shape.shape = cs
	c.add_child(shape)
	c.chest_opened.connect(_on_chest_opened)
	add_child(c)

func _on_chest_opened(_cid: String) -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	update_quest_log("💛 Treasure found!")

# ─────────────────────────────────────────────────────────────────────────────
# SIDE QUEST COLLECTIBLES
# ─────────────────────────────────────────────────────────────────────────────
func _place_side_quest_objects() -> void:
	# Praise stones (5)
	var stone_positions := [
		Vector3(180, 0, -200), Vector3(380, 0, -80), Vector3(-80, 0, 140),
		Vector3(460, 0, -340), Vector3(-340, 0, -420)
	]
	for i: int in stone_positions.size():
		_sqitem(stone_positions[i], "✦", Color(1.0, 0.85, 0.2, 1), "judah_praise_stones",
			func(): SideQuestManager.collect_item("judah_praise_stones"))

	# Bread loaves (3)
	var bread_positions := [Vector3(-480, 0, 200), Vector3(-180, 0, 280), Vector3(120, 0, 220)]
	for bp: Vector3 in bread_positions:
		_sqitem(bp, "🍞", Color(0.86, 0.62, 0.28, 1), "judah_merchants",
			func(): SideQuestManager.collect_item("judah_merchants"))

func _sqitem(pos: Vector3, emoji: String, color: Color, quest_id: String, collect_func: Callable) -> void:
	var area := Area3D.new()
	area.position = pos
	area.monitoring = true
	area.monitorable = true
	var shape := CollisionShape3D.new()
	var cs := SphereShape3D.new()
	cs.radius = 0.4
	shape.shape = cs
	area.add_child(shape)
	var lbl := Label3D.new()
	lbl.text = emoji
	lbl.font_size = 22
	lbl.position = Vector3(-0.25, 0.5, 0)
	area.add_child(lbl)
	if Global.treasures_found.has(quest_id + "_" + str(pos)):
		area.visible = false
	# Inline interact script
	var sc := GDScript.new()
	sc.source_code = ("""
extends Area3D
var collect_func: Callable
func get_interaction_label() -> String: return "✦ Pick up"
func _ready() -> void:
	body_entered.connect(func(body):
		if body.is_in_group("player"):
			collect_func.call()
			queue_free()
	)
""")
	var script_instance = sc.new()
	script_instance.collect_func = collect_func
	area.set_script(script_instance)
	add_child(area)

# ─────────────────────────────────────────────────────────────────────────────
# WORLD INTRO
# ─────────────────────────────────────────────────────────────────────────────
func _show_world_intro() -> void:
	await get_tree().create_timer(1.0).timeout
	show_dialogue([
		{"name": "❝ Psalm 100:1 ❝",
		 "text": "Shout for joy to the LORD, all the earth. Worship the LORD with gladness; come before him with joyful songs."},
		{"name": "Golden Hillside",
		 "text": "Sunrise spills across Judah's hills. Elder Shelah waits under the great olive tree. Praise stones glow among the rocks — and traders rest on the south path."}
	])
	update_quest_log("Find Elder Shelah\nto begin your quest")

# ─────────────────────────────────────────────────────────────────────────────
# MAIN QUEST — PHASE 1: PRAISE ROAR (rhythm tap)
# "Make a joyful noise" – Psalm 100:1
# ─────────────────────────────────────────────────────────────────────────────
func _start_main_quest_sequence() -> void:
	_quest_state = 1
	_spawn_roar_minigame()

func _spawn_roar_minigame() -> void:
	build_rhythm_minigame(_mini_game_container, 0.8, 8, 6, "Roar with the lion's heartbeat — match the rhythm!")

func on_minigame_complete(result: Dictionary) -> void:
	if _quest_state == 1:
		_quest_state = 2
		show_verse_scroll("Psalm 100:1-2", "Shout for joy to the LORD, all the earth. Worship the LORD with gladness; come before him with joyful songs.")
		await get_tree().create_timer(2.0).timeout
		show_nature_fact()
		await get_tree().create_timer(2.0).timeout
		_collect_stone()

func on_minigame_timeout(result: Dictionary) -> void:
	if _quest_state == 1:
		show_dialogue([
			{"name": "Elder Shelah", "text": "The lion's roar echoes through the hills. Try again, my child — 'Shout for joy to the LORD' — Psalm 100:1."},
			{"name": "You", "text": "Please, Elder — I will roar with praise."}
		])
		await get_tree().create_timer(1.0).timeout
		_spawn_roar_minigame()

func _spawn_roar_minigame() -> void:
	var panel := PanelContainer.new()
	_ui_canvas.add_child(panel)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -300.0; panel.offset_right  = 300.0
	panel.offset_top  = -240.0; panel.offset_bottom = 240.0

	var sty := StyleBoxFlat.new()
	sty.bg_color = Color(0.08, 0.05, 0.01, 0.97)
	for corner: String in ["corner_radius_top_left","corner_radius_top_right",
			"corner_radius_bottom_left","corner_radius_bottom_right"]:
		sty.set(corner, 14)
	sty.border_color = Color(0.92, 0.68, 0.08, 1)
	for side: String in ["border_width_left","border_width_right","border_width_top","border_width_bottom"]:
		sty.set(side, 2)
	for margin: String in ["content_margin_left","content_margin_right","content_margin_top","content_margin_bottom"]:
		sty.set(margin, 14)
	panel.add_theme_stylebox_override("panel", sty)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	panel.add_child(vb)

	var title := Label.new()
	title.text = "🦁  The Lion's Heartbeat  🦁"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.modulate = Color(1.0, 0.85, 0.2, 1)
	vb.add_child(title)

	var prompt := Label.new()
	prompt.text = "Tap when the circle ROARS!\n(when it pulses big — tap boldly!)"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.add_theme_font_size_override("font_size", 16)
	vb.add_child(prompt)

	var c_cont := Control.new()
	c_cont.custom_minimum_size = Vector2(200, 110)
	c_cont.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vb.add_child(c_cont)

	var circle := ColorRect.new()
	circle.color    = Color(0.92, 0.62, 0.08, 0.65)
	circle.size     = Vector2(80, 80)
	circle.position = Vector2(60, 15)
	c_cont.add_child(circle)

	var roar_lbl := Label.new()
	roar_lbl.text = "🦁"
	roar_lbl.add_theme_font_size_override("font_size", 36)
	roar_lbl.position = Vector2(75, 18)
	c_cont.add_child(roar_lbl)

	var score_lbl := Label.new()
	var goal: int = 5 if Global.selected_avatar == "david_j" else 6
	score_lbl.text = "0 / %d roars" % goal
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_lbl.add_theme_font_size_override("font_size", 18)
	score_lbl.modulate = Color(1.0, 0.85, 0.2, 1)
	vb.add_child(score_lbl)

	var tap_btn := Button.new()
	tap_btn.text = "🦁  ROAR!"
	tap_btn.custom_minimum_size = Vector2(0, 60)
	tap_btn.add_theme_font_size_override("font_size", 22)
	vb.add_child(tap_btn)

	if _player: _player.set_physics_process(false)

	const BEAT_DUR  := 0.70
	const BEATS     := 12
	var hits: int   = 0
	var beat_i: int = 0
	var is_open: bool  = false
	var done: bool     = false

	var run_beat
	run_beat = func():
		if done or beat_i >= BEATS: return
		beat_i += 1
		is_open = true
		var tw_o := create_tween()
		tw_o.tween_property(circle, "size", Vector2(140, 140), 0.18).set_ease(Tween.EASE_OUT)
		tw_o.tween_property(circle, "modulate:a", 1.0, 0.18)
		tw_o.tween_interval(0.14)
		tw_o.tween_callback(func():
			is_open = false
			var tw_c := create_tween()
			tw_c.tween_property(circle, "size", Vector2(80, 80), 0.25).set_ease(Tween.EASE_IN)
			tw_c.tween_property(circle, "modulate:a", 0.65, 0.25)
		)
		get_tree().create_timer(BEAT_DUR).timeout.connect(run_beat, CONNECT_ONE_SHOT)
	run_beat.call()

	tap_btn.pressed.connect(func():
		if done: return
		if is_open:
			hits += 1
			score_lbl.text = "%d / %d roars" % [hits, goal]
			var fl := create_tween()
			fl.tween_property(roar_lbl, "modulate", Color(1.5, 1.2, 0.2, 1), 0.08)
			fl.tween_property(roar_lbl, "modulate", Color(1, 1, 1, 1), 0.15)
			if hits >= goal:
				done = true
				await get_tree().create_timer(0.4).timeout
				_ui_canvas.remove_child(panel); panel.queue_free()
				if _player: _player.set_physics_process(true)
				_on_roar_complete()
		else:
			var ms := create_tween()
			ms.tween_property(circle, "modulate", Color(1.5, 0.3, 0.1, 1), 0.07)
			ms.tween_property(circle, "modulate", Color(1, 1, 1, 1), 0.18)
	)

	get_tree().create_timer(BEAT_DUR * float(BEATS) + 1.2).timeout.connect(func():
		if done: return
		done = true
		_ui_canvas.remove_child(panel); panel.queue_free()
		if _player: _player.set_physics_process(true)
		if hits >= goal: _on_roar_complete()
		else:            _on_roar_timeout()
	, CONNECT_ONE_SHOT)

func _on_roar_complete() -> void:
	var en: String = _tribe_data.get("elder", "Elder Shelah") as String
	show_dialogue([
		{"name": en,
		 "text": "The whole hillside heard you! Now — hold the Praise button and let the sound grow until it fills the valley."},
		{"name": en,
		 "text": "\"Judah Roars — Reuben Climbs\" is the co-op gift. Your praise carries further than you know.",
		 "callback": Callable(self, "_spawn_bubble_minigame")}
	])

func _on_roar_timeout() -> void:
	var en: String = _tribe_data.get("elder", "Elder Shelah") as String
	show_dialogue([
		{"name": en,
		 "text": "Let's try again together. The lion roars on the beat — wait for the big pulse, then answer boldly. God is patient.",
		 "callback": Callable(self, "_spawn_roar_minigame")}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MAIN QUEST — PHASE 2: GROUP PRAISE BUBBLE (hold-button fill)
# "Praise him with all that is within me" – Psalm 103:1
# ─────────────────────────────────────────────────────────────────────────────
var _bubble_holding:    bool  = false
var _bubble_progress:   float = 0.0
var _bubble_done:       bool  = false
var _bubble_active:     bool  = false
var _bubble_fill_speed: float = 18.0
var _bubble_prog_bar:   ProgressBar = null
var _bubble_btn:        Button      = null

func _spawn_bubble_minigame() -> void:
	var panel := PanelContainer.new()
	_ui_canvas.add_child(panel)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -280.0; panel.offset_right  = 280.0
	panel.offset_top  = -200.0; panel.offset_bottom = 200.0

	var sty := StyleBoxFlat.new()
	sty.bg_color = Color(0.04, 0.07, 0.02, 0.97)
	for corner: String in ["corner_radius_top_left","corner_radius_top_right",
			"corner_radius_bottom_left","corner_radius_bottom_right"]:
		sty.set(corner, 14)
	sty.border_color = Color(0.4, 0.8, 0.2, 1)
	for side: String in ["border_width_left","border_width_right","border_width_top","border_width_bottom"]:
		sty.set(side, 2)
	for margin: String in ["content_margin_left","content_margin_right","content_margin_top","content_margin_bottom"]:
		sty.set(margin, 14)
	panel.add_theme_stylebox_override("panel", sty)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	panel.add_child(vb)

	var title := Label.new()
	title.text = "♪ Group Praise Bubble ♪"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.modulate = Color(0.7, 1.0, 0.4, 1)
	vb.add_child(title)

	var prompt := Label.new()
	prompt.text = "Hold the Praise button!\nKeep holding until the bubble fills the valley."
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.add_theme_font_size_override("font_size", 16)
	vb.add_child(prompt)

	_bubble_prog_bar = ProgressBar.new()
	_bubble_prog_bar.min_value = 0.0
	_bubble_prog_bar.max_value = 100.0
	_bubble_prog_bar.value     = 0.0
	_bubble_prog_bar.custom_minimum_size = Vector2(0, 36)
	vb.add_child(_bubble_prog_bar)

	_bubble_btn = Button.new()
	_bubble_btn.text = "♪  Praise!  ♪"
	_bubble_btn.custom_minimum_size = Vector2(0, 80)
	_bubble_btn.add_theme_font_size_override("font_size", 26)
	vb.add_child(_bubble_btn)

	_bubble_fill_speed = 22.0 if Global.selected_avatar == "abigail_j" else 18.0
	_bubble_holding  = false
	_bubble_progress = 0.0
	_bubble_done     = false
	_bubble_active   = true

	if _player: _player.set_physics_process(false)
	_bubble_btn.button_down.connect(func(): _bubble_holding = true)
	_bubble_btn.button_up.connect(func():   _bubble_holding = false)

	# Store panel reference for cleanup
	var _cleanup_panel := panel
	get_tree().create_timer(0.05).timeout.connect(func():
		_start_bubble_update(_cleanup_panel)
	, CONNECT_ONE_SHOT)

func _start_bubble_update(panel: PanelContainer) -> void:
	# Poll until done via a recurring timer
	var tick
	tick = func():
		if not _bubble_active or _bubble_done:
			return
		get_tree().create_timer(0.05).timeout.connect(tick, CONNECT_ONE_SHOT)
	get_tree().create_timer(0.05).timeout.connect(tick, CONNECT_ONE_SHOT)

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
		# Find and remove bubble panel
		for child in _ui_canvas.get_children():
			if child is PanelContainer:
				_ui_canvas.remove_child(child)
				child.queue_free()
		if _player: _player.set_physics_process(true)
		_on_bubble_complete()

func _on_bubble_complete() -> void:
	var en: String = _tribe_data.get("elder", "Elder Shelah") as String
	show_dialogue([{
		"name": en,
		"text": "God sees your heart! The praise bubble fills the valley — now, receive the word of Judah.",
		"callback": Callable(self, "_finish_quest")
	}])

# ─────────────────────────────────────────────────────────────────────────────
# FINISH
# ─────────────────────────────────────────────────────────────────────────────
func _finish_quest() -> void:
	show_verse_scroll(
		_tribe_data.get("quest_verse_ref", "Psalm 100:1-2") as String,
		_tribe_data.get("quest_verse", "") as String
	)

func _on_chest_opened(cid: String) -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/chest_open.wav")
	update_quest_log("Treasure found:\n" + cid.replace("judah_chest_", "").capitalize())

