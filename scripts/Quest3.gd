extends "res://scripts/QuestBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# Quest3.gd  –  Tribe of Levi
# Map: Sacred hall — gold rounded pillars, cedar beams, 7-flame lampstand,
#                    blue/purple/scarlet curtains, thick veil with cherubim.
#      (No words "temple" or "church" used anywhere.)
# Mini-game 1: Lamp Lighting — tap lamps in order left→right (7 lamps).
# Mini-game 2: Scroll Reading — tap glowing words in the correct sequence.
# Verse: Matthew 5:16  |  Nature: Firefly / Daniel 12:3
# "Let your light shine before others" – Matthew 5:16
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	tribe_key  = "levi"
	quest_id   = "levi_main"
	next_scene = "res://scenes/Quest4.tscn"
	music_path = "res://assets/audio/music/quest_theme.ogg"
	super._ready()

func on_quest_ready() -> void:
	var elder: String = Global.get_tribe_data(tribe_key).get("elder", "Elder")
	show_dialogue([
		{
			"name": elder,
			"text": "My child, shalom. You stand in a sacred hall. Look — the golden pillars, the carved cedar beams above, the curtains of blue, purple, and scarlet."
		},
		{
			"name": elder,
			"text": "The Carbuncle stone — the tribe of Levi's gem — hangs above the seventh flame of the lampstand. But the lamps must be lit first. In order. Deliberately."
		},
		{
			"name": "You",
			"text": "Please, Elder Gershon — how do I know the right order?"
		},
		{
			"name": elder,
			"text": "Left to right. Seven lamps, seven lights. Each flame is a person God watches over. Tap them gently, purposefully, from one to seven.",
			"callback": Callable(self, "_start_lamp_mini")
		}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 1 — LAMP LIGHTING (ordered tap)
# ─────────────────────────────────────────────────────────────────────────────
var _lamp_result: Dictionary = {}
var _scroll_result: Dictionary = {}

func _start_lamp_mini() -> void:
	var container: Node = $MiniGameContainer
	container.visible = true

	var prompt := Label.new()
	prompt.text = "Light the seven lamps in order — left to right.\nTap gently and purposefully."
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 17)
	container.add_child(prompt)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 12)
	container.add_child(hbox)

	var status := Label.new()
	status.text = "Tap lamp 1 first…"
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(status)

	var _next := [0]
	var _done  := [false]
	# Anna avatar: speed boost — lamps stay visible longer (no mechanical diff needed)
	var lamp_buttons: Array[Button] = []
	for i in range(7):
		var lamp := Button.new()
		lamp.text = str(i + 1)
		lamp.custom_minimum_size = Vector2(52, 52)
		lamp.add_theme_font_size_override("font_size", 18)
		lamp.modulate = Color(0.5, 0.5, 0.5, 1)   # unlit
		hbox.add_child(lamp)
		lamp_buttons.append(lamp)
		var idx := i
		lamp.pressed.connect(func():
			if _done[0]: return
			if idx == _next[0]:
				lamp.modulate = Color(1.0, 0.82, 0.1, 1)   # lit — gold
				AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
				_next[0] += 1
				if _next[0] >= 7:
					_done[0] = true
					status.text = "✦ All seven lamps are lit! Light shines!"
					_lamp_result = {"lamp_done": true}
					on_minigame_complete(_lamp_result)
				else:
					status.text = "Tap lamp %d…" % (_next[0] + 1)
			else:
				status.text = "Not yet — try lamp %d first." % (_next[0] + 1)
				AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
		)
	_lamp_result = {"buttons": lamp_buttons, "done": false}

func _after_lamps() -> void:
	$MiniGameContainer.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([
		{"name": elder,
		 "text": "Every flame glows! Now look — the thick veil has an inscription. The letters are scattered. Tap them in the right order to open the way."},
		{"name": elder,
		 "text": "Micah, your scroll-reading skill will help here. Read carefully.",
		 "callback": Callable(self, "_start_scroll_mini")}
	])

# ─────────────────────────────────────────────────────────────────────────────
# MINI-GAME 2 — SCROLL READING (word sequence)
# ─────────────────────────────────────────────────────────────────────────────
# Words from Matthew 5:16 scattered on screen; player taps them in order
const SCROLL_WORDS: Array[String] = [
	"Let", "your", "light", "shine", "before", "others"
]

func _start_scroll_mini() -> void:
	var container: Node = $MiniGameContainer
	container.visible = true
	for child in container.get_children(): child.queue_free()

	var prompt := Label.new()
	prompt.text = "Tap the words of Matthew 5:16 in order:"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 17)
	container.add_child(prompt)

	# Shuffle display order
	var shuffled := SCROLL_WORDS.duplicate()
	shuffled.shuffle()

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	container.add_child(grid)

	var status := Label.new()
	status.text = "First word: \"%s\"" % SCROLL_WORDS[0]
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(status)

	# Avatar edge: Micah sees correct answer highlighted briefly
	var _next := [0]
	var _done  := [false]
	for word in shuffled:
		var btn := Button.new()
		btn.text = word
		btn.custom_minimum_size = Vector2(100, 48)
		grid.add_child(btn)
		var captured_word := word
		btn.pressed.connect(func():
			if _done[0]: return
			if captured_word == SCROLL_WORDS[_next[0]]:
				btn.modulate = Color(0.2, 0.7, 0.25, 1)
				btn.disabled = true
				AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
				_next[0] += 1
				if _next[0] >= SCROLL_WORDS.size():
					_done[0] = true
					status.text = "✦ The scroll is read! The path opens."
				_scroll_result = {"scroll_done": true}
					on_minigame_complete(_scroll_result)
				else:
					status.text = "Next word: \"%s\"" % SCROLL_WORDS[_next[0]]
			else:
				status.text = "Not that one — find \"%s\" next." % SCROLL_WORDS[_next[0]]
				AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
		)
	_scroll_result = {"done": false}

func _on_scroll_complete() -> void:
	$MiniGameContainer.visible = false
	var elder: String = _tribe_data.get("elder", "Elder")
	show_dialogue([{
		"name": elder,
		"text": "\"Let your light shine before others, that they may see your good deeds and glorify your Father in heaven.\" Well read! Now — receive the word of Levi.",
		"callback": Callable(self, "_show_quest_verse")
	}])

func _show_quest_verse() -> void:
	show_verse_scroll(
		_tribe_data.get("quest_verse_ref", ""),
		_tribe_data.get("quest_verse", "")
	)

# ─────────────────────────────────────────────────────────────────────────────
# CALLBACKS
# ─────────────────────────────────────────────────────────────────────────────
func on_minigame_complete(result: Dictionary) -> void:
	if result.has("lamp_done"):
		await get_tree().create_timer(0.8).timeout
		_after_lamps()
	elif result.has("scroll_done"):
		await get_tree().create_timer(0.6).timeout
		_on_scroll_complete()

func on_minigame_timeout(_result: Dictionary) -> void:
	pass  # Lamp and scroll have no time limit — retry is always available
