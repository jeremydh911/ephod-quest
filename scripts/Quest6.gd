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
	tribe_key  = "simeon"
	quest_id   = "simeon_main"
	next_scene = "res://scenes/Quest7.tscn"
	# Lamentations 3:23 – Great is His faithfulness; new every morning
	music_path = "res://assets/audio/music/simeon_theme.wav"
	super._ready()

func on_world_ready() -> void:
	super.on_world_ready()  # 3D sky + directional light – Psalm 19:1
	_build_terrain()
	_place_npcs()
	_place_chests()
	_show_world_intro()

# ─────────────────────────────────────────────────────────────────────────────
# TERRAIN
# "Be still, and know that I am God" – Psalm 46:10
# ─────────────────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# Desert border crossing / arbiter's tent
	# "Simeon and Levi are brothers" – Genesis 49:5
	# Ground: sandy desert
	_tr(Vector3(-50, 0, -50), Vector3(100, 0, 100), "sand.jpg")
	
	# Arbiter's tent in center
	_wall(Vector3(-10, 0, -10), Vector3(20, 8, 0), "tent_canvas.jpg")  # Tent walls
	_wall(Vector3(-10, 0, 10), Vector3(20, 8, 0), "tent_canvas.jpg")
	_wall(Vector3(-10, 0, -10), Vector3(0, 8, 20), "tent_canvas.jpg")
	_wall(Vector3(10, 0, -10), Vector3(0, 8, 20), "tent_canvas.jpg")

# ─────────────────────────────────────────────────────────────────────────────
# NPCs
# "I will be exalted among the nations" – Psalm 46:10
# ─────────────────────────────────────────────────────────────────────────────
func _place_npcs() -> void:
	# Elder Nemuel in the arbiter's tent
	_build_npc("nemuel", Vector3(0, 0, 0), "elder_nemuel.jpg")

# ─────────────────────────────────────────────────────────────────────────────
# CHESTS
# "I will be exalted in the earth" – Psalm 46:10
# ─────────────────────────────────────────────────────────────────────────────
func _place_chests() -> void:
	# Verse chest near the tent
	_chest(Vector3(15, 0, 15), "psalm_46_10", "Psalm 46:10")

func on_quest_ready() -> void:
	var elder: String = Global.get_tribe_data(tribe_key).get("elder", "Elder")
	show_dialogue([
		{
			"name": elder,
			"text": "My child, shalom! The desert border stretches before us, where disputes arise like sandstorms. The Ligure stone — striped like justice — waits in the arbiter's tent."
		},
		{
			"name": elder,
			"text": "Simeon and Levi once acted hastily in anger. But Simeon learned to be still, to know that God is God. \"Be still, and know that I am God\", he came to understand."
		},
		{
			"name": "You",
			"text": "Please, Elder Nemuel — how do I find the stone?"
		},
		{
			"name": elder,
			"text": "First, balance the scales of justice. Sort the deeds fairly — some are just, some unjust. Then, negotiate peace with wisdom.",
			"callback": Callable(self, "_start_justice_scales")
		}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — JUSTICE SCALES (sorting)
# ─────────────────────────────────────────────────────────────────────────────
var _scales_result: Dictionary = {}
var _negotiation_result: Dictionary = {}

func _start_justice_scales() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	_scales_result = build_sorting_minigame(
		container, 8,
		"Sort deeds into Just or Unjust piles!\nBalance the scales of righteousness.",
		20.0
	)

func _continue_after_scales() -> void:
	await get_tree().create_timer(1.5).timeout
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder,
		 "text": "Well balanced! Justice requires wisdom. Now — two travelers approach with a dispute. Choose your words carefully to bring peace."},
		{"name": elder,
		 "text": "Remember: \"Be still, and know that I am God.\" Sometimes silence and wisdom speak louder than words.",
		 "callback": Callable(self, "_start_peace_negotiation")}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 2 — PEACE NEGOTIATION (dialogue choices)
# ─────────────────────────────────────────────────────────────────────────────
func _start_peace_negotiation() -> void:
	var container: Control = _mini_game_container
	container.visible = true
	for child in container.get_children():
		child.queue_free()
	_negotiation_result = build_dialogue_choice_minigame(
		container, 4,
		"Choose dialogue options to resolve the dispute!\nWisdom brings peace."
	)

func _on_negotiation_complete() -> void:
	_mini_game_container.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "Peace restored! You spoke with wisdom. Now — let me share the words that Simeon carried through the desert.",
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
	if result.get("root") == _scales_result.get("root"):
		_continue_after_scales()
	elif result.get("root") == _negotiation_result.get("root"):
		_on_negotiation_complete()

func on_minigame_timeout(result: Dictionary) -> void:
	if result.get("root") == _scales_result.get("root"):
		_continue_after_scales()
	elif result.get("root") == _negotiation_result.get("root"):
		_on_negotiation_complete()
