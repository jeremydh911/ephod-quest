extends "res://scripts/WorldBase.gd"

# ─────────────────────────────────────────────────────────────────────────────
# Quest7.gd  –  Tribe of Gad
# Map: Mountain stronghold.
# Mini-game 1: Tower Defense — place defenses, hold the line (10 waves, 25 s).
# Mini-game 2: Endurance Race — sustained running (hold button, 20 s).
# Verse: Hebrews 12:1  |  Nature: Olive tree / Hebrews 12:1
# "Let us run with perseverance the race marked out for us" – Hebrews 12:1
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key = "gad"
	quest_id = "gad_main"
	next_scene = "res://scenes/Quest8.tscn"
	world_name = "Mountain Stronghold"
	# Genesis 49:19 – Gad, a troop shall press upon him; he shall press back
	music_path = "res://assets/audio/music/gather_the_tribes_2.wav"
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
# "Let us run with perseverance" – Hebrews 12:1
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# "Gad will be attacked by a band of raiders, but he will attack at their heels" – Genesis 49:19
	# Base mountain rock floor
	_draw_tile(Rect2(-900, -700, 1800, 1400), Color(0.42, 0.36, 0.28, 1), "rock") # mountain base
	# High ridge path (centre-south axis)
	_draw_tile(Rect2(-80, -700, 160, 1400), Color(0.52, 0.46, 0.38, 1)) # ridge road
	# Summit plateau (north)
	_draw_tile(Rect2(-340, -700, 680, 340), Color(0.60, 0.52, 0.42, 1)) # summit
	_draw_tile(Rect2(-200, -720, 400, 80), Color(0.68, 0.60, 0.48, 1)) # peak capstone
	# Fort interior (centre)
	_draw_tile(Rect2(-280, -200, 560, 480), Color(0.50, 0.44, 0.36, 1)) # fort courtyard
	# West terrace — olive grove
	_draw_tile(Rect2(-900, -280, 480, 560), Color(0.34, 0.46, 0.24, 1)) # olive terrace
	# East rocky outcrop
	_draw_tile(Rect2(500, -400, 400, 600), Color(0.38, 0.32, 0.24, 1)) # east outcrop
	# Brook runoff (north-west)
	_draw_tile(Rect2(-600, -580, 28, 400), Color(0.36, 0.62, 0.84, 0.72)) # stream
	# Boundary walls
	_draw_wall(Rect2(-920, -730, 20, 1460))
	_draw_wall(Rect2(900, -730, 20, 1460))
	_draw_wall(Rect2(-920, -730, 1840, 20))
	_draw_wall(Rect2(-920, 730, 1840, 20))


# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# "The race marked out for us" – Hebrews 12:1
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder Zephon — fort entrance (centre south)
	_build_npc("elder_zephon", Vector3(0, 0, 200))
	# Warrior scout — east outcrop lookout
	_build_npc("scout_haggi", Vector3(560, 0, -140))
	# Shepherd — olive grove west
	_build_npc("shepherd_shuni", Vector3(-560, 0, 80))


# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# "Fixing our eyes on Jesus" – Hebrews 12:2
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	# Summit chest — peak capstone
	_chest(Vector3(0, 0, -600), "gad_chest_hebrews12", "Hebrews 12:1")
	# Fort interior chest — hidden alcove
	_chest(Vector3(-220, 0, -60), "gad_chest_deuteronomy", "Deuteronomy 33:20")
	# Olive terrace chest — grove west
	_chest(Vector3(-620, 0, 60), "gad_chest_psalm23", "Psalm 23:4")
	# East outcrop chest — behind rocks
	_chest(Vector3(620, 0, -200), "gad_chest_isaiah", "Isaiah 40:31")


func on_quest_ready() -> void:
	var elder: String = Global.get_tribe_data(tribe_key).get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "My child, shalom! The mountain stronghold stands firm against invaders. The Ligure stone — striped like Gad's warriors — waits at the peak.",
			},
			{
				"name": elder,
				"text": "Gad chose the best land for his people, but it required perseverance. Like olive trees that live for centuries, he endured. \"Let us run with perseverance...\", he taught.",
			},
			{
				"name": "You",
				"text": "Please, Elder Zephon — how do I reach the stone?",
			},
			{
				"name": elder,
				"text": "First, defend the stronghold! Place your towers wisely as waves approach. Then, run the endurance race up the mountain.",
				"callback": Callable(self, "_start_tower_defense"),
			},
		],
	)

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — TOWER DEFENSE (place defenses)
# ─────────────────────────────────────────────────────────────────────────────
var _defense_result: Dictionary = { }
var _race_result: Dictionary = { }


func _start_tower_defense() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	_defense_result = build_tower_defense_minigame(
		container,
		10,
		"Place towers to defend the stronghold!\nHold the line against invaders.",
		25.0,
	)


func _continue_after_defense() -> void:
	await get_tree().create_timer(1.5).timeout
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "Stronghold defended! You showed perseverance. Now — the final climb requires endurance. Run steadily to the peak!",
			},
			{
				"name": elder,
				"text": "Like the olive tree that endures for generations, keep running. God gives strength to those who persevere.",
				"callback": Callable(self, "_start_endurance_race"),
			},
		],
	)


# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 2 — ENDURANCE RACE (sustained effort)
# ─────────────────────────────────────────────────────────────────────────────
func _start_endurance_race() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	for child in container.get_children():
		child.queue_free()
	# Hebrews 12:1 — "run with perseverance the race marked out for us"
	_race_result = build_rhythm_minigame(
		container,
		0.5,
		20,
		14,
		"Run the endurance race!\nKeep the rhythm — hold the pace steadily to the finish.",
	)


func _on_race_complete() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "Endurance rewarded! You ran with perseverance. Now — let me share the words that Gad carried through the mountains.",
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
	if result.get("root") == _defense_result.get("root"):
		_continue_after_defense()
	elif result.get("root") == _race_result.get("root"):
		_on_race_complete()


func on_minigame_timeout(result: Dictionary) -> void:
	if result.get("root") == _defense_result.get("root"):
		_continue_after_defense()
	elif result.get("root") == _race_result.get("root"):
		_on_race_complete()
