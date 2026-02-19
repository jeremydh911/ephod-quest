extends "res://scripts/QuestBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# Quest1.gd  –  Tribe of Reuben
# Map: Cave with ladder.
# Mini-game 1: Ladder Climb — tap to climb (10 taps, 18 s).
# Mini-game 2: Butterfly Flutter — rhythm tap (tap when circle pulses big).
# Verse: Proverbs 3:5-6  |  Nature: Butterfly / 2 Corinthians 5:17
# "Trust in the LORD with all your heart" – Proverbs 3:5
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key  = "reuben"
	quest_id   = "reuben_main"
	next_scene = "res://scenes/Quest2.tscn"
	super._ready()

func on_quest_ready() -> void:
	var elder: String = Global.get_tribe_data(tribe_key).get("elder", "Elder")
	show_dialogue([
		{
			"name": elder,
			"text": "My child, shalom! The entrance of the cave is just ahead. The Sardius stone — ruby red like courage — rests at the very top of this ladder."
		},
		{
			"name": elder,
			"text": "Reuben was the firstborn. Strong — yet he learnt that strength needs wisdom. \"Trust in the LORD with all your heart\", he told his children."
		},
		{
			"name": "You",
			"text": "Please, Elder Hanoch — how do I climb?"
		},
		{
			"name": elder,
			"text": "Tap the rungs, one by one. Steady hands, steady heart. God sees your effort. Every rung is a step of trust.",
			"callback": Callable(self, "_start_ladder_climb")
		}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — LADDER CLIMB
# ─────────────────────────────────────────────────────────────────────────────
var _ladder_result: Dictionary = {}
var _butterfly_result: Dictionary = {}

func _start_ladder_climb() -> void:
	var container: Node = $MiniGameContainer
	container.visible = true
	var goal := 9 if Global.selected_avatar == "naomi" else 10
	_ladder_result = build_tap_minigame(
		container, goal,
		"Tap each rung of the ladder!\nTrust your hands, trust God.",
		18.0
	)

func _animate_climb() -> void:
	var sprite: Node = $PlayerSprite
	var tw := create_tween()
	tw.tween_property(sprite, "position:y", 60.0, 1.8).set_ease(Tween.EASE_OUT)

func _continue_after_climb() -> void:
	await get_tree().create_timer(1.5).timeout
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder,
		 "text": "Well done! You reached the top. Do you see that butterfly resting on the stone ledge? Watch it — it has something to teach us."},
		{"name": elder,
		 "text": "The butterfly lands when it is ready, not when we demand. Tap gently when it opens its wings — on the beat!",
		 "callback": Callable(self, "_start_butterfly_mini")}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 2 — BUTTERFLY FLUTTER (rhythm)
# ─────────────────────────────────────────────────────────────────────────────
func _start_butterfly_mini() -> void:
	var container: Node = $MiniGameContainer
	container.visible = true
	for child in container.get_children():
		child.queue_free()
	if Global.selected_avatar == "ezra_r":
		var hint := Label.new()
		hint.text = "★ Clue: the butterfly opens on beats 2, 4, 6, 8"
		hint.add_theme_font_size_override("font_size", 13)
		hint.modulate = Color(0.4, 0.7, 0.2, 1)
		container.add_child(hint)
	_butterfly_result = build_rhythm_minigame(
		container, 0.9, 10, 6,
		"The butterfly opens its wings on the beat —\ntap when the circle pulses big!"
	)

func _on_butterfly_complete() -> void:
	$MiniGameContainer.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "Beautiful! You felt the rhythm of creation. Now — let me share a word carried by Reuben's children for generations.",
		"callback": Callable(self, "_show_quest_verse")
	}])

func _show_quest_verse() -> void:
	var entries: Array = VerseVault.VAULT[tribe_key].filter(func(e): return e.get("type") in ["quest", "bonus"])
	show_verses(entries)

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME CALLBACKS  (overrides QuestBase)
# ─────────────────────────────────────────────────────────────────────────────
func on_minigame_complete(result: Dictionary) -> void:
	if result == _ladder_result:
		$MiniGameContainer.visible = false
		_animate_climb()
		_continue_after_climb()
	elif result == _butterfly_result:
		_on_butterfly_complete()

func on_minigame_timeout(result: Dictionary) -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	if result == _ladder_result:
		show_dialogue([{"name": elder,
			"text": "Let's try again together. God sees your heart on every rung."}])
		await get_tree().create_timer(1.2).timeout
		for child in $MiniGameContainer.get_children(): child.queue_free()
		_ladder_result = build_tap_minigame(
			$MiniGameContainer, 10,
			"Tap each rung — steady hands, steady heart.", 18.0)
	elif result == _butterfly_result:
		show_dialogue([{"name": elder,
			"text": "Try again, my child. The butterfly is patient with you too."}])
		await get_tree().create_timer(1.2).timeout
		for child in $MiniGameContainer.get_children(): child.queue_free()
		_butterfly_result = build_rhythm_minigame(
			$MiniGameContainer, 0.9, 10, 6,
			"Try again — tap when the circle pulses big!")
