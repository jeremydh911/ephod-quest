extends "res://scripts/QuestBase.gd"
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
	music_path = "res://assets/audio/music/quest_theme.ogg"
	super._ready()

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
	var container: Node = $MiniGameContainer
	container.visible = true
	_harvest_result = build_harvesting_minigame(
		container, 12,
		"Harvest crops and share bread!\nBlessing multiplies when shared.",
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
	var container: Node = $MiniGameContainer
	container.visible = true
	for child in container.get_children():
		child.queue_free()
	_dance_result = build_honey_dance_minigame(
		container, 6,
		"Follow the bee's waggle dance!\nWatch the pattern and repeat it."
	)

func _on_dance_complete() -> void:
	$MiniGameContainer.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "Dance followed perfectly! You found the sweetness. Now — let me share the words that Asher carried through the valleys.",
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
	if result == _harvest_result:
		_continue_after_harvest()
	elif result == _dance_result:
		_on_dance_complete()

func on_minigame_timeout(result: Dictionary) -> void:
	if result == _harvest_result:
		_continue_after_harvest()
	elif result == _dance_result:
		_on_dance_complete()