extends "res://scripts/WorldBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# Quest10.gd  –  Tribe of Zebulun
# Mini-game 1: Sailing Swipe — swipe to dodge waves (10, 20 s)
# Mini-game 2: Hospitality Tap — tap to welcome each traveller (8, 18 s)
# Verse: Romans 15:7  |  Nature: Clownfish & anemone / Ecclesiastes 4:9
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key  = "zebulun"
	quest_id   = "zebulun_main"
	next_scene = "res://scenes/Quest11.tscn"
	# Genesis 49:13 – Zebulun shall dwell at the shore of the sea
	music_path = "res://assets/audio/music/gathering_at_the_gates.wav"
	super._ready()

func on_world_ready() -> void:
	super.on_world_ready()  # 3D sky + directional light – Psalm 19:1
	_build_terrain()
	_place_npcs()
	_place_chests()
	_show_world_intro()

# ─────────────────────────────────────────────────────────────────────────────
# TERRAIN
# "Haven for ships" – Genesis 49:13
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# Harbour/seaside
	# "Zebulun will live by the seashore" – Genesis 49:13
	# Ground: sandy beach
	_tr(Vector3(-50, 0, -50), Vector3(100, 0, 100), "sand.jpg")
	
	# Harbour structures: docks and boats
	_wall(Vector3(-20, 0, 0), Vector3(40, 2, 4), "wood.jpg")  # Dock
	_wall(Vector3(0, 0, 10), Vector3(4, 2, 20), "wood.jpg")   # Boat

# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# "Accept one another" – Romans 15:7
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder at the harbour
	_build_npc("zebulun_elder", Vector3(0, 0, 0), "elder_zebulun.jpg")

# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# "Just as Christ accepted you" – Romans 15:7
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	# Verse chest on the dock
	_chest(Vector3(15, 0, 0), "romans_15_7", "Romans 15:7")

func on_quest_ready() -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder, "text": "My child, shalom! The harbour is open, the sea is wide. Zebulun was a haven for ships — and for weary souls. The Beryl stone waits beyond the waves."},
		{"name": elder, "text": "\"Accept one another, just as Christ accepted you.\" That is our word. But first — guide our boat safely to shore. Swipe left and right to steer."},
		{"name": "You",  "text": "Please, elder — how do I keep the boat steady?"},
		{"name": elder, "text": "Watch the waves and move with them, not against them. God placed calm water between every storm.",
		 "callback": Callable(self, "_start_sailing")}
	])

var _sailing_result: Dictionary = {}
var _hospitality_result: Dictionary = {}

func _start_sailing() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	var goal := 8 if Global.selected_avatar == "marina_z" else 10
	_sailing_result = build_swipe_minigame(
		container, goal,
		"Swipe left/right to steer through the waves!\nGod calms the storm.",
		20.0
	)

func _after_sailing() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder, "text": "Safe harbour! Now — travellers are arriving, tired and hungry. Tap to welcome each one as they step ashore."},
		{"name": elder, "text": "Hospitality is worship. Every open hand mirrors the hands of God.",
		 "callback": Callable(self, "_start_hospitality")}
	])

func _start_hospitality() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	for child in container.get_children(): child.queue_free()
	_hospitality_result = build_tap_minigame(
		container, 8,
		"Welcome each traveller!\nTap as they arrive — an open hand, an open heart.",
		18.0
	)

func _after_hospitality() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "Every stranger felt welcome. That is Zebulun. Now receive the word our tribe has carried from shore to shore.",
		"callback": Callable(self, "_show_quest_verse")
	}])

func _show_quest_verse() -> void:
	show_verse_scroll(
		_tribe_data.get("quest_verse_ref", ""),
		_tribe_data.get("quest_verse", "")
	)

func on_minigame_complete(result: Dictionary) -> void:
	if result.get("root") == _sailing_result.get("root"):
		_after_sailing()
	elif result.get("root") == _hospitality_result.get("root"):
		_after_hospitality()

func on_minigame_timeout(result: Dictionary) -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	if result.get("root") == _sailing_result.get("root"):
		show_dialogue([{"name": elder, "text": "The waves pushed us back — let's try again. God is patient with our steering."}])
		get_tree().create_timer(1.2).timeout.connect(func():
			for child in _mini_game_container.get_children(): child.queue_free()
			_sailing_result = build_swipe_minigame(_mini_game_container, 10, "Steer through the waves!", 20.0)
		, CONNECT_ONE_SHOT)
	elif result.get("root") == _hospitality_result.get("root"):
		show_dialogue([{"name": elder, "text": "Some travellers had to wait — let's open the harbour again."}])
		get_tree().create_timer(1.2).timeout.connect(func():
			for child in _mini_game_container.get_children(): child.queue_free()
			_hospitality_result = build_tap_minigame(_mini_game_container, 8, "Welcome each traveller!", 18.0)
		, CONNECT_ONE_SHOT)
