extends "res://scripts/WorldBase.gd"

# ─────────────────────────────────────────────────────────────────────────────
# Quest11.gd  –  Tribe of Joseph
# Mini-game 1: Growth Tap — tap to tend the garden (12 taps, 22 s)
# Mini-game 2: Forgiveness Choice — dialogue choice mini-game (4 choices)
# Verse: Genesis 50:20  |  Nature: Pearl / Romans 8:28
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key = "joseph"
	quest_id = "joseph_main"
	next_scene = "res://scenes/Quest12.tscn"
	world_name = "Vineyard Valley"
	# Genesis 49:22 – Joseph is a fruitful bough, a fruitful bough by a spring
	music_path = "res://assets/audio/music/desert_sanctuary_main_theme.wav"
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
# TERRAIN
# "God intended it for good" – Genesis 50:20
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# "Joseph is a fruitful vine, a fruitful vine near a spring" – Genesis 49:22
	# Base fertile valley (rich brown soil)
	_draw_tile(Rect2(-900, -700, 1800, 1400), Color(0.42, 0.30, 0.18, 1), "soil") # rich soil
	# Vine row terraces (horizontal bands, alternating green + path)
	for row in range(7):
		var rz := -600 + row * 180
		_draw_tile(Rect2(-700, rz, 1400, 80), Color(0.30, 0.52, 0.18, 1)) # vine leaves
		_draw_tile(Rect2(-700, rz + 80, 1400, 80), Color(0.50, 0.40, 0.22, 1)) # vine path
	# Central north-south road
	_draw_tile(Rect2(-48, -700, 96, 1400), Color(0.58, 0.46, 0.28, 1)) # central road
	# Dream well clearing (centre)
	_draw_tile(Rect2(-160, -80, 320, 300), Color(0.46, 0.56, 0.30, 1)) # well courtyard
	_draw_tile(Rect2(-28, -20, 56, 56), Color(0.28, 0.28, 0.30, 1)) # well mouth
	# Brother's pit area (west low ground)
	_draw_tile(Rect2(-900, -200, 240, 400), Color(0.34, 0.24, 0.14, 1)) # pit depression
	# Grain silo district (east)
	_draw_tile(Rect2(540, -300, 360, 500), Color(0.68, 0.58, 0.38, 1)) # silo plaza
	# Spring / river source (far north)
	_draw_tile(Rect2(-80, -700, 160, 200), Color(0.44, 0.72, 0.88, 0.80)) # spring pool
	# Boundary walls
	_draw_wall(Rect2(-920, -730, 20, 1460))
	_draw_wall(Rect2(900, -730, 20, 1460))
	_draw_wall(Rect2(-920, -730, 1840, 20))
	_draw_wall(Rect2(-920, 730, 1840, 20))


# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# "You intended to harm me" – Genesis 50:20
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder Joseph — beside the dream well (centre)
	_build_npc("elder_joseph", Vector3(0, 0, 80))
	# Brother Manasseh — grain silo district
	_build_npc("manasseh", Vector3(620, 0, -80))
	# Brother Ephraim — vine terrace east
	_build_npc("ephraim", Vector3(420, 0, 260))
	# Servant girl — spring pool north
	_build_npc("servant_asenath", Vector3(-20, 0, -620))


# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# "For the saving of many lives" – Genesis 50:20
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	# Dream well chest — main verse
	_chest(Vector3(40, 0, 40), "joseph_chest_gen5020", "Genesis 50:20")
	# Pit area chest (forgiveness)
	_chest(Vector3(-660, 0, 80), "joseph_chest_romans828", "Romans 8:28")
	# Grain silo chest — east plaza
	_chest(Vector3(640, 0, 100), "joseph_chest_gen4922", "Genesis 49:22")
	# Spring source chest — far north
	_chest(Vector3(0, 0, -640), "joseph_chest_john737", "John 7:37-38")


# ─────────────────────────────────────────────────────────────────────────────
# SIDE QUEST OBJECTS
# "God causes all things to work together for good" – Romans 8:28
# ─────────────────────────────────────────────────────────────────────────────
func _place_side_quest_objects() -> void:
	# Collect flowers blessing — scattered through vine rows
	_place_collectible(Vector3(120, 1, -300), "flower", Callable(self, "_on_flower_collected"))
	_place_collectible(Vector3(-180, 1, 120), "flower", Callable(self, "_on_flower_collected"))
	_place_collectible(Vector3(300, 1, 400), "flower", Callable(self, "_on_flower_collected"))
	_place_collectible(Vector3(-200, 1, -480), "flower", Callable(self, "_on_flower_collected"))
	_place_collectible(Vector3(500, 1, -200), "flower", Callable(self, "_on_flower_collected"))
	_place_collectible(Vector3(-420, 1, 340), "flower", Callable(self, "_on_flower_collected"))


func _on_flower_collected() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/stone_collect.wav")
	show_dialogue(
		[
			{
				"name": "You",
				"text": "A beautiful flower in Joseph's garden! God makes beauty from hardship.",
				"callback": Callable(self, "_show_flower_fact"),
			},
		],
	)


func _show_flower_fact() -> void:
	show_nature_fact()


func on_quest_ready() -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{ "name": elder, "text": "My child, shalom. You stand in the garden of Joseph — once a pit, now a palace garden. God turned every wound into wonder." },
			{ "name": elder, "text": "The Onyx stone — dark and deep, like the pit — rests at the top of the garden wall. Tend the garden first. Then face the greater test: forgiveness." },
			{ "name": "You", "text": "Please, elder — I am ready to learn." },
			{
				"name": elder,
				"text": "Water the plants, remove the thorns. Each tap is a choice to nurture what God has planted, not destroy it.",
				"callback": Callable(self, "_start_growth"),
			},
		],
	)


var _growth_result: Dictionary = { }
var _forgiveness_result: Dictionary = { }


func _start_growth() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	var goal := 10 if Global.selected_avatar == "joseph_w" else 12
	_growth_result = build_tap_minigame(
		container,
		goal,
		"Tend the garden!\nTap to water and nurture — God grows what we plant.",
		22.0,
	)


func _after_growth() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{ "name": elder, "text": "The garden flourishes! Now — the brothers who sold Joseph stand before you. He had every reason for bitterness. He chose something greater." },
			{
				"name": elder,
				"text": "\"You intended to harm me, but God intended it for good.\" Choose: hold the hurt, or release it?",
				"callback": Callable(self, "_start_forgiveness"),
			},
		],
	)


func _start_forgiveness() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	for child in container.get_children():
		child.queue_free()
	_forgiveness_result = build_dialogue_choice_minigame(
		container,
		4,
		"Your brothers stand before you.\nChoose the path of Joseph.",
	)


func _after_forgiveness() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "You chose as Joseph chose. God sees your heart. Now — receive the word that Ephraim's children carried through every hard season.",
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
	if result.get("root") == _growth_result.get("root"):
		_after_growth()
	elif result.get("root") == _forgiveness_result.get("root"):
		_after_forgiveness()


func on_minigame_timeout(result: Dictionary) -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	if result.get("root") == _growth_result.get("root"):
		show_dialogue([{ "name": elder, "text": "Growth takes patience — let's tend the garden once more. God is patient with us too." }])
		get_tree().create_timer(1.2).timeout.connect(
			func():
				for child in _mini_game_container.get_children():
					child.queue_free()
				_growth_result = build_tap_minigame(_mini_game_container, 12, "Tend the garden!", 22.0)
			,
			CONNECT_ONE_SHOT,
		)
	elif result.get("root") == _forgiveness_result.get("root"):
		show_dialogue([{ "name": elder, "text": "Forgiveness is difficult — Joseph wrestled with it too. Let's try again together." }])
		get_tree().create_timer(1.2).timeout.connect(
			func():
				for child in _mini_game_container.get_children():
					child.queue_free()
				_forgiveness_result = build_dialogue_choice_minigame(_mini_game_container, 4, "Choose the path of Joseph."),
			CONNECT_ONE_SHOT,
		)
