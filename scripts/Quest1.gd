extends "res://scripts/WorldBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# Quest1.gd  –  World 1: Morning Cliffs  (Tribe of Reuben)
# ─────────────────────────────────────────────────────────────────────────────
#
# WORLD LAYOUT (top-down, free exploration):
#   [Start Plateau]  Player spawns on grass ledge; Elder Hanoch nearby.
#   [East Gorge]     Rocky stream – Lost Lamb #2, Herb #3.
#   [Cave Mouth]     Dark alcove – Herb #2, Lost Lamb #3, Chest "Faith".
#   [Watchtower]     Three unlit torches – side quest.
#   [High Ledge]     Cliff path – Chest "Eagle", Herb #4.
#   [Cliff Top]      Sardius stone – main quest climax.
#   [West Meadow]    Lost Lamb #1, Herb #1, Chest "Coin".
#   [Waterfall]      South-east – Lost Lamb #2b, Chest "River Stone".
#
# SIDE QUESTS  (3):
#   reuben_lost_lamb   — find 3 lambs
#   reuben_torch_light — light 3 torches east→centre→west
#   reuben_herbs       — collect 4 healing herbs
#
# HIDDEN CHESTS (4):
#   reuben_chest_faith   Hebrews 11:1
#   reuben_chest_eagle   Isaiah 40:31
#   reuben_chest_coin    Luke 15:8-9
#   reuben_chest_river   Isaiah 48:18
#
# MAIN QUEST:
#   Speak with Elder Hanoch → Ladder Climb tap-minigame →
#   Butterfly Rhythm minigame → Verse (Prov 3:5-6) →
#   Nature fact (butterfly) → Sardius stone collected
#
# "Trust in the LORD with all your heart" – Proverbs 3:5
# ─────────────────────────────────────────────────────────────────────────────

var _quest_state: int = 0  # 0: not started, 1: ladder, 2: butterfly, 3: done

func _ready() -> void:
	tribe_key    = "reuben"
	quest_id     = "reuben_main"
	next_scene   = "res://scenes/Quest2.tscn"
	world_name   = "Morning Cliffs"
	music_path   = "res://assets/audio/music/sacred_spark.wav"
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
# "He set the earth on its foundations" – Psalm 104:5
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# "He set the earth on its foundations" – Psalm 104:5
	# Grass plateau (player start)
	_draw_tile(Rect2(-360, -120, 560, 320), Color(0.38, 0.55, 0.28, 1), "grass")
	# Ground
	_draw_tile(Rect2(-900, 180, 1800, 540), Color(0.48, 0.40, 0.26, 1), "dirt")
	# Cliff face
	_draw_tile(Rect2(-110, -720, 230, 620), Color(0.54, 0.46, 0.36, 1), "cliff")
	# Cliff top ledge
	_draw_tile(Rect2(-220, -740, 420, 60),  Color(0.60, 0.52, 0.38, 1), "stone")
	# Cave mouth
	_draw_tile(Rect2(-640, -220, 240, 210), Color(0.14, 0.10, 0.08, 1), "cave")
	# Watchtower base
	_draw_tile(Rect2(340, -520, 140, 370),  Color(0.52, 0.46, 0.36, 1), "stone")
	# Stream
	_draw_tile(Rect2(190, -70, 32, 320),    Color(0.36, 0.60, 0.82, 0.72), "")
	# Waterfall
	_draw_tile(Rect2(440, 90, 80, 200),     Color(0.36, 0.60, 0.82, 0.72), "")
	# West meadow
	_draw_tile(Rect2(-900, -100, 400, 280), Color(0.34, 0.48, 0.24, 1), "grass")

	# Boundary walls
	_draw_wall(Rect2(-920, -730, 20, 1480))
	_draw_wall(Rect2(910, -730, 20, 1480))
	_draw_wall(Rect2(-920, -730, 1850, 20))
	_draw_wall(Rect2(-920, 740, 1850, 20))
	# _draw_tile and _draw_wall are inherited from WorldBase — no override needed
	# WorldBase version: PlaneMesh with noise colour variation, collision + texture lookup
	# WorldBase _draw_wall: BoxMesh 30 units tall, StaticBody3D collision — Isaiah 26:1

# ─────────────────────────────────────────────────────────────────────────────
# NPCS
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	var elder_name: String = _tribe_data.get("elder", "Elder Hanoch") as String

	# Elder Hanoch — main quest trigger
	var hanoch := _spawn_npc(Vector3(-60, 0, 40), "Elder Hanoch", "👴", Color("#C0392B"))
	hanoch.dialogue_lines = [
		{"name": elder_name,
		 "text": "My child, shalom! Welcome to Morning Cliffs — land of Reuben, the firstborn. The Sardius stone — ruby red like courage — rests at the very cliff top."},
		{"name": elder_name,
		 "text": "Reuben learnt that strength needs wisdom. 'Trust in the LORD with all your heart, and lean not on your own understanding.' – Proverbs 3:5"},
		{"name": "You",
		 "text": "Please, Elder Hanoch — I am ready. How do I reach the top?"},
		{"name": elder_name,
		 "text": "The ladder is carved into the cliff face — just north. But first, explore this land. Lost lambs need finding, torches need lighting, and a young girl needs herbs for her grandmother.",
		 "callback": Callable(self, "_start_main_quest_sequence")}
	]
	hanoch.repeat_lines = [
		{"name": elder_name,
		 "text": "Trust in the LORD, my child. He makes your paths straight — even up a rocky cliff."}
	]
	add_child(hanoch)

	# Shepherd Boy — lost lamb side quest
	var shepherd := _spawn_npc(Vector3(-300, 0, 130), "Shepherd Boy", "🧒", Color("#7A9A6A"))
	shepherd.dialogue_lines = [
		{"name": "Shepherd Boy",
		 "text": "My three lambs strayed while I slept. One ran east toward the stream, one hid in the cave, and one wanders in the west meadow. Please bring them home?"},
		{"name": "You",
		 "text": "'The LORD is my shepherd, I lack nothing.' – Psalm 23:1. He will guide me to them!"}
	]
	shepherd.repeat_lines = [{"name": "Shepherd Boy",
		 "text": "Have you found all three? They get so frightened alone…"}]
	shepherd.give_side_quest = "reuben_lost_lamb"
	add_child(shepherd)

	# Miriam — herb side quest
	var miriam := _spawn_npc(Vector3(250, 0, 90), "Miriam", "👧", Color("#A0522D"))
	miriam.dialogue_lines = [
		{"name": "Miriam",
		 "text": "Oh! I need four healing herbs for my grandmother's remedy. They grow near the north path, in the cave, by the stream, and on the high ledge. Could you help?"},
		{"name": "You",
		 "text": "'Their leaves are for healing.' – Ezekiel 47:12. Of course, Miriam!"}
	]
	miriam.repeat_lines = [{"name": "Miriam",
		 "text": "Any herbs yet? '…their leaves are for healing.' – Ezekiel 47:12"}]
	miriam.give_side_quest = "reuben_herbs"
	add_child(miriam)

	# Watchtower Guard — torch side quest
	var guard := _spawn_npc(Vector3(395, 0, -260), "Watchtower Guard", "🗿", Color("#8B6F47"))
	guard.dialogue_lines = [
		{"name": "Guard",
		 "text": "The three signal torches blew out in the wind! Light them east first, then centre, then west — order matters, or the signal is wrong."},
		{"name": "You",
		 "text": "'Let your light shine before others.' – Matthew 5:16. I will relight them!"}
	]
	guard.repeat_lines = [{"name": "Guard",
		 "text": "East, centre, west — that is the order. 'Let your light shine.' – Matthew 5:16"}]
	guard.give_side_quest = "reuben_torch_light"
	add_child(guard)

func _spawn_npc(pos: Vector3, npc_name: String, emoji: String, color: Color) -> Area3D:
	var npc: Area3D = preload("res://scripts/NPC.gd").new()
	npc.position = pos
	npc.npc_name = npc_name

	var body := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(0.8, 1.6, 0.8)
	body.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color.darkened(0.15)
	body.material_override = material

	var e := Label3D.new()
	e.text = emoji
	e.font_size = 28
	e.position = Vector3(-0.3, 0.5, 0)

	var n := Label3D.new()
	n.text = npc_name
	n.font_size = 11
	n.modulate = Color(1, 0.95, 0.78, 1)
	n.position = Vector3(-0.8, 0.8, 0)
	n.size = Vector2(1.6, 0.3)

	var shape := CollisionShape3D.new()
	var cs := SphereShape3D.new()
	cs.radius = 0.5
	shape.shape = cs

	npc.add_child(body)
	npc.add_child(e)
	npc.add_child(n)
	npc.add_child(shape)
	return npc

# ─────────────────────────────────────────────────────────────────────────────
# TREASURE CHESTS
# "The kingdom of heaven is like treasure hidden in a field" – Matthew 13:44
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	_spawn_chest(Vector3(-670, 0, 50),    "reuben_chest_faith", "✦ Ancient Scroll",
		"verse", "Hebrews 11:1",
		"Now faith is confidence in what we hope for and assurance about what we do not see.")
	_spawn_chest(Vector3(70, 0, -630),    "reuben_chest_eagle", "✦ Eagle's Feather",
		"verse", "Isaiah 40:31",
		"But those who hope in the LORD will renew their strength. They will soar on wings like eagles.")
	_spawn_chest(Vector3(-530, 0, -130),  "reuben_chest_coin",  "✦ Ancient Coin",
		"verse", "Luke 15:8-9",
		"Or suppose a woman has ten silver coins and loses one. Does she not light a lamp and search carefully until she finds it?")
	_spawn_chest(Vector3(450, 0, 160),    "reuben_chest_river", "✦ River Stone",
		"verse", "Isaiah 48:18",
		"If only you had paid attention to my commands, your peace would have been like a river.")

func _spawn_chest(pos: Vector3, cid: String, lbl: String,
			rtype: String, rid: String, rtext: String) -> void:
	var c: Area3D = preload("res://scripts/TreasureChest.gd").new()
	c.position    = pos
	c.chest_id    = cid
	c.chest_label = lbl
	c.reward_type = rtype
	c.reward_id   = rid
	c.reward_text = rtext
	c.starts_hidden = true
	var shape := CollisionShape3D.new()
	var cs    := SphereShape3D.new()
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
	# Lambs
	_sqitem(Vector3(-490, 0, 50),   "lamb_1", "🐑", "Lamb 1 found — safe now!")
	_sqitem(Vector3(360, 0, 190),   "lamb_2", "🐑", "Lamb 2 found — good!",)
	_sqitem(Vector3(-560, 0, -90),  "lamb_3", "🐑", "Lamb 3 — reunited!")
	# Herbs
	_sqitem(Vector3(-190, 0, -290), "herb_1", "🌿", "Herb 1 — north path!")
	_sqitem(Vector3(-490, 0, -90),  "herb_2", "🌿", "Herb 2 — from the cave!")
	_sqitem(Vector3(210, 0, 90),    "herb_3", "🌿", "Herb 3 — by the stream!")
	_sqitem(Vector3(55, 0, -590),   "herb_4", "🌿", "Herb 4 — the high ledge!")
	# Torches
	_sqitem(Vector3(450, 0, -440),  "torch_east",   "🔥", "East torch — lit!")
	_sqitem(Vector3(410, 0, -390),  "torch_centre", "🔥", "Centre torch — lit!")
	_sqitem(Vector3(365, 0, -440),  "torch_west",   "🔥", "West torch — lit!")

func _sqitem(pos: Vector3, item_id: String, emoji: String, msg: String) -> void:
	var area := Area3D.new()
	area.position   = pos
	area.monitoring  = true
	area.monitorable = true
	var shape := CollisionShape3D.new()
	var cs    := SphereShape3D.new()
	cs.radius = 0.4
	shape.shape = cs
	area.add_child(shape)
	var lbl := Label3D.new()
	lbl.text = emoji
	lbl.font_size = 22
	lbl.position = Vector3(-0.25, 0.5, 0)
	area.add_child(lbl)
	if Global.treasures_found.has(item_id):
		area.visible = false
	# Inline interact script
	var sc := GDScript.new()
	sc.source_code = ("""
extends Area3D
var item_id: String = ""
var pick_msg: String = ""
func get_interaction_label() -> String: return "✦ Pick up"
func on_interact(world: Node) -> void:
	if not visible: return
	SideQuestManager.collect_item(item_id, world)
	world.show_dialogue([{"name":"✦ Found!", "text": pick_msg}])
	visible = false
""")
	sc.reload()
	area.set_script(sc)
	area.set("item_id",   item_id)
	area.set("pick_msg",  msg)
	add_child(area)

# ─────────────────────────────────────────────────────────────────────────────
# WORLD INTRO
# ─────────────────────────────────────────────────────────────────────────────
func _show_world_intro() -> void:
	await get_tree().create_timer(1.2).timeout
	show_dialogue([
		{"name": "❝ Proverbs 3:5 ❝",
		 "text": "Trust in the LORD with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight."},
		{"name": "Morning Cliffs",
		 "text": "Explore freely. Find Elder Hanoch to begin your main quest. Hidden treasures, lost lambs, and unlit torches await your help."}
	])
	update_quest_log("Find Elder Hanoch\nto begin your quest")

# ─────────────────────────────────────────────────────────────────────────────
# MAIN QUEST — PHASE 1: LADDER CLIMB
# ─────────────────────────────────────────────────────────────────────────────
func _start_main_quest_sequence() -> void:
	update_quest_log("Main Quest: Climb to\nthe Sardius Stone ↑")
	await get_tree().create_timer(0.6).timeout
	_spawn_ladder_minigame()

func _spawn_ladder_minigame() -> void:
	var panel := PanelContainer.new()
	_ui_canvas.add_child(panel)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -280.0; panel.offset_right  = 280.0
	panel.offset_top  = -210.0; panel.offset_bottom = 210.0

	var sty := StyleBoxFlat.new()
	sty.bg_color   = Color(0.07, 0.04, 0.02, 0.96)
	sty.corner_radius_top_left     = 14; sty.corner_radius_top_right    = 14
	sty.corner_radius_bottom_left  = 14; sty.corner_radius_bottom_right = 14
	sty.border_color = Color(0.77, 0.12, 0.22, 1)
	sty.border_width_left = 2; sty.border_width_right  = 2
	sty.border_width_top  = 2; sty.border_width_bottom = 2
	sty.content_margin_left = 14; sty.content_margin_right  = 14
	sty.content_margin_top  = 14; sty.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", sty)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	panel.add_child(vb)

	var title := Label.new()
	title.text = "⬆  Climb the Ladder  ⬆"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.modulate = Color(1, 0.85, 0.3, 1)
	vb.add_child(title)

	var prompt := Label.new()
	prompt.text = "Tap each rung!\nSteady hands — steady heart."
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.add_theme_font_size_override("font_size", 17)
	prompt.modulate = Color(0.95, 0.92, 0.85, 1)
	vb.add_child(prompt)

	var progress := Label.new()
	progress.text = "0 / 10 rungs"
	progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress.add_theme_font_size_override("font_size", 20)
	progress.modulate = Color(0.9, 0.7, 0.2, 1)
	vb.add_child(progress)

	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	bar_bg.custom_minimum_size = Vector2(400, 22)
	vb.add_child(bar_bg)

	var bar := ColorRect.new()
	bar.color = Color(0.77, 0.12, 0.22, 1)
	bar.size  = Vector2(0, 22)
	bar_bg.add_child(bar)

	var tap_btn := Button.new()
	tap_btn.text = "🪜  TAP RUNG"
	tap_btn.custom_minimum_size = Vector2(0, 60)
	tap_btn.add_theme_font_size_override("font_size", 22)
	vb.add_child(tap_btn)

	var timer_lbl := Label.new()
	timer_lbl.text = "18.0 s"
	timer_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_lbl.add_theme_font_size_override("font_size", 14)
	timer_lbl.modulate = Color(0.7, 0.9, 1, 1)
	vb.add_child(timer_lbl)

	if _player:
		_player.set_physics_process(false)

	var goal: int = 9 if Global.selected_avatar.ends_with("naomi") else 10
	var count: int = 0
	var remaining: float = 18.0
	var done: bool = false

	get_tree().create_timer(18.0).timeout.connect(func():
		if done: return
		done = true
		_ui_canvas.remove_child(panel); panel.queue_free()
		if _player: _player.set_physics_process(true)
		_on_ladder_timeout()
	, CONNECT_ONE_SHOT)

	tap_btn.pressed.connect(func():
		if done: return
		count += 1
		progress.text = "%d / %d rungs" % [count, goal]
		bar.size.x = (float(count) / float(goal)) * 400.0
		var tw := create_tween()
		tw.tween_property(tap_btn, "scale", Vector2(0.9, 0.9), 0.07)
		tw.tween_property(tap_btn, "scale", Vector2(1.0, 1.0), 0.09)
		if count >= goal:
			done = true
			await get_tree().create_timer(0.3).timeout
			_ui_canvas.remove_child(panel); panel.queue_free()
			if _player: _player.set_physics_process(true)
			_on_ladder_complete()
	)

	# Countdown tick
	var _do_tick
	_do_tick = func():
		if done: return
		remaining -= 0.1
		timer_lbl.text = "%.1f s" % remaining
		timer_lbl.modulate = Color(0.7, 0.9, 1, 1) if remaining > 8 else (
			Color(1, 0.9, 0.3, 1) if remaining > 4 else Color(1, 0.3, 0.3, 1))
		get_tree().create_timer(0.1).timeout.connect(_do_tick, CONNECT_ONE_SHOT)
	get_tree().create_timer(0.1).timeout.connect(_do_tick, CONNECT_ONE_SHOT)

func _on_ladder_complete() -> void:
	var en: String = _tribe_data.get("elder", "Elder Hanoch") as String
	show_dialogue([
		{"name": en, "text": "You made it to the top! Well done, my child. Now — do you see that butterfly resting on the stone ledge?"},
		{"name": en, "text": "Tap when its wings open wide — on the beat. Listen with your heart, not just your eyes.",
		 "callback": Callable(self, "_spawn_butterfly_minigame")}
	])

func _on_ladder_timeout() -> void:
	var en: String = _tribe_data.get("elder", "Elder Hanoch") as String
	show_dialogue([
		{"name": en, "text": "Let's try again together. God is patient — He sees your heart on every rung.",
		 "callback": Callable(self, "_spawn_ladder_minigame")}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MAIN QUEST — PHASE 2: BUTTERFLY RHYTHM
# "New creation comes in Christ" – 2 Corinthians 5:17
# ─────────────────────────────────────────────────────────────────────────────
func _spawn_butterfly_minigame() -> void:
	var panel := PanelContainer.new()
	_ui_canvas.add_child(panel)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -300.0; panel.offset_right  = 300.0
	panel.offset_top  = -230.0; panel.offset_bottom = 230.0

	var sty := StyleBoxFlat.new()
	sty.bg_color   = Color(0.04, 0.07, 0.04, 0.96)
	sty.corner_radius_top_left     = 14; sty.corner_radius_top_right    = 14
	sty.corner_radius_bottom_left  = 14; sty.corner_radius_bottom_right = 14
	sty.border_color = Color(0.38, 0.72, 0.38, 1)
	sty.border_width_left = 2; sty.border_width_right  = 2
	sty.border_width_top  = 2; sty.border_width_bottom = 2
	sty.content_margin_left = 14; sty.content_margin_right  = 14
	sty.content_margin_top  = 14; sty.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", sty)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	panel.add_child(vb)

	var title := Label.new()
	title.text = "🦋  Butterfly Flutter  🦋"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.modulate = Color(0.7, 1.0, 0.7, 1)
	vb.add_child(title)

	var prompt := Label.new()
	prompt.text = "Tap when the butterfly opens its wings!\n(when the circle pulses BIG)"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.add_theme_font_size_override("font_size", 16)
	vb.add_child(prompt)

	var c_container := Control.new()
	c_container.custom_minimum_size = Vector2(200, 110)
	c_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vb.add_child(c_container)

	var circle := ColorRect.new()
	circle.color    = Color(0.38, 0.72, 0.38, 0.6)
	circle.size     = Vector2(80, 80)
	circle.position = Vector2(60, 18)
	c_container.add_child(circle)

	var fly_lbl := Label.new()
	fly_lbl.text = "🦋"
	fly_lbl.add_theme_font_size_override("font_size", 36)
	fly_lbl.position = Vector2(74, 20)
	c_container.add_child(fly_lbl)

	var score_lbl := Label.new()
	score_lbl.text = "0 / 6 beats"
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_lbl.add_theme_font_size_override("font_size", 18)
	score_lbl.modulate = Color(0.7, 1.0, 0.7, 1)
	vb.add_child(score_lbl)

	var tap_btn := Button.new()
	tap_btn.text = "🦋  TAP!"
	tap_btn.custom_minimum_size = Vector2(0, 56)
	tap_btn.add_theme_font_size_override("font_size", 22)
	vb.add_child(tap_btn)

	if _player: _player.set_physics_process(false)

	const BEAT_DUR  := 0.9
	const BEATS     := 10
	const NEED_HITS := 6
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
		tw_o.tween_property(circle, "size", Vector2(140, 140), 0.22).set_ease(Tween.EASE_OUT)
		tw_o.tween_property(circle, "modulate:a", 1.0, 0.22)
		tw_o.tween_interval(0.18)
		tw_o.tween_callback(func():
			is_open = false
			var tw_c := create_tween()
			tw_c.tween_property(circle, "size", Vector2(80, 80), 0.28).set_ease(Tween.EASE_IN)
			tw_c.tween_property(circle, "modulate:a", 0.6, 0.28)
		)
		get_tree().create_timer(BEAT_DUR).timeout.connect(run_beat, CONNECT_ONE_SHOT)
	run_beat.call()

	tap_btn.pressed.connect(func():
		if done: return
		if is_open:
			hits += 1
			score_lbl.text = "%d / %d beats" % [hits, NEED_HITS]
			var fl := create_tween()
			fl.tween_property(fly_lbl, "modulate", Color(1.5, 1.5, 0.5, 1), 0.1)
			fl.tween_property(fly_lbl, "modulate", Color(1, 1, 1, 1), 0.15)
			if hits >= NEED_HITS:
				done = true
				await get_tree().create_timer(0.5).timeout
				_ui_canvas.remove_child(panel); panel.queue_free()
				if _player: _player.set_physics_process(true)
				_on_butterfly_complete()
		else:
			var ms := create_tween()
			ms.tween_property(circle, "modulate", Color(1.5, 0.3, 0.3, 1), 0.08)
			ms.tween_property(circle, "modulate", Color(1, 1, 1, 1), 0.22)
	)

	get_tree().create_timer(BEAT_DUR * float(BEATS) + 1.0).timeout.connect(func():
		if done: return
		done = true
		_ui_canvas.remove_child(panel); panel.queue_free()
		if _player: _player.set_physics_process(true)
		if hits >= NEED_HITS: _on_butterfly_complete()
		else:                 _on_butterfly_timeout()
	, CONNECT_ONE_SHOT)

func _on_butterfly_complete() -> void:
	var en: String = _tribe_data.get("elder", "Elder Hanoch") as String
	show_dialogue([
		{"name": en, "text": "Beautiful! You felt the rhythm of God's creation. The Sardius stone — ruby red courage of Reuben — is yours.",
		 "callback": Callable(self, "_finish_quest")}
	])

func _on_butterfly_timeout() -> void:
	var en: String = _tribe_data.get("elder", "Elder Hanoch") as String
	show_dialogue([
		{"name": en, "text": "Try again, my child. The butterfly is patient — just as 'new creation comes in Christ.' – 2 Corinthians 5:17",
		 "callback": Callable(self, "_spawn_butterfly_minigame")}
	])

func on_minigame_complete(result: Dictionary) -> void:
	if _quest_state == 1:
		# Ladder complete
		_quest_state = 2
		show_dialogue([
			{"name": "Elder Hanoch", "text": "Well done! Now, look at this butterfly. It tastes with its feet — a wonder of creation. Match its rhythm to prove your trust."},
			{"name": "You", "text": "Please, Elder — I will try."}
		])
		await get_tree().create_timer(1.0).timeout
		_spawn_butterfly_minigame()
	elif _quest_state == 2:
		# Butterfly complete
		_quest_state = 3
		show_verse_scroll("Proverbs 3:5-6", "Trust in the LORD with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.")
		await get_tree().create_timer(2.0).timeout
		show_nature_fact()
		await get_tree().create_timer(2.0).timeout
		_collect_stone()

func on_minigame_timeout(result: Dictionary) -> void:
	if _quest_state == 1:
		show_dialogue([
			{"name": "Elder Hanoch", "text": "The climb is steep, but 'I can do all things through Christ who strengthens me.' – Philippians 4:13. Try again!"},
			{"name": "You", "text": "Thank you, Elder. I will."}
		])
		await get_tree().create_timer(1.0).timeout
		_spawn_ladder_minigame()
	elif _quest_state == 2:
		show_dialogue([
			{"name": "Elder Hanoch", "text": "The butterfly flew away. But 'new creation comes in Christ.' – 2 Corinthians 5:17. Try again!"},
			{"name": "You", "text": "Please, Elder — I will match its rhythm."}
		])
		await get_tree().create_timer(1.0).timeout
		_spawn_butterfly_minigame()
