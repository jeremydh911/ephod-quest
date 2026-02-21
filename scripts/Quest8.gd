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
	tribe_key  = "asher"
	quest_id   = "asher_main"
	next_scene = "res://scenes/Quest9.tscn"
	# Genesis 49:20 – Asher's food shall be rich, and he shall yield royal delicacies
	music_path = "res://assets/audio/music/sunrise_over_the_valley.wav"
	super._ready()

func on_world_ready() -> void:
	super.on_world_ready()  # 3D sky + directional light – Psalm 19:1
	_build_terrain()
	_place_npcs()
	_place_chests()
	_show_world_intro()

# ─────────────────────────────────────────────────────────────────────────────
# TERRAIN
# "He gave thanks and broke them" – Luke 9:16
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# Fertile valley
	# "Asher's food will be rich" – Genesis 49:20
	# Ground: fertile soil
	_tr(Vector3(-50, 0, -50), Vector3(100, 0, 100), "soil.jpg")
	
	# Valley boundaries: gentle hills
	_wall(Vector3(-50, 0, -50), Vector3(100, 3, 0), "grass.jpg")  # North hill
	_wall(Vector3(-50, 0, 50), Vector3(100, 3, 0), "grass.jpg")   # South hill
	_wall(Vector3(-50, 0, -50), Vector3(0, 3, 100), "grass.jpg")  # West hill
	_wall(Vector3(50, 0, -50), Vector3(0, 3, 100), "grass.jpg")   # East hill

# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# "He gave them to the disciples to distribute" – Luke 9:16
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder Imnah in the valley center
	_build_npc("imnah", Vector3(0, 0, 0), "elder_imnah.jpg")

# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# "To the people" – Luke 9:16
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	# Verse chest among the crops
	_chest(Vector3(20, 0, 20), "luke_9_16", "Luke 9:16")

func on_quest_ready() -> void:
	var elder: String = Global.get_tribe_data(tribe_key).get("elder", "Elder")
	show_dialogue([
		{
			"name": elder,
			"text": "My child, shalom! The fertile valley overflows with blessing. The Agate stone — banded like Asher's abundance — waits among the harvests."
		},
		{
			"name": elder,
			"text": "Asher was blessed with rich food and royal delicacies. Like bees that share through dance, he provided for all. \"Taking the five loaves...\", he remembered."
		},
		{
			"name": "You",
			"text": "Please, Elder Imnah — how do I find the stone?"
		},
		{
			"name": elder,
			"text": "First, harvest the crops and share the bread with all who come. Then, learn the honey dance from the bees!",
			"callback": Callable(self, "_start_harvesting_game")
		}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — HARVESTING GAME (collect and share)
# ─────────────────────────────────────────────────────────────────────────────
var _harvest_result: Dictionary = {}
var _dance_result: Dictionary = {}

func _start_harvesting_game() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	# Luke 9:16 — giving thanks, bread multiplied when shared with all
	_harvest_result = build_tap_minigame(
		container, 12,
		"Harvest the crops and share the bread!\nBlessing multiplies when shared.",
		18.0
	)

func _continue_after_harvest() -> void:
	await get_tree().create_timer(1.5).timeout
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder,
		 "text": "Abundantly shared! You understand blessing. Now — watch the bees dance! Follow their waggle to find the honey."},
		{"name": elder,
		 "text": "The bee's dance shows the way to sweetness. Each movement reveals God's provision. Follow carefully!",
		 "callback": Callable(self, "_start_honey_dance")}
	])

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
		container, 0.4, 6, 5,
		"Follow the bee's waggle dance!\nKeep the rhythm — watch the pattern."
	)

func _on_dance_complete() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "Dance followed perfectly! You found the sweetness. Now — let me share the words that Asher carried through the valleys.",
		"callback": Callable(self, "_show_quest_verse")
	}])

func _show_quest_verse() -> void:
	show_verse_scroll(
		_tribe_data.get("quest_verse_ref", ""),
		_tribe_data.get("quest_verse", "")
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