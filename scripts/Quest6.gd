extends "res://scripts/WorldBase.gd"

# ─────────────────────────────────────────────────────────────────────────────
# Quest6.gd  –  Tribe of Simeon
# Map: Desert border crossing / arbiter's tent.
# Mini-game 1: Justice Scales — sort deeds into just/unjust (8 sorts, 20 s).
# Mini-game 2: Peace Negotiation — choose dialogue options (4 choices).
# Verse: Psalm 46:10  |  Nature: Sheep / Psalm 46:10
# "Be still, and know that I am God" – Psalm 46:10
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key = "simeon"
	quest_id = "simeon_main"
	next_scene = "res://scenes/Quest7.tscn"
	world_name = "Desert Border Crossing"
	# Lamentations 3:23 – Great is His faithfulness; new every morning
	music_path = "res://assets/audio/music/simeon_theme.wav"
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
# "Be still, and know that I am God" – Psalm 46:10
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# "Simeon and Levi are brothers … weapons of violence are their swords" – Genesis 49:5
	# Vast sandy desert floor
	_draw_tile(Rect2(-900, -700, 1800, 1400), Color(0.84, 0.72, 0.46, 1), "sand") # main desert
	# Dune ridges (north)
	_draw_tile(Rect2(-900, -700, 1800, 300), Color(0.78, 0.64, 0.38, 1)) # far dune bank
	_draw_tile(Rect2(-700, -420, 560, 180), Color(0.82, 0.70, 0.44, 1)) # mid dune 1
	_draw_tile(Rect2(260, -380, 420, 160), Color(0.82, 0.70, 0.44, 1)) # mid dune 2
	# Oasis pool (west)
	_draw_tile(Rect2(-580, -100, 200, 160), Color(0.34, 0.62, 0.80, 0.78)) # oasis water
	_draw_tile(Rect2(-640, -160, 340, 300), Color(0.40, 0.56, 0.30, 1)) # palm grass
	# Arbiter's tent clearing (centre)
	_draw_tile(Rect2(-140, -100, 280, 280), Color(0.70, 0.58, 0.36, 1)) # tent courtyard
	# Rocky border ridge (east)
	_draw_tile(Rect2(540, -500, 200, 900), Color(0.52, 0.40, 0.28, 1)) # rocky ridge
	_draw_tile(Rect2(700, -600, 180, 1100), Color(0.46, 0.36, 0.24, 1)) # far rock
	# Boundary walls
	_draw_wall(Rect2(-920, -730, 20, 1460))
	_draw_wall(Rect2(900, -730, 20, 1460))
	_draw_wall(Rect2(-920, -730, 1840, 20))
	_draw_wall(Rect2(-920, 730, 1840, 20))


# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# "I will be exalted among the nations" – Psalm 46:10
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder Nemuel — inside arbiter's tent (centre clearing)
	_build_npc("elder_nemuel", Vector3(0, 0, 0))
	# Merchant traveller — oasis edge
	_build_npc("traveller_darda", Vector3(-380, 0, 20))
	# Gatekeeper — east ridge path
	_build_npc("gatekeeper_jamin", Vector3(460, 0, -80))


# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# "I will be exalted in the earth" – Psalm 46:10
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	# Main verse chest — beneath arbiter's canopy
	_chest(Vector3(15, 0, 15), "simeon_chest_psalm46", "Psalm 46:10")
	# Oasis hidden chest — behind palm trees
	_chest(Vector3(-480, 0, 60), "simeon_chest_lament", "Lamentations 3:22-23")
	# Ridge lookout chest — east boulder
	_chest(Vector3(560, 0, 120), "simeon_chest_proverbs", "Proverbs 21:3")
	# Deep desert chest — north dune
	_chest(Vector3(-260, 0, -380), "simeon_chest_micah", "Micah 6:8")


func on_quest_ready() -> void:
	var elder: String = Global.get_tribe_data(tribe_key).get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "My child, shalom! The desert border stretches before us, where disputes arise like sandstorms. The Ligure stone — striped like justice — waits in the arbiter's tent.",
			},
			{
				"name": elder,
				"text": "Simeon and Levi once acted hastily in anger. But Simeon learned to be still, to know that God is God. \"Be still, and know that I am God\", he came to understand.",
			},
			{
				"name": "You",
				"text": "Please, Elder Nemuel — how do I find the stone?",
			},
			{
				"name": elder,
				"text": "First, balance the scales of justice. Sort the deeds fairly — some are just, some unjust. Then, negotiate peace with wisdom.",
				"callback": Callable(self, "_start_justice_scales"),
			},
		],
	)

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — JUSTICE SCALES (sorting)
# ─────────────────────────────────────────────────────────────────────────────
var _scales_result: Dictionary = { }
var _negotiation_result: Dictionary = { }


func _start_justice_scales() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	_scales_result = build_sorting_minigame(
		container,
		8,
		"Sort deeds into Just or Unjust piles!\nBalance the scales of righteousness.",
		20.0,
	)


func _continue_after_scales() -> void:
	await get_tree().create_timer(1.5).timeout
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "Well balanced! Justice requires wisdom. Now — two travelers approach with a dispute. Choose your words carefully to bring peace.",
			},
			{
				"name": elder,
				"text": "Remember: \"Be still, and know that I am God.\" Sometimes silence and wisdom speak louder than words.",
				"callback": Callable(self, "_start_peace_negotiation"),
			},
		],
	)


# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 2 — PEACE NEGOTIATION (dialogue choices)
# ─────────────────────────────────────────────────────────────────────────────
func _start_peace_negotiation() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	for child in container.get_children():
		child.queue_free()
	_negotiation_result = build_dialogue_choice_minigame(
		container,
		4,
		"Choose dialogue options to resolve the dispute!\nWisdom brings peace.",
	)


func _on_negotiation_complete() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "Peace restored! You spoke with wisdom. Now — let me share the words that Simeon carried through the desert.",
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
	if result.get("root") == _scales_result.get("root"):
		_continue_after_scales()
	elif result.get("root") == _negotiation_result.get("root"):
		_on_negotiation_complete()


func on_minigame_timeout(result: Dictionary) -> void:
	if result.get("root") == _scales_result.get("root"):
		_continue_after_scales()
	elif result.get("root") == _negotiation_result.get("root"):
		_on_negotiation_complete()
