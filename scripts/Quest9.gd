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
	tribe_key = "issachar"
	quest_id = "issachar_main"
	next_scene = "res://scenes/Quest10.tscn"
	world_name = "Hilltop Observatory"
	# Genesis 49:14 – Issachar is a strong donkey, a patient and steady worker
	music_path = "res://assets/audio/music/soft_stone_discovery.wav"
	world_bounds = Rect2(-900, -700, 1800, 1400)
	super._ready()


func on_world_ready() -> void:
	super.on_world_ready() # 3D sky + directional light – Psalm 19:1
	_build_terrain()
	_place_npcs()
	_place_chests()
	_show_world_intro()


# ─────────────────────────────────────────────────────────────────────────────
# TERRAIN
# "Understood the times" – 1 Chronicles 12:32
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# "Men of Issachar who understood the times" – 1 Chronicles 12:32
	# Wide hillside approach (south/lower)
	_draw_tile(Rect2(-900, 200, 1800, 500), Color(0.44, 0.42, 0.36, 1)) # lower slope
	# Rising terrace 1
	_draw_tile(Rect2(-700, -60, 1400, 260), Color(0.50, 0.48, 0.40, 1)) # mid terrace
	# Rising terrace 2
	_draw_tile(Rect2(-560, -280, 1120, 200), Color(0.56, 0.52, 0.44, 1)) # upper terrace
	# Summit platform (flat hilltop)
	_draw_tile(Rect2(-400, -700, 800, 460), Color(0.62, 0.58, 0.50, 1), "stone") # hilltop stone
	# Observation ring (centre summit)
	_draw_tile(Rect2(-120, -560, 240, 240), Color(0.72, 0.68, 0.58, 1)) # observation floor
	# Staircase path up the hill (zigzag blocks)
	_draw_tile(Rect2(-24, 200, 48, 900), Color(0.58, 0.54, 0.46, 1)) # central stair path
	_draw_tile(Rect2(-180, -60, 300, 48), Color(0.54, 0.50, 0.42, 1)) # stair landing 1
	_draw_tile(Rect2(-80, -220, 300, 48), Color(0.56, 0.52, 0.44, 1)) # stair landing 2
	# Star map engraving (north — flat dark stone)
	_draw_tile(Rect2(-300, -700, 600, 200), Color(0.14, 0.12, 0.20, 1)) # star map dark
	# Stone circle (8 uprights, baked as small plateau pads)
	for i in range(8):
		var angle := i * PI / 4.0
		var cx := cos(angle) * 140.0
		var cz := sin(angle) * 140.0
		_draw_tile(Rect2(-28 + cx - 400, -280 + cz - 560, 56, 56), Color(0.58, 0.50, 0.40, 1))
	# Boundary walls
	_draw_wall(Rect2(-920, -730, 20, 1460))
	_draw_wall(Rect2(900, -730, 20, 1460))
	_draw_wall(Rect2(-920, -730, 1840, 20))
	_draw_wall(Rect2(-920, 730, 1840, 20))


# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# "Knew what Israel should do" – 1 Chronicles 12:32
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder Tola — observation ring centre
	_build_npc("elder_tola", Vector3(0, 0, -400))
	# Astronomer apprentice — star map north
	_build_npc("apprentice_puah", Vector3(-80, 0, -620))
	# Hillside farmer — lower slope
	_build_npc("farmer_shimron", Vector3(300, 0, 360))


# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# "Men of Issachar" – 1 Chronicles 12:32
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	# Summit chest — stone circle centre
	_chest(Vector3(0, 0, -420), "issachar_chest_chron", "1 Chronicles 12:32")
	# Star map chest — dark stone north
	_chest(Vector3(-80, 0, -660), "issachar_chest_psalm19", "Psalm 19:1")
	# Mid terrace chest
	_chest(Vector3(-340, 0, -180), "issachar_chest_gen49", "Genesis 49:14")
	# Lower slope chest — near farmer
	_chest(Vector3(400, 0, 360), "issachar_chest_eccl311", "Ecclesiastes 3:11")


func on_quest_ready() -> void:
	var elder: String = Global.get_tribe_data(tribe_key).get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "My child, shalom! The hilltop observatory commands the stars above. The Amethyst stone — purple like wisdom — waits among the ancient stones.",
			},
			{
				"name": elder,
				"text": "Issachar understood the times and seasons. Like butterflies that know when to migrate, he perceived God's timing. \"Men who understood the times...\", they were called.",
			},
			{
				"name": "You",
				"text": "Please, Elder Tola — how do I find the stone?",
			},
			{
				"name": elder,
				"text": "First, arrange the constellations in the night sky. Then, schedule the tribe's activities with wisdom!",
				"callback": Callable(self, "_start_astronomy_puzzle"),
			},
		],
	)

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — ASTRONOMY PUZZLE (arrange constellations)
# ─────────────────────────────────────────────────────────────────────────────
var _puzzle_result: Dictionary = { }
var _schedule_result: Dictionary = { }


func _start_astronomy_puzzle() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	_puzzle_result = build_sorting_minigame(
		container,
		8,
		"Sort the constellation pieces!\nFind God's order in the stars.",
		20.0,
	)


func _continue_after_puzzle() -> void:
	await get_tree().create_timer(1.5).timeout
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "Stars aligned perfectly! You see God's order. Now — schedule the tribe's activities. Wisdom knows the right time for each thing.",
			},
			{
				"name": elder,
				"text": "Morning prayer, midday work, evening rest. Each has its season. Arrange them wisely!",
				"callback": Callable(self, "_start_time_management"),
			},
		],
	)


# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 2 — TIME MANAGEMENT (schedule activities)
# ─────────────────────────────────────────────────────────────────────────────
func _start_time_management() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	for child in container.get_children():
		child.queue_free()
	_schedule_result = build_rhythm_minigame(
		container,
		0.8,
		12,
		7,
		"Tap in the rhythm of the seasons!\nThere is a time for everything.",
	)


func _on_schedule_complete() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "Schedule perfected! You understand timing. Now — let me share the words that Issachar carried through the seasons.",
				"callback": Callable(self, "_show_quest_verse"),
			},
		],
	)


func _show_quest_verse() -> void:
	var ref: String = _tribe_data.get("quest_verse_ref", "")
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
