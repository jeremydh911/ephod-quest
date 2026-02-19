extends "res://scripts/QuestBase.gd"
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
	music_path = "res://assets/audio/music/quest_theme.ogg"
	super._ready()

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
	var container: Node = $MiniGameContainer
	container.visible = true
	_puzzle_result = build_astronomy_puzzle_minigame(
		container, 8,
		"Arrange the constellation pieces!\nFind the pattern in the stars.",
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
	var container: Node = $MiniGameContainer
	container.visible = true
	for child in container.get_children():
		child.queue_free()
	_schedule_result = build_time_management_minigame(
		container, 6,
		"Schedule tribal activities!\nPlace each task in its proper time."
	)

func _on_schedule_complete() -> void:
	$MiniGameContainer.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "Schedule perfected! You understand timing. Now — let me share the words that Issachar carried through the seasons.",
		"callback": Callable(self, "_show_quest_verse")
	}])

func _show_quest_verse() -> void:
	var ref:  String = _tribe_data.get("quest_verse_ref", "")
	var text: String = _tribe_data.get("quest_verse_text", "")
	show_verse_scroll(ref, text)

# ─────────────────────────────────────────────────────────────────────────────
# QUEST COMPLETE — fade out and change scene
# ─────────────────────────────────────────────────────────────────────────────
func on_minigame_complete(result: Dictionary) -> void:
	if result == _puzzle_result:
		_continue_after_puzzle()
	elif result == _schedule_result:
		_on_schedule_complete()

func on_minigame_timeout(result: Dictionary) -> void:
	if result == _puzzle_result:
		_continue_after_puzzle()
	elif result == _schedule_result:
		_on_schedule_complete()