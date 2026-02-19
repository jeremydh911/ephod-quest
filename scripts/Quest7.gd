extends "res://scripts/QuestBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# Quest7.gd  –  Tribe of Gad
# Map: Mountain stronghold.
# Mini-game 1: Tower Defense — place defenses, hold the line (10 waves, 25 s).
# Mini-game 2: Endurance Race — sustained running (hold button, 20 s).
# Verse: Hebrews 12:1  |  Nature: Olive tree / Hebrews 12:1
# "Let us run with perseverance the race marked out for us" – Hebrews 12:1
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key  = "gad"
	quest_id   = "gad_main"
	next_scene = "res://scenes/Quest8.tscn"
	music_path = "res://assets/audio/music/quest_theme.ogg"
	super._ready()

func on_quest_ready() -> void:
	var elder: String = Global.get_tribe_data(tribe_key).get("elder", "Elder")
	show_dialogue([
		{
			"name": elder,
			"text": "My child, shalom! The mountain stronghold stands firm against invaders. The Ligure stone — striped like Gad's warriors — waits at the peak."
		},
		{
			"name": elder,
			"text": "Gad chose the best land for his people, but it required perseverance. Like olive trees that live for centuries, he endured. \"Let us run with perseverance...\", he taught."
		},
		{
			"name": "You",
			"text": "Please, Elder Zephon — how do I reach the stone?"
		},
		{
			"name": elder,
			"text": "First, defend the stronghold! Place your towers wisely as waves approach. Then, run the endurance race up the mountain.",
			"callback": Callable(self, "_start_tower_defense")
		}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — TOWER DEFENSE (place defenses)
# ─────────────────────────────────────────────────────────────────────────────
var _defense_result: Dictionary = {}
var _race_result: Dictionary = {}

func _start_tower_defense() -> void:
	var container: Node = $MiniGameContainer
	container.visible = true
	_defense_result = build_tower_defense_minigame(
		container, 10,
		"Place towers to defend the stronghold!\nHold the line against invaders.",
		25.0
	)

func _continue_after_defense() -> void:
	await get_tree().create_timer(1.5).timeout
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder,
		 "text": "Stronghold defended! You showed perseverance. Now — the final climb requires endurance. Run steadily to the peak!"},
		{"name": elder,
		 "text": "Like the olive tree that endures for generations, keep running. God gives strength to those who persevere.",
		 "callback": Callable(self, "_start_endurance_race")}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 2 — ENDURANCE RACE (sustained effort)
# ─────────────────────────────────────────────────────────────────────────────
func _start_endurance_race() -> void:
	var container: Node = $MiniGameContainer
	container.visible = true
	for child in container.get_children():
		child.queue_free()
	_race_result = build_endurance_minigame(
		container,
		"Run the endurance race!\nHold the pace steadily to the finish."
	)

func _on_race_complete() -> void:
	$MiniGameContainer.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "Endurance rewarded! You ran with perseverance. Now — let me share the words that Gad carried through the mountains.",
		"callback": Callable(self, "_show_quest_verse")
	}])

func _show_quest_verse() -> void:
	var ref:  String = _tribe_data.get("quest_verse_ref", "")
	var text: String = _tribe_data.get("quest_verse_text", "")
	show_verse_scroll(ref, text)

func _show_nature_fact() -> void:
	show_nature_fact()

func _collect_stone() -> void:
	_collect_stone()

# ─────────────────────────────────────────────────────────────────────────────
# QUEST COMPLETE — fade out and change scene
# ─────────────────────────────────────────────────────────────────────────────
func on_minigame_complete(result: Dictionary) -> void:
	if result == _defense_result:
		_continue_after_defense()
	elif result == _race_result:
		_on_race_complete()

func on_minigame_timeout(result: Dictionary) -> void:
	if result == _defense_result:
		_continue_after_defense()
	elif result == _race_result:
		_on_race_complete()