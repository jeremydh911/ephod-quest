extends "res://scripts/WorldBase.gd"

# ─────────────────────────────────────────────────────────────────────────────
# Quest12.gd  –  Tribe of Benjamin
# Mini-game 1: Precision Tap — tap targets accurately (10 taps, 20 s)
# Mini-game 2: Protection Swipe — swipe to shield the vulnerable (8, 18 s)
# Verse: Deuteronomy 33:12  |  Nature: Wolf pack pups / Zephaniah 3:17
# "Let the beloved of the LORD rest secure in him" – Deuteronomy 33:12
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key = "benjamin"
	quest_id = "benjamin_main"
	next_scene = "res://scenes/Finale.tscn"
	world_name = "Moonlit Forest"
	# Deuteronomy 33:12 – Let the beloved of the LORD rest secure in him
	music_path = "res://assets/audio/music/sacred_spark.wav"
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
# "Beloved of the LORD" – Deuteronomy 33:12
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# "Benjamin is a ravenous wolf; in the morning he devours the prey" – Genesis 49:27
	# Dark forest floor (base)
	_draw_tile(Rect2(-900, -700, 1800, 1400), Color(0.10, 0.14, 0.08, 1)) # dark forest
	# Deep pine zones (edge columns)
	_draw_tile(Rect2(-900, -700, 300, 1400), Color(0.06, 0.10, 0.04, 1)) # west deep pine
	_draw_tile(Rect2(600, -700, 300, 1400), Color(0.06, 0.10, 0.04, 1)) # east deep pine
	_draw_tile(Rect2(-900, -700, 1800, 300), Color(0.06, 0.10, 0.04, 1)) # north deep pine
	# Moonlit clearing (centre)
	_draw_tile(Rect2(-280, -200, 560, 480), Color(0.28, 0.38, 0.22, 1)) # moonlit grass
	_draw_tile(Rect2(-120, -100, 240, 220), Color(0.36, 0.46, 0.28, 0.80)) # brightest moon pool
	# Forest paths (two crossing trails)
	_draw_tile(Rect2(-30, -700, 60, 1400), Color(0.20, 0.26, 0.14, 1)) # north-south trail
	_draw_tile(Rect2(-900, -30, 1800, 60), Color(0.20, 0.26, 0.14, 1)) # east-west trail
	# Wolf den boulders (rocky pads)
	_draw_tile(Rect2(-460, -380, 160, 140), Color(0.32, 0.28, 0.22, 1)) # den 1 rock
	_draw_tile(Rect2(300, 260, 140, 120), Color(0.32, 0.28, 0.22, 1)) # den 2 rock
	_draw_tile(Rect2(-200, 340, 120, 100), Color(0.34, 0.30, 0.24, 1)) # den 3 rock
	# Signal fire clearing (south)
	_draw_tile(Rect2(-120, 460, 240, 180), Color(0.44, 0.38, 0.24, 1)) # signal fire ground
	_draw_tile(Rect2(-16, 500, 32, 40), Color(0.92, 0.52, 0.12, 0.85)) # fire glow
	# Stream (east)
	_draw_tile(Rect2(380, -400, 28, 700), Color(0.44, 0.72, 0.90, 0.70)) # east brook
	# Boundary walls
	_draw_wall(Rect2(-920, -730, 20, 1460))
	_draw_wall(Rect2(900, -730, 20, 1460))
	_draw_wall(Rect2(-920, -730, 1840, 20))
	_draw_wall(Rect2(-920, 730, 1840, 20))


# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# "Rest secure in him" – Deuteronomy 33:12
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder Benjamin — moonlit clearing centre
	_build_npc("elder_benjamin", Vector3(0, 0, 0))
	# Young wolf-shepherd — east brook
	_build_npc("shepherd_muppim", Vector3(440, 0, 80))
	# Night watchwoman — signal fire south
	_build_npc("watchwoman_ard", Vector3(-40, 0, 520))
	# Hidden hermit — deep west pine
	_build_npc("hermit_gera", Vector3(-640, 0, -80))


# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# "He will rest between his shoulders" – Deuteronomy 33:12
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	# Main chest — moonlit clearing
	_chest(Vector3(0, 0, 80), "benjamin_chest_deut3312", "Deuteronomy 33:12")
	# Den 1 hidden chest — west boulders
	_chest(Vector3(-380, 0, -300), "benjamin_chest_zeph317", "Zephaniah 3:17")
	# Signal fire chest — south clearing
	_chest(Vector3(40, 0, 520), "benjamin_chest_psalm4610", "Psalm 46:10")
	# Deep pine chest — hermit's cave
	_chest(Vector3(-680, 0, -120), "benjamin_chest_esther49", "Esther 4:14")


func on_quest_ready() -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{ "name": elder, "text": "My child, shalom. You have come to the youngest tribe — and the most beloved. Benjamin means 'son of my right hand'. The smallest, and yet held closest." },
			{ "name": elder, "text": "The Jasper stone — warm like sunrise — rests where the wolf pack rests. To earn it, you must show precision and protection. Both are gifts of Benjamin." },
			{ "name": "You", "text": "Please, elder — I am ready." },
			{
				"name": elder,
				"text": "Strike with precision first. The wolf does not waste a move. Each tap must land true.",
				"callback": Callable(self, "_start_precision"),
			},
		],
	)


var _precision_result: Dictionary = { }
var _protection_result: Dictionary = { }


func _start_precision() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	var goal := 8 if Global.selected_avatar == "esther_b" else 10
	_precision_result = build_tap_minigame(
		container,
		goal,
		"Tap each target with precision!\nStrike true — Benjamin strikes like the Wolf.",
		20.0,
	)


func _after_precision() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{ "name": elder, "text": "Precise and steady! Now the greater test — protection. The smallest members of the pack are in danger. Swipe to shield them." },
			{
				"name": elder,
				"text": "The wolf pack raises every pup together. No pup left behind. That is the heart of Benjamin.",
				"callback": Callable(self, "_start_protection"),
			},
		],
	)


func _start_protection() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	for child in container.get_children():
		child.queue_free()
	var goal := 6 if Global.selected_avatar == "nia_b" else 8
	_protection_result = build_swipe_minigame(
		container,
		goal,
		"Swipe to shield the vulnerable!\nGuard them — God shields you the same way.",
		18.0,
	)


func _after_protection() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "Every one of them is safe. God sees your heart. You have finished all twelve paths. Now — receive the final word, and carry it to the courtyard.",
				"callback": Callable(self, "_show_quest_verse"),
			},
		],
	)


func _show_quest_verse() -> void:
	show_verse_scroll(
		_tribe_data.get("quest_verse_ref", ""),
		_tribe_data.get("quest_verse", ""),
	)


func on_minigame_complete(result: Dictionary) -> void:
	if result.get("root") == _precision_result.get("root"):
		_after_precision()
	elif result.get("root") == _protection_result.get("root"):
		_after_protection()


func on_minigame_timeout(result: Dictionary) -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	if result.get("root") == _precision_result.get("root"):
		show_dialogue([{ "name": elder, "text": "Let's try again together. God is patient on every path." }])
		get_tree().create_timer(1.2).timeout.connect(
			func():
				for child in _mini_game_container.get_children():
					child.queue_free()
				_precision_result = build_tap_minigame(_mini_game_container, 10, "Tap each target with precision!", 20.0),
			CONNECT_ONE_SHOT,
		)
	elif result.get("root") == _protection_result.get("root"):
		show_dialogue([{ "name": elder, "text": "Let's try once more. None are forgotten." }])
		get_tree().create_timer(1.2).timeout.connect(
			func():
				for child in _mini_game_container.get_children():
					child.queue_free()
				_protection_result = build_swipe_minigame(_mini_game_container, 8, "Swipe to shield the vulnerable!", 18.0),
			CONNECT_ONE_SHOT,
		)
