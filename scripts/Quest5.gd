extends "res://scripts/QuestBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# Quest5.gd  –  Tribe of Naphtali
# Map: Forest clearing at night, stars overhead.
# Mini-game 1: Run Dash — swipe left/right to dodge obstacles (8 dodges, 15 s).
# Mini-game 2: Praise Poem — tap rhythm to complete verse (tap on beats).
# Verse: Psalm 19:14  |  Nature: Doe / Psalm 19:14
# "Let the words of my mouth and the meditation of my heart be acceptable in your sight" – Psalm 19:14
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key  = "naphtali"
	quest_id   = "naphtali_main"
	next_scene = "res://scenes/Quest6.tscn"
	music_path = "res://assets/audio/music/quest_theme.ogg"
	super._ready()

func on_quest_ready() -> void:
	var elder: String = Global.get_tribe_data(tribe_key).get("elder", "Elder")
	show_dialogue([
		{
			"name": elder,
			"text": "My child, shalom! The forest clearing opens before us, under the watchful stars. The Diamond stone — clear as truth — waits where the swift deer run."
		},
		{
			"name": elder,
			"text": "Naphtali was blessed with beautiful words. Like a doe set free, his speech brought grace. \"Let the words of my mouth...\", he prayed each morning."
		},
		{
			"name": "You",
			"text": "Please, Elder Jahzeel — how do I find the stone?"
		},
		{
			"name": elder,
			"text": "Run with the deer! Swipe left and right to dodge the fallen branches. Swift feet, swift heart. God gives speed to those who follow Him.",
			"callback": Callable(self, "_start_run_dash")
		}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — RUN DASH (swipe to dodge)
# ─────────────────────────────────────────────────────────────────────────────
var _dash_result: Dictionary = {}
var _poem_result: Dictionary = {}

func _start_run_dash() -> void:
	var container: Node = $MiniGameContainer
	container.visible = true
	_dash_result = build_swipe_minigame(
		container, 8,
		"Swipe left/right to dodge the branches!\nRun like the deer — swift and sure.",
		15.0
	)

func _continue_after_dash() -> void:
	await get_tree().create_timer(1.5).timeout
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder,
		 "text": "Excellent! You ran with grace. Now listen — the stars above whisper a poem of praise. Tap the rhythm as the words appear!"},
		{"name": elder,
		 "text": "Feel the beat of creation. Each tap completes the verse. \"Let the words of my mouth...\"",
		 "callback": Callable(self, "_start_praise_poem")}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 2 — PRAISE POEM (rhythm tap)
# ─────────────────────────────────────────────────────────────────────────────
func _start_praise_poem() -> void:
	var container: Node = $MiniGameContainer
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
		container, 1.0, 8, 4,
		"Tap when the words pulse!\nComplete the verse of praise."
	)

func _on_poem_complete() -> void:
	$MiniGameContainer.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "Perfect harmony! You spoke with beauty. Now — let me share the words that Naphtali carried through the ages.",
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
	if result == _dash_result:
		_continue_after_dash()
	elif result == _poem_result:
		_on_poem_complete()

func on_minigame_timeout(result: Dictionary) -> void:
	if result == _dash_result:
		_continue_after_dash()
	elif result == _poem_result:
		_on_poem_complete()