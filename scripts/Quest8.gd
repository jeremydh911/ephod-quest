extends "res://scripts/WorldBase.gd"

# ─────────────────────────────────────────────────────────────────────────────
# Quest8.gd  –  Tribe of Asher
# Map: Fertile valley.
# Mini-game 1: Harvesting Game — collect and share bread (12 shares, 18 s).
# Mini-game 2: Honey Dance — follow bee's waggle dance (6 dances).
# Verse: Luke 9:16  |  Nature: Bees / Luke 9:16
# "Taking the five loaves and the two fish... he gave thanks" – Luke 9:16
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key = "asher"
	quest_id = "asher_main"
	next_scene = "res://scenes/Quest9.tscn"
	world_name = "Fertile Valley"
	# Genesis 49:20 – Asher's food shall be rich, and he shall yield royal delicacies
	music_path = "res://assets/audio/music/sunrise_over_the_valley.wav"
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
# "He gave thanks and broke them" – Luke 9:16
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# "Asher's food will be rich, he will provide delicacies fit for a king" – Genesis 49:20
	# Wide valley floor (fertile brown soil)
	_draw_tile(Rect2(-900, -700, 1800, 1400), Color(0.46, 0.34, 0.20, 1), "soil") # valley soil
	# Lush orchard zone (rows of trees, east half)
	_draw_tile(Rect2(80, -700, 820, 1400), Color(0.34, 0.52, 0.22, 1)) # orchard grass
	_draw_tile(Rect2(200, -700, 80, 1400), Color(0.28, 0.44, 0.18, 1)) # orchard lane 1
	_draw_tile(Rect2(380, -700, 80, 1400), Color(0.28, 0.44, 0.18, 1)) # orchard lane 2
	_draw_tile(Rect2(560, -700, 80, 1400), Color(0.28, 0.44, 0.18, 1)) # orchard lane 3
	# Olive grove (far east)
	_draw_tile(Rect2(700, -600, 200, 1100), Color(0.44, 0.52, 0.28, 1)) # olive green
	# Central harvest path
	_draw_tile(Rect2(-60, -700, 120, 1400), Color(0.54, 0.44, 0.28, 1)) # central path
	# Beehive clearing (west)
	_draw_tile(Rect2(-600, -160, 320, 320), Color(0.74, 0.66, 0.38, 0.85)) # honey glow ground
	# Stream running north-south (far west)
	_draw_tile(Rect2(-820, -600, 28, 1200), Color(0.44, 0.72, 0.90, 0.78)) # stream
	# Bread oven plaza (south centre)
	_draw_tile(Rect2(-200, 360, 380, 260), Color(0.62, 0.50, 0.34, 1)) # oven plaza
	# Valley rim hills
	_draw_tile(Rect2(-900, -700, 120, 1400), Color(0.52, 0.44, 0.30, 1)) # west rim
	_draw_tile(Rect2(880, -700, 120, 1400), Color(0.52, 0.44, 0.30, 1)) # east rim
	# Boundary walls
	_draw_wall(Rect2(-920, -730, 20, 1460))
	_draw_wall(Rect2(900, -730, 20, 1460))
	_draw_wall(Rect2(-920, -730, 1840, 20))
	_draw_wall(Rect2(-920, 730, 1840, 20))


# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# "He gave them to the disciples to distribute" – Luke 9:16
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder Imnah — central harvest path
	_build_npc("elder_imnah", Vector3(0, 0, 0))
	# Beekeeper daughter — beehive clearing west
	_build_npc("beekeeper_beriah", Vector3(-440, 0, -20))
	# Baker — bread oven plaza south
	_build_npc("baker_japhlet", Vector3(-40, 0, 440))
	# Orchard worker — east orchard lane
	_build_npc("orchard_jimnah", Vector3(440, 0, -240))


# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# "To the people" – Luke 9:16
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	# Central chest — under harvest canopy
	_chest(Vector3(30, 0, 30), "asher_chest_luke916", "Luke 9:16")
	# Beehive hidden chest — behind hive wall
	_chest(Vector3(-520, 0, 60), "asher_chest_psalm34", "Psalm 34:8")
	# Orchard chest — east olive grove
	_chest(Vector3(720, 0, 200), "asher_chest_genesis49", "Genesis 49:20")
	# Bread oven chest — south plaza
	_chest(Vector3(-80, 0, 500), "asher_chest_john621", "John 6:35")


func on_quest_ready() -> void:
	var elder: String = Global.get_tribe_data(tribe_key).get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "My child, shalom! The fertile valley overflows with blessing. The Agate stone — banded like Asher's abundance — waits among the harvests.",
			},
			{
				"name": elder,
				"text": "Asher was blessed with rich food and royal delicacies. Like bees that share through dance, he provided for all. \"Taking the five loaves...\", he remembered.",
			},
			{
				"name": "You",
				"text": "Please, Elder Imnah — how do I find the stone?",
			},
			{
				"name": elder,
				"text": "First, harvest the crops and share the bread with all who come. Then, learn the honey dance from the bees!",
				"callback": Callable(self, "_start_harvesting_game"),
			},
		],
	)

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — HARVESTING GAME (collect and share)
# ─────────────────────────────────────────────────────────────────────────────
var _harvest_result: Dictionary = { }
var _dance_result: Dictionary = { }


func _start_harvesting_game() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	# Luke 9:16 — giving thanks, bread multiplied when shared with all
	_harvest_result = build_tap_minigame(
		container,
		12,
		"Harvest the crops and share the bread!\nBlessing multiplies when shared.",
		18.0,
	)


func _continue_after_harvest() -> void:
	await get_tree().create_timer(1.5).timeout
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "Abundantly shared! You understand blessing. Now — watch the bees dance! Follow their waggle to find the honey.",
			},
			{
				"name": elder,
				"text": "The bee's dance shows the way to sweetness. Each movement reveals God's provision. Follow carefully!",
				"callback": Callable(self, "_start_honey_dance"),
			},
		],
	)


# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 2 — HONEY DANCE (follow pattern)
# ─────────────────────────────────────────────────────────────────────────────
func _start_honey_dance() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	for child in container.get_children():
		child.queue_free()
	# Proverbs 6:6–8 — bees communicate direction through rhythmic waggle dance
	_dance_result = build_rhythm_minigame(
		container,
		0.4,
		6,
		5,
		"Follow the bee's waggle dance!\nKeep the rhythm — watch the pattern.",
	)


func _on_dance_complete() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "Dance followed perfectly! You found the sweetness. Now — let me share the words that Asher carried through the valleys.",
				"callback": Callable(self, "_show_quest_verse"),
			},
		],
	)


func _show_quest_verse() -> void:
	show_verse_scroll(
		_tribe_data.get("quest_verse_ref", ""),
		_tribe_data.get("quest_verse", ""),
	)


# ─────────────────────────────────────────────────────────────────────────────
# QUEST COMPLETE — fade out and change scene
# ─────────────────────────────────────────────────────────────────────────────
func on_minigame_complete(result: Dictionary) -> void:
	if result.get("root") == _harvest_result.get("root"):
		_continue_after_harvest()
	elif result.get("root") == _dance_result.get("root"):
		_on_dance_complete()


func on_minigame_timeout(result: Dictionary) -> void:
	if result.get("root") == _harvest_result.get("root"):
		_continue_after_harvest()
	elif result.get("root") == _dance_result.get("root"):
		_on_dance_complete()
