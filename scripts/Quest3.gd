extends "res://scripts/WorldBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# Quest3.gd  –  World 3: Sacred Lampstand Hall  (Tribe of Levi)
# Gold rounded pillars, cedar beams, 7-flame lampstand, blue/purple/scarlet
# curtains, thick veil with embroidered cherubim. (No "temple" or "church".)
# Mini-game 1: Lamp Lighting — tap lamps in order left→right (7 lamps).
# Mini-game 2: Scroll Reading — tap glowing words in the correct sequence.
# "Let your light shine before others" – Matthew 5:16
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key    = "levi"
	quest_id     = "levi_main"
	next_scene   = "res://scenes/Quest4.tscn"
	world_name   = "Sacred Lampstand Hall"
	# Exodus 30:7 – Aaron burns fragrant incense every morning
	music_path   = "res://assets/audio/music/incense_in_the_vaulted_air.wav"
	world_bounds = Rect2(-900, -700, 1800, 1400)
	super._ready()

func on_world_ready() -> void:
	super.on_world_ready()  # 3D sky + directional light – Psalm 19:1
	_build_terrain()
	_place_npcs()
	_place_chests()
	_show_world_intro()

# "He tends his lamp before the LORD" – Exodus 27:20
func _build_terrain() -> void:
	# "He tends his lamp before the LORD" – Exodus 27:20
	# Stone floor
	_draw_tile(Rect2(-800, -600, 1600, 1200), Color(0.52, 0.44, 0.28, 1))
	# Cedar ceiling beam (decorative—dark strip at top)
	_draw_tile(Rect2(-800, -600, 1600, 40),   Color(0.36, 0.24, 0.14, 1))
	# Gold pillar — left
	_draw_tile(Rect2(-680, -560, 60, 900),    Color(0.82, 0.68, 0.12, 1))
	# Gold pillar — right
	_draw_tile(Rect2(620,  -560, 60, 900),    Color(0.82, 0.68, 0.12, 1))
	# Blue + purple + scarlet curtain bands at rear
	_draw_tile(Rect2(-600, -580, 200, 580),   Color(0.22, 0.38, 0.72, 0.80))  # blue
	_draw_tile(Rect2(-360, -580, 200, 580),   Color(0.50, 0.20, 0.62, 0.80))  # purple
	_draw_tile(Rect2(-120, -580, 200, 580),   Color(0.72, 0.16, 0.18, 0.80))  # scarlet
	_draw_tile(Rect2(120,  -580, 200, 580),   Color(0.22, 0.38, 0.72, 0.80))  # blue
	_draw_tile(Rect2(360,  -580, 200, 580),   Color(0.50, 0.20, 0.62, 0.80))  # purple
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
	var elder_name: String = _tribe_data.get("elder", "Elder Gershon") as String

	# Elder Gershon — main quest trigger
	var gershon := _build_npc_q3(Vector3(-60, 0, 40), elder_name, "👴", Color("#8B4513"))
	gershon.dialogue_lines = [
		{"name": elder_name,
		 "text": "My child, shalom! Welcome to the Sacred Lampstand Hall — land of Levi, the priestly tribe. The Carbuncle stone rests beyond the veil, glowing like the seven lamps."},
		{"name": elder_name,
		 "text": "Levi means 'joined'. The priests were joined to the LORD's service. Light shines from those who serve faithfully."},
		{"name": "You", "text": "Please, Elder " + elder_name.split(" ")[1] + " — what must I do?"},
		{"name": elder_name,
		 "text": "Light the seven lamps in order — left to right. Then read the scroll on the veil. The light will guide you."},
		{"name": elder_name,
		 "text": "God sees your heart. Are you ready?",
		 "callback": Callable(self, "_start_lamp_mini")}
	]
	gershon.repeat_lines = [
		{"name": elder_name,
		 "text": "The lamps await your touch. Light them in order, my child."}
	]

func _build_npc_q3(pos: Vector3, npc_name: String, emoji: String, color: Color) -> Area3D:
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
	_spawn_chest(Vector3(350, 0, -180), "levi_chest_matthew",
		"verse", "", "Matthew 5:16",
		"Let your light shine before others, that they may see your good deeds and glorify your Father in heaven.")

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
		{"name": "❝ Matthew 5:16 ❝",
		 "text": "Let your light shine before others, that they may see your good deeds and glorify your Father in heaven."},
		{"name": "Sacred Lampstand Hall",
		 "text": "Gold pillars line the hall. Cedar beams arch overhead. Seven unlit lamps wait in a row — and a scroll hangs on the great veil. Speak with " + elder + " to begin."}
	])
	update_quest_log("Find " + elder + "\nto begin your quest")

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — LAMP LIGHTING (ordered tap)
# ─────────────────────────────────────────────────────────────────────────────
var _lamp_result: Dictionary = {}
var _scroll_result: Dictionary = {}

func _start_lamp_mini() -> void:
	var container: Control = _mini_game_container
	container.visible = true

	var prompt := Label.new()
	prompt.text = "Light the seven lamps in order — left to right.\nTap gently and purposefully."
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 17)
	container.add_child(prompt)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 12)
	container.add_child(hbox)

	var status := Label.new()
	status.text = "Tap lamp 1 first…"
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(status)

	var _next := [0]
	var _done  := [false]
	# Anna avatar: speed boost — lamps stay visible longer (no mechanical diff needed)
	var lamp_buttons: Array[Button] = []
	for i in range(7):
		var lamp := Button.new()
		lamp.text = str(i + 1)
		lamp.custom_minimum_size = Vector2(52, 52)
		lamp.add_theme_font_size_override("font_size", 18)
		lamp.modulate = Color(0.5, 0.5, 0.5, 1)   # unlit
		hbox.add_child(lamp)
		lamp_buttons.append(lamp)
		var idx := i
		lamp.pressed.connect(func():
			if _done[0]: return
			if idx == _next[0]:
				lamp.modulate = Color(1.0, 0.82, 0.1, 1)   # lit — gold
				AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
				_next[0] += 1
				if _next[0] >= 7:
					_done[0] = true
					status.text = "✦ All seven lamps are lit! Light shines!"
					_lamp_result = {"lamp_done": true}
					on_minigame_complete(_lamp_result)
				else:
					status.text = "Tap lamp %d…" % (_next[0] + 1)
			else:
				status.text = "Not yet — try lamp %d first." % (_next[0] + 1)
				AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
		)
	_lamp_result = {"buttons": lamp_buttons, "done": false}

func _after_lamps() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder,
		 "text": "Every flame glows! Now look — the thick veil has an inscription. The letters are scattered. Tap them in the right order to open the way."},
		{"name": elder,
		 "text": "Micah, your scroll-reading skill will help here. Read carefully.",
		 "callback": Callable(self, "_start_scroll_mini")}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 2 — SCROLL READING (word sequence)
# ─────────────────────────────────────────────────────────────────────────────
# Words from Matthew 5:16 scattered on screen; player taps them in order
const SCROLL_WORDS: Array[String] = [
	"Let", "your", "light", "shine", "before", "others"
]

func _start_scroll_mini() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	for child in container.get_children(): child.queue_free()

	var prompt := Label.new()
	prompt.text = "Tap the words of Matthew 5:16 in order:"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 17)
	container.add_child(prompt)

	# Shuffle display order
	var shuffled := SCROLL_WORDS.duplicate()
	shuffled.shuffle()

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	container.add_child(grid)

	var status := Label.new()
	status.text = "First word: \"%s\"" % SCROLL_WORDS[0]
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(status)

	# Avatar edge: Micah sees correct answer highlighted briefly
	var _next := [0]
	var _done  := [false]
	for word in shuffled:
		var btn := Button.new()
		btn.text = word
		btn.custom_minimum_size = Vector2(100, 48)
		grid.add_child(btn)
		var captured_word: String = word as String
		btn.pressed.connect(func():
			if _done[0]: return
			if captured_word == SCROLL_WORDS[_next[0]]:
				btn.modulate = Color(0.2, 0.7, 0.25, 1)
				btn.disabled = true
				AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
				_next[0] += 1
				if _next[0] >= SCROLL_WORDS.size():
					_done[0] = true
					status.text = "✦ The scroll is read! The path opens."
					_scroll_result = {"scroll_done": true}
					on_minigame_complete(_scroll_result)
				else:
					status.text = "Next word: \"%s\"" % SCROLL_WORDS[_next[0]]
			else:
				status.text = "Not that one — find \"%s\" next." % SCROLL_WORDS[_next[0]]
				AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
		)
	_scroll_result = {"done": false}

func _on_scroll_complete() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "\"Let your light shine before others, that they may see your good deeds and glorify your Father in heaven.\" Well read! Now — receive the word of Levi.",
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
	if result.has("lamp_done"):
		await get_tree().create_timer(0.8).timeout
		_after_lamps()
	elif result.has("scroll_done"):
		await get_tree().create_timer(0.6).timeout
		_on_scroll_complete()

func on_minigame_timeout(_result: Dictionary) -> void:
	pass  # Lamp and scroll have no time limit — retry is always available
