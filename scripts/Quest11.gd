extends "res://scripts/WorldBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# Quest11.gd  –  Tribe of Joseph
# Mini-game 1: Growth Tap — tap to tend the garden (12 taps, 22 s)
# Mini-game 2: Forgiveness Choice — dialogue choice mini-game (4 choices)
# Verse: Genesis 50:20  |  Nature: Pearl / Romans 8:28
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key  = "joseph"
	quest_id   = "joseph_main"
	next_scene = "res://scenes/Quest12.tscn"
	# Genesis 49:22 – Joseph is a fruitful bough, a fruitful bough by a spring
	music_path = "res://assets/audio/music/desert_sanctuary_main_theme.wav"
	super._ready()

func on_world_ready() -> void:
	super.on_world_ready()  # 3D sky + directional light – Psalm 19:1
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
	# Palace garden
	# "Joseph is a fruitful vine" – Genesis 49:22
	# Ground: garden soil
	_tr(Vector3(-50, 0, -50), Vector3(100, 0, 100), "soil.jpg")
	
	# Garden walls and paths
	_wall(Vector3(-30, 0, -30), Vector3(60, 4, 0), "stone_wall.jpg")  # North wall
	_wall(Vector3(-30, 0, 30), Vector3(60, 4, 0), "stone_wall.jpg")   # South wall
	_wall(Vector3(-30, 0, -30), Vector3(0, 4, 60), "stone_wall.jpg")  # West wall
	_wall(Vector3(30, 0, -30), Vector3(0, 4, 60), "stone_wall.jpg")   # East wall

# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# "You intended to harm me" – Genesis 50:20
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder in the garden
	_build_npc("joseph_elder", Vector3(0, 0, 0), "elder_joseph.jpg")

# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# "For the saving of many lives" – Genesis 50:20
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	# Verse chest at the top of the wall
	_chest(Vector3(0, 5, 0), "genesis_50_20", "Genesis 50:20")

# ─────────────────────────────────────────────────────────────────────────────
# SIDE QUEST OBJECTS
# "God causes all things to work together for good" – Romans 8:28
# ─────────────────────────────────────────────────────────────────────────────
func _place_side_quest_objects() -> void:
	# Collect flowers for extra heart badge
	_place_collectible(Vector3(10, 1, 10), "flower", Callable(self, "_on_flower_collected"))
	_place_collectible(Vector3(-10, 1, -10), "flower", Callable(self, "_on_flower_collected"))
	_place_collectible(Vector3(15, 1, -5), "flower", Callable(self, "_on_flower_collected"))

func _on_flower_collected() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/stone_collect.wav")
	show_dialogue([{
		"name": "You",
		"text": "A beautiful flower in Joseph's garden! God makes beauty from hardship.",
		"callback": Callable(self, "_show_flower_fact")
	}])

func _show_flower_fact() -> void:
	show_nature_fact()

func on_quest_ready() -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder, "text": "My child, shalom. You stand in the garden of Joseph — once a pit, now a palace garden. God turned every wound into wonder."},
		{"name": elder, "text": "The Onyx stone — dark and deep, like the pit — rests at the top of the garden wall. Tend the garden first. Then face the greater test: forgiveness."},
		{"name": "You",  "text": "Please, elder — I am ready to learn."},
		{"name": elder, "text": "Water the plants, remove the thorns. Each tap is a choice to nurture what God has planted, not destroy it.",
		 "callback": Callable(self, "_start_growth")}
	])

var _growth_result: Dictionary = {}
var _forgiveness_result: Dictionary = {}

func _start_growth() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	var goal := 10 if Global.selected_avatar == "joseph_w" else 12
	_growth_result = build_tap_minigame(
		container, goal,
		"Tend the garden!\nTap to water and nurture — God grows what we plant.",
		22.0
	)

func _after_growth() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder, "text": "The garden flourishes! Now — the brothers who sold Joseph stand before you. He had every reason for bitterness. He chose something greater."},
		{"name": elder, "text": "\"You intended to harm me, but God intended it for good.\" Choose: hold the hurt, or release it?",
		 "callback": Callable(self, "_start_forgiveness")}
	])

func _start_forgiveness() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	for child in container.get_children(): child.queue_free()
	_forgiveness_result = build_dialogue_choice_minigame(
		container, 4,
		"Your brothers stand before you.\nChoose the path of Joseph."
	)

func _after_forgiveness() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "You chose as Joseph chose. God sees your heart. Now — receive the word that Ephraim's children carried through every hard season.",
		"callback": Callable(self, "_show_quest_verse")
	}])

func _show_quest_verse() -> void:
	show_verse_scroll(
		_tribe_data.get("quest_verse_ref", ""),
		_tribe_data.get("quest_verse", "")
	)

func on_minigame_complete(result: Dictionary) -> void:
	if result.get("root") == _growth_result.get("root"):
		_after_growth()
	elif result.get("root") == _forgiveness_result.get("root"):
		_after_forgiveness()

func on_minigame_timeout(result: Dictionary) -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	if result.get("root") == _growth_result.get("root"):
		show_dialogue([{"name": elder, "text": "Growth takes patience — let's tend the garden once more. God is patient with us too."}])
		get_tree().create_timer(1.2).timeout.connect(func():
			for child in _mini_game_container.get_children(): child.queue_free()
			_growth_result = build_tap_minigame(_mini_game_container, 12, "Tend the garden!", 22.0)
		, CONNECT_ONE_SHOT)
	elif result.get("root") == _forgiveness_result.get("root"):
		show_dialogue([{"name": elder, "text": "Forgiveness is difficult — Joseph wrestled with it too. Let's try again together."}])
		get_tree().create_timer(1.2).timeout.connect(func():
			for child in _mini_game_container.get_children(): child.queue_free()
			_forgiveness_result = build_dialogue_choice_minigame(_mini_game_container, 4, "Choose the path of Joseph.")
		, CONNECT_ONE_SHOT)
