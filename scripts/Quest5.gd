extends "res://scripts/WorldBase.gd"

# ─────────────────────────────────────────────────────────────────────────────
# Quest5.gd  –  Tribe of Naphtali
# Map: Forest clearing at night, stars overhead.
# Mini-game 1: Run Dash — swipe left/right to dodge obstacles (8 dodges, 15 s).
# Mini-game 2: Praise Poem — tap rhythm to complete verse (tap on beats).
# Verse: Psalm 19:14  |  Nature: Doe / Psalm 19:14
# "Let the words of my mouth and the meditation of my heart be acceptable in your sight" – Psalm 19:14
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key = "naphtali"
	quest_id = "naphtali_main"
	next_scene = "res://scenes/Quest6.tscn"
	world_name = "Night Forest"
	# Genesis 49:21 – Naphtali is a doe set free that bears beautiful fawns
	music_path = "res://assets/audio/music/naphtali_theme.wav"
	world_bounds = Rect2(-900, -700, 1800, 1400)
	super._ready()


func on_world_ready() -> void:
	super.on_world_ready() # 3D sky + directional light – Psalm 19:1
	_build_terrain()
	_place_npcs()
	_place_chests()
	_place_side_quest_objects()
	_show_world_intro()


# ─────────────────────────────────────────────────────────────────────────────
# SIDE QUEST OBJECTS
# "Butterflies taste with their feet" – Real science, God's design
# ─────────────────────────────────────────────────────────────────────────────
func _place_side_quest_objects() -> void:
	# naphtali_good_news – 4 message scrolls scattered in forest
	_place_collectible(Vector3(80, 1, 60), "message_scroll", Callable(SideQuestManager, "collect_item").bind("naphtali_good_news", self))
	_place_collectible(Vector3(-120, 1, -80), "message_scroll", Callable(SideQuestManager, "collect_item").bind("naphtali_good_news", self))
	_place_collectible(Vector3(160, 1, -200), "message_scroll", Callable(SideQuestManager, "collect_item").bind("naphtali_good_news", self))
	_place_collectible(Vector3(-200, 1, 220), "message_scroll", Callable(SideQuestManager, "collect_item").bind("naphtali_good_news", self))
	# Butterfly collectibles (nature discovery)
	_place_collectible(Vector3(40, 1, 40), "butterfly", Callable(self, "_on_butterfly_collected"))
	_place_collectible(Vector3(-60, 1, 80), "butterfly", Callable(self, "_on_butterfly_collected"))
	_place_collectible(Vector3(100, 1, 150), "butterfly", Callable(self, "_on_butterfly_collected"))
	# Glowing fireflies near south clearing
	_place_collectible(Vector3(-80, 1, 260), "firefly", Callable(self, "_on_butterfly_collected"))
	_place_collectible(Vector3(60, 1, 300), "firefly", Callable(self, "_on_butterfly_collected"))


func _on_butterfly_collected() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/stone_collect.wav")
	show_dialogue(
		[
			{
				"name": "You",
				"text": "A beautiful butterfly! God made such wonders.",
				"callback": Callable(self, "_show_butterfly_fact"),
			},
		],
	)


func _show_butterfly_fact() -> void:
	show_nature_fact()


# ─────────────────────────────────────────────────────────────────────────────
# TERRAIN
# "The heavens declare the glory of God" – Psalm 19:1
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# "Naphtali is a doe set free that bears beautiful fawns" – Genesis 49:21
	# Night sky backplane
	_draw_tile(Rect2(-900, -700, 1800, 400), Color(0.04, 0.04, 0.14, 1)) # midnight sky
	# Moonlit forest floor clearing (centre)
	_draw_tile(Rect2(-400, -300, 800, 560), Color(0.22, 0.32, 0.18, 1)) # grass clearing
	# Dark pine forest zones (edges)
	_draw_tile(Rect2(-900, -300, 500, 900), Color(0.08, 0.14, 0.06, 1)) # west pine
	_draw_tile(Rect2(400, -300, 500, 900), Color(0.08, 0.14, 0.06, 1)) # east pine
	_draw_tile(Rect2(-900, -700, 1800, 400), Color(0.06, 0.10, 0.04, 1)) # north deep forest
	# Crystal stream (cuts south)
	_draw_tile(Rect2(-16, -300, 32, 600), Color(0.52, 0.78, 0.92, 0.80)) # stream
	# Moon glow pool (centre-north)
	_draw_tile(Rect2(-100, -380, 200, 140), Color(0.70, 0.80, 0.60, 0.55)) # moon pool
	# Firefly clearing (south)
	_draw_tile(Rect2(-180, 200, 360, 260), Color(0.28, 0.40, 0.22, 1)) # bright clearing
	# Rock outcrops
	_draw_tile(Rect2(260, -140, 140, 120), Color(0.36, 0.32, 0.26, 1)) # east rock
	_draw_tile(Rect2(-380, -80, 120, 100), Color(0.36, 0.32, 0.26, 1)) # west rock
	# Boundary walls
	_draw_wall(Rect2(-920, -730, 20, 1460))
	_draw_wall(Rect2(900, -730, 20, 1460))
	_draw_wall(Rect2(-920, -730, 1840, 20))
	_draw_wall(Rect2(-920, 730, 1840, 20))


# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# "Let the words of my mouth... be acceptable" – Psalm 19:14
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder Jahzeel — clearing centre, main quest giver
	_build_npc("elder_jahzeel", Vector3(0, 0, 0))
	# Shepherd daughter — near crystal stream
	_build_npc("shepherd_tirzah", Vector3(-80, 0, 120))
	# Night watcher — east rock outcrop
	_build_npc("watcher_oren", Vector3(300, 0, -100))


# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# "The meditation of my heart be acceptable in your sight" – Psalm 19:14
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	# Isaiah 52:7 — beautiful feet on the mountains (main quest verse)
	_chest(Vector3(10, 0, 10), "naphtali_chest_isaiah", "Isaiah 52:7")
	# Psalm 19:14 — words of mouth acceptable in God's sight
	_chest(Vector3(320, 0, -180), "naphtali_chest_psalm19", "Psalm 19:14")
	# Genesis 49:21 — doe set free
	_chest(Vector3(-260, 0, 280), "naphtali_chest_genesis", "Genesis 49:21")
	# Psalm 104:20 — darkness comes, creatures of night move
	_chest(Vector3(-360, 0, -240), "naphtali_chest_night", "Psalm 104:20")


func on_quest_ready() -> void:
	var elder: String = Global.get_tribe_data(tribe_key).get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "My child, shalom! The forest clearing opens before us, under the watchful stars. The Diamond stone — clear as truth — waits where the swift deer run.",
			},
			{
				"name": elder,
				"text": "Naphtali was blessed with beautiful words. Like a doe set free, his speech brought grace. \"Let the words of my mouth...\", he prayed each morning.",
			},
			{
				"name": "You",
				"text": "Please, Elder Jahzeel — how do I find the stone?",
			},
			{
				"name": elder,
				"text": "Run with the deer! Swipe left and right to dodge the fallen branches. Swift feet, swift heart. God gives speed to those who follow Him.",
				"callback": Callable(self, "_start_run_dash"),
			},
		],
	)

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — RUN DASH (swipe to dodge)
# ─────────────────────────────────────────────────────────────────────────────
var _dash_result: Dictionary = { }
var _poem_result: Dictionary = { }


func _start_run_dash() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	_dash_result = build_swipe_minigame(
		container,
		8,
		"Swipe left/right to dodge the branches!\nRun like the deer — swift and sure.",
		15.0,
	)


func _continue_after_dash() -> void:
	await get_tree().create_timer(1.5).timeout
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "Excellent! You ran with grace. Now listen — the stars above whisper a poem of praise. Tap the rhythm as the words appear!",
			},
			{
				"name": elder,
				"text": "Feel the beat of creation. Each tap completes the verse. \"Let the words of my mouth...\"",
				"callback": Callable(self, "_start_praise_poem"),
			},
		],
	)


# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 2 — PRAISE POEM (rhythm tap)
# ─────────────────────────────────────────────────────────────────────────────
func _start_praise_poem() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	for child in container.get_children():
		child.queue_free()
	if Global.selected_avatar == "ezra_n":
		var hint := Label.new()
		hint.text = "★ Clue: tap on the 2nd, 4th, 6th, and 8th beats"
		hint.add_theme_font_size_override("font_size", 13)
		hint.modulate = Color(0.4, 0.7, 0.2, 1)
		container.add_child(hint)
	_poem_result = build_rhythm_minigame(
		container,
		1.0,
		8,
		4,
		"Tap when the words pulse!\nComplete the verse of praise.",
	)


func _on_poem_complete() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "Perfect harmony! You spoke with beauty. Now — let me share the words that Naphtali carried through the ages.",
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
	if result.get("root") == _dash_result.get("root"):
		_continue_after_dash()
	elif result.get("root") == _poem_result.get("root"):
		_on_poem_complete()


func on_minigame_timeout(result: Dictionary) -> void:
	if result.get("root") == _dash_result.get("root"):
		_continue_after_dash()
	elif result.get("root") == _poem_result.get("root"):
		_on_poem_complete()
