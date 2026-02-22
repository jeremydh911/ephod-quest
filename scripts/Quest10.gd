extends "res://scripts/WorldBase.gd"

# ─────────────────────────────────────────────────────────────────────────────
# Quest10.gd  –  Tribe of Zebulun
# Mini-game 1: Sailing Swipe — swipe to dodge waves (10, 20 s)
# Mini-game 2: Hospitality Tap — tap to welcome each traveller (8, 18 s)
# Verse: Romans 15:7  |  Nature: Clownfish & anemone / Ecclesiastes 4:9
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key = "zebulun"
	quest_id = "zebulun_main"
	next_scene = "res://scenes/Quest11.tscn"
	world_name = "Coastal Harbour"
	# Genesis 49:13 – Zebulun shall dwell at the shore of the sea
	music_path = "res://assets/audio/music/gathering_at_the_gates.wav"
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
# "Haven for ships" – Genesis 49:13
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# "Zebulun will live by the seashore and become a haven for ships" – Genesis 49:13
	# Deep ocean (far north)
	_draw_tile(Rect2(-900, -700, 1800, 400), Color(0.16, 0.38, 0.72, 0.92)) # ocean deep
	# Shallow harbour water
	_draw_tile(Rect2(-900, -300, 1800, 380), Color(0.34, 0.60, 0.86, 0.82)) # harbour water
	# Sandy beach (wide strip)
	_draw_tile(Rect2(-900, 80, 1800, 260), Color(0.88, 0.80, 0.56, 1), "sand") # beach
	# Dock planks (extend into water)
	_draw_tile(Rect2(-60, -380, 120, 460), Color(0.48, 0.36, 0.22, 1)) # main dock
	_draw_tile(Rect2(240, -280, 80, 380), Color(0.46, 0.34, 0.20, 1)) # west pier
	_draw_tile(Rect2(-340, -220, 80, 320), Color(0.46, 0.34, 0.20, 1)) # east pier
	# Boat hulls (flat coloured pad + wall above = hull)
	_draw_tile(Rect2(300, -220, 200, 100), Color(0.62, 0.44, 0.28, 1)) # boat 1
	_draw_tile(Rect2(-500, -180, 160, 90), Color(0.58, 0.42, 0.26, 1)) # boat 2
	# Market stall row (south beach)
	_draw_tile(Rect2(-720, 100, 1440, 180), Color(0.78, 0.64, 0.42, 1)) # market floor
	# Cliff face (east)
	_draw_tile(Rect2(680, -400, 220, 900), Color(0.50, 0.44, 0.36, 1)) # east cliff
	_draw_tile(Rect2(820, -700, 80, 1400), Color(0.44, 0.38, 0.30, 1)) # cliff wall
	# Inland path (south)
	_draw_tile(Rect2(-60, 340, 120, 360), Color(0.60, 0.50, 0.34, 1)) # inland road
	_draw_tile(Rect2(-900, 340, 1800, 360), Color(0.54, 0.46, 0.30, 1)) # town square
	# Boundary walls
	_draw_wall(Rect2(-920, -730, 20, 1460))
	_draw_wall(Rect2(900, -730, 20, 1460))
	_draw_wall(Rect2(-920, -730, 1840, 20))
	_draw_wall(Rect2(-920, 730, 1840, 20))


# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# "Accept one another" – Romans 15:7
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder Zebulun at the dock end
	_build_npc("elder_zebulon", Vector3(0, 0, 60))
	# Fisherman — west pier
	_build_npc("fisherman_sered", Vector3(-400, 0, 80))
	# Merchant — market stalls south
	_build_npc("merchant_elon", Vector3(300, 0, 200))
	# Cliff watchman — east cliff edge
	_build_npc("watchman_jahleel", Vector3(740, 0, -140))


# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# "Just as Christ accepted you" – Romans 15:7
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	# Dock end chest — main verse
	_chest(Vector3(15, 0, 60), "zebulun_chest_romans157", "Romans 15:7")
	# Boat hold chest — hull of boat 1
	_chest(Vector3(360, 0, -160), "zebulun_chest_gen4913", "Genesis 49:13")
	# Market hidden chest — behind merchant stall
	_chest(Vector3(-560, 0, 180), "zebulun_chest_eccl49", "Ecclesiastes 4:9")
	# Cliff lookout chest
	_chest(Vector3(760, 0, -300), "zebulun_chest_matt413", "Matthew 4:13-14")


func on_quest_ready() -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{ "name": elder, "text": "My child, shalom! The harbour is open, the sea is wide. Zebulun was a haven for ships — and for weary souls. The Beryl stone waits beyond the waves." },
			{ "name": elder, "text": "\"Accept one another, just as Christ accepted you.\" That is our word. But first — guide our boat safely to shore. Swipe left and right to steer." },
			{ "name": "You", "text": "Please, elder — how do I keep the boat steady?" },
			{
				"name": elder,
				"text": "Watch the waves and move with them, not against them. God placed calm water between every storm.",
				"callback": Callable(self, "_start_sailing"),
			},
		],
	)


var _sailing_result: Dictionary = { }
var _hospitality_result: Dictionary = { }


func _start_sailing() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	var goal := 8 if Global.selected_avatar == "marina_z" else 10
	_sailing_result = build_swipe_minigame(
		container,
		goal,
		"Swipe left/right to steer through the waves!\nGod calms the storm.",
		20.0,
	)


func _after_sailing() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{ "name": elder, "text": "Safe harbour! Now — travellers are arriving, tired and hungry. Tap to welcome each one as they step ashore." },
			{
				"name": elder,
				"text": "Hospitality is worship. Every open hand mirrors the hands of God.",
				"callback": Callable(self, "_start_hospitality"),
			},
		],
	)


func _start_hospitality() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	for child in container.get_children():
		child.queue_free()
	_hospitality_result = build_tap_minigame(
		container,
		8,
		"Welcome each traveller!\nTap as they arrive — an open hand, an open heart.",
		18.0,
	)


func _after_hospitality() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue(
		[
			{
				"name": elder,
				"text": "Every stranger felt welcome. That is Zebulun. Now receive the word our tribe has carried from shore to shore.",
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
	if result.get("root") == _sailing_result.get("root"):
		_after_sailing()
	elif result.get("root") == _hospitality_result.get("root"):
		_after_hospitality()


func on_minigame_timeout(result: Dictionary) -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	if result.get("root") == _sailing_result.get("root"):
		show_dialogue([{ "name": elder, "text": "The waves pushed us back — let's try again. God is patient with our steering." }])
		get_tree().create_timer(1.2).timeout.connect(
			func():
				for child in _mini_game_container.get_children():
					child.queue_free()
				_sailing_result = build_swipe_minigame(_mini_game_container, 10, "Steer through the waves!", 20.0),
			CONNECT_ONE_SHOT,
		)
	elif result.get("root") == _hospitality_result.get("root"):
		show_dialogue([{ "name": elder, "text": "Some travellers had to wait — let's open the harbour again." }])
		get_tree().create_timer(1.2).timeout.connect(
			func():
				for child in _mini_game_container.get_children():
					child.queue_free()
				_hospitality_result = build_tap_minigame(_mini_game_container, 8, "Welcome each traveller!", 18.0),
			CONNECT_ONE_SHOT,
		)
