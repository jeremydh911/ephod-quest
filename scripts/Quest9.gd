extends "res://scripts/WorldBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# Quest9.gd  –  Tribe of Issachar
# Map: Hilltop observatory.
# Mini-game 1: Astronomy Puzzle — arrange constellations (8 pieces, 20 s).
# Mini-game 2: Time Management — schedule tribal activities (6 schedules).
# Verse: 1 Chronicles 12:32  |  Nature: Monarch butterflies / 1 Chronicles 12:32
# "Men who understood the times and knew what Israel should do" – 1 Chronicles 12:32
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key  = "issachar"
	quest_id   = "issachar_main"
	next_scene = "res://scenes/Quest10.tscn"
	# Genesis 49:14 – Issachar is a strong donkey, a patient and steady worker
	music_path = "res://assets/audio/music/soft_stone_discovery.wav"
	super._ready()

func on_world_ready() -> void:
	super.on_world_ready()  # 3D sky + directional light – Psalm 19:1
	_build_terrain()
	_place_npcs()
	_place_chests()
	_show_world_intro()

# ─────────────────────────────────────────────────────────────────────────────
# TERRAIN
# "Understood the times" – 1 Chronicles 12:32
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# Hilltop observatory
	# "Issachar crouched between two saddlebags" – Genesis 49:14
	# Ground: hilltop stone
	_tr(Vector3(-50, 0, -50), Vector3(100, 0, 100), "stone.jpg")
	
	# Observatory stones: arranged in a circle
	for i in range(8):
		var angle = i * PI / 4
		var x = cos(angle) * 20
		var z = sin(angle) * 20
		_wall(Vector3(x, 0, z), Vector3(2, 3, 2), "stone.jpg")

# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# "Knew what Israel should do" – 1 Chronicles 12:32
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder Tola at the observatory center
	_build_npc("tola", Vector3(0, 0, 0), "elder_tola.jpg")

# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# "Men of Issachar" – 1 Chronicles 12:32
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	# Verse chest among the stones
	_chest(Vector3(15, 0, 15), "chronicles_12_32", "1 Chronicles 12:32")

func on_quest_ready() -> void:
	var elder: String = Global.get_tribe_data(tribe_key).get("elder", "Elder")
	show_dialogue([
		{
			"name": elder,
			"text": "My child, shalom! The hilltop observatory commands the stars above. The Amethyst stone — purple like wisdom — waits among the ancient stones."
		},
		{
			"name": elder,
			"text": "Issachar understood the times and seasons. Like butterflies that know when to migrate, he perceived God's timing. \"Men who understood the times...\", they were called."
		},
		{
			"name": "You",
			"text": "Please, Elder Tola — how do I find the stone?"
		},
		{
			"name": elder,
			"text": "First, arrange the constellations in the night sky. Then, schedule the tribe's activities with wisdom!",
			"callback": Callable(self, "_start_astronomy_puzzle")
		}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — ASTRONOMY PUZZLE (arrange constellations)
# ─────────────────────────────────────────────────────────────────────────────
var _puzzle_result: Dictionary = {}
var _schedule_result: Dictionary = {}

func _start_astronomy_puzzle() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	_puzzle_result = build_sorting_minigame(
		container, 8,
		"Sort the constellation pieces!\nFind God's order in the stars.",
		20.0
	)

func _continue_after_puzzle() -> void:
	await get_tree().create_timer(1.5).timeout
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder,
		 "text": "Stars aligned perfectly! You see God's order. Now — schedule the tribe's activities. Wisdom knows the right time for each thing."},
		{"name": elder,
		 "text": "Morning prayer, midday work, evening rest. Each has its season. Arrange them wisely!",
		 "callback": Callable(self, "_start_time_management")}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 2 — TIME MANAGEMENT (schedule activities)
# ─────────────────────────────────────────────────────────────────────────────
func _start_time_management() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	for child in container.get_children(): child.queue_free()
	_schedule_result = build_rhythm_minigame(
		container, 0.8, 12, 7,
		"Tap in the rhythm of the seasons!\nThere is a time for everything."
	)

func _on_schedule_complete() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "Schedule perfected! You understand timing. Now — let me share the words that Issachar carried through the seasons.",
		"callback": Callable(self, "_show_quest_verse")
	}])

func _show_quest_verse() -> void:
	var ref:  String = _tribe_data.get("quest_verse_ref", "")
	var text: String = _tribe_data.get("quest_verse", "")
	show_verse_scroll(ref, text)

# ─────────────────────────────────────────────────────────────────────────────
# QUEST COMPLETE — fade out and change scene
# ─────────────────────────────────────────────────────────────────────────────
func on_minigame_complete(result: Dictionary) -> void:
	if result.get("root") == _puzzle_result.get("root"):
		_continue_after_puzzle()
	elif result.get("root") == _schedule_result.get("root"):
		_on_schedule_complete()

func on_minigame_timeout(result: Dictionary) -> void:
	if result.get("root") == _puzzle_result.get("root"):
		_continue_after_puzzle()
	elif result.get("root") == _schedule_result.get("root"):
		_on_schedule_complete()