extends "res://scripts/WorldBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# Quest12.gd  –  Tribe of Benjamin
# Mini-game 1: Precision Tap — tap targets accurately (10 taps, 20 s)
# Mini-game 2: Protection Swipe — swipe to shield the vulnerable (8, 18 s)
# Verse: Deuteronomy 33:12  |  Nature: Wolf pack pups / Zephaniah 3:17
# "Let the beloved of the LORD rest secure in him" – Deuteronomy 33:12
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key  = "benjamin"
	quest_id   = "benjamin_main"
	next_scene = "res://scenes/Finale.tscn"
	music_path = "res://assets/audio/music/sacred_spark.wav"
	super._ready()

func on_world_ready() -> void:
	super.on_world_ready()  # 3D sky + directional light – Psalm 19:1
	_build_terrain()
	_place_npcs()
	_place_chests()
	_show_world_intro()

# ─────────────────────────────────────────────────────────────────────────────
# TERRAIN
# "Beloved of the LORD" – Deuteronomy 33:12
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# Wolf pack resting area
	# "Benjamin is a ravenous wolf" – Genesis 49:27
	# Ground: forest floor
	_tr(Vector3(-50, 0, -50), Vector3(100, 0, 100), "forest_floor.jpg")
	
	# Pack dens: rocky outcrops
	_wall(Vector3(-20, 0, -20), Vector3(10, 5, 10), "rock.jpg")  # Den 1
	_wall(Vector3(10, 0, 10), Vector3(10, 5, 10), "rock.jpg")    # Den 2

# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# "Rest secure in him" – Deuteronomy 33:12
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder Benjamin in the pack area
	_build_npc("benjamin_elder", Vector3(0, 0, 0), "elder_benjamin.jpg")

# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# "He will rest between his shoulders" – Deuteronomy 33:12
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	# Verse chest in the central den
	_chest(Vector3(0, 3, 0), "deuteronomy_33_12", "Deuteronomy 33:12")

func on_quest_ready() -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder, "text": "My child, shalom. You have come to the youngest tribe — and the most beloved. Benjamin means 'son of my right hand'. The smallest, and yet held closest."},
		{"name": elder, "text": "The Jasper stone — warm like sunrise — rests where the wolf pack rests. To earn it, you must show precision and protection. Both are gifts of Benjamin."},
		{"name": "You",  "text": "Please, elder — I am ready."},
		{"name": elder, "text": "Strike with precision first. The wolf does not waste a move. Each tap must land true.",
		 "callback": Callable(self, "_start_precision")}
	])

var _precision_result: Dictionary = {}
var _protection_result: Dictionary = {}

func _start_precision() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	var goal := 8 if Global.selected_avatar == "esther_b" else 10
	_precision_result = build_tap_minigame(
		container, goal,
		"Tap each target with precision!\nStrike true — Benjamin strikes like the Wolf.",
		20.0
	)

func _after_precision() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder, "text": "Precise and steady! Now the greater test — protection. The smallest members of the pack are in danger. Swipe to shield them."},
		{"name": elder, "text": "The wolf pack raises every pup together. No pup left behind. That is the heart of Benjamin.",
		 "callback": Callable(self, "_start_protection")}
	])

func _start_protection() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	for child in container.get_children(): child.queue_free()
	var goal := 6 if Global.selected_avatar == "nia_b" else 8
	_protection_result = build_swipe_minigame(
		container, goal,
		"Swipe to shield the vulnerable!\nGuard them — God shields you the same way.",
		18.0
	)

func _after_protection() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "Every one of them is safe. God sees your heart. You have finished all twelve paths. Now — receive the final word, and carry it to the courtyard.",
		"callback": Callable(self, "_show_quest_verse")
	}])

func _show_quest_verse() -> void:
	show_verse_scroll(
		_tribe_data.get("quest_verse_ref", ""),
		_tribe_data.get("quest_verse", "")
	)

func on_minigame_complete(result: Dictionary) -> void:
	if result.get("root") == _precision_result.get("root"):
		_after_precision()
	elif result.get("root") == _protection_result.get("root"):
		_after_protection()

func on_minigame_timeout(result: Dictionary) -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	if result.get("root") == _precision_result.get("root"):
		show_dialogue([{"name": elder, "text": "Let's try again together. God is patient on every path."}])
		get_tree().create_timer(1.2).timeout.connect(func():
			for child in _mini_game_container.get_children(): child.queue_free()
			_precision_result = build_tap_minigame(_mini_game_container, 10, "Tap each target with precision!", 20.0)
		, CONNECT_ONE_SHOT)
	elif result.get("root") == _protection_result.get("root"):
		show_dialogue([{"name": elder, "text": "Let's try once more. None are forgotten."}])
		get_tree().create_timer(1.2).timeout.connect(func():
			for child in _mini_game_container.get_children(): child.queue_free()
			_protection_result = build_swipe_minigame(_mini_game_container, 8, "Swipe to shield the vulnerable!", 18.0)
		, CONNECT_ONE_SHOT)
