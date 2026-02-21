extends Control
# ─────────────────────────────────────────────────────────────────────────────
# VerseVaultScene.gd  –  Flip-page Journal of collected verses and nature facts
# Shows tribe colour swatch, verse reference, verse text, nature fact,
# and a memorised badge glow.  Navigate Prev / Next between unlocked entries.
# "I have hidden your word in my heart" – Psalm 119:11
# ─────────────────────────────────────────────────────────────────────────────

var _entries: Array = []
var _current_idx: int = 0

# Cached button references (resolved in _ready, may be created programmatically)
var _prev_btn: Button
var _next_btn: Button
var _page_label: Label
var _back_btn: Button

const VisualEnvironment := preload("res://scripts/VisualEnvironment.gd")

func _ready() -> void:
	VisualEnvironment.add_scene_background(self, "verse_vault")

	const VAULT_MUSIC := "res://assets/audio/music/soft_stone_discovery.wav"
	AudioManager.play_music(VAULT_MUSIC if ResourceLoader.exists(VAULT_MUSIC) else "res://assets/audio/music/sacred_spark.wav")

	_entries = VerseVault.get_all_entries()

	# Resolve nav buttons – fall back to programmatic creation if the scene
	# binary omits NavRow (external-drive NTFS scene-cache bug workaround).
	_prev_btn   = get_node_or_null("NavRow/PrevBtn")   as Button
	_next_btn   = get_node_or_null("NavRow/NextBtn")   as Button
	_page_label = get_node_or_null("NavRow/PageLabel") as Label
	_back_btn   = get_node_or_null("BackBtn")          as Button

	if _prev_btn == null or _next_btn == null:
		_build_nav_row_programmatically()

	if _prev_btn:
		_prev_btn.pressed.connect(_on_prev)
	if _next_btn:
		_next_btn.pressed.connect(_on_next)
	if _back_btn:
		_back_btn.pressed.connect(_on_back)

	_show_entry(_current_idx)

# Build NavRow + Prev/PageLabel/Next/Back entirely in code as a fallback.
func _build_nav_row_programmatically() -> void:
	# Remove stale NavRow if present but corrupt
	var old_row := get_node_or_null("NavRow")
	if old_row:
		old_row.queue_free()

	var nav_row := HBoxContainer.new()
	nav_row.name = "NavRow"
	nav_row.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	nav_row.offset_left   = 30.0
	nav_row.offset_right  = 610.0
	nav_row.offset_top    = 498.0
	nav_row.offset_bottom = 548.0
	nav_row.add_theme_constant_override("separation", 12)
	add_child(nav_row)

	_prev_btn = Button.new()
	_prev_btn.name = "PrevBtn"
	_prev_btn.text = "< Prev"
	_prev_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav_row.add_child(_prev_btn)

	_page_label = Label.new()
	_page_label.name = "PageLabel"
	_page_label.text = "1 / 1"
	_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav_row.add_child(_page_label)

	_next_btn = Button.new()
	_next_btn.name = "NextBtn"
	_next_btn.text = "Next >"
	_next_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav_row.add_child(_next_btn)

	# Back button – also build programmatically if missing
	if _back_btn == null:
		_back_btn = Button.new()
		_back_btn.name = "BackBtn"
		_back_btn.text = "<- Back"
		_back_btn.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
		_back_btn.offset_left   = 30.0
		_back_btn.offset_right  = 610.0
		_back_btn.offset_top    = 558.0
		_back_btn.offset_bottom = 610.0
		add_child(_back_btn)



func _show_entry(idx: int) -> void:
	if _entries.is_empty():
		return
	_current_idx = clamp(idx, 0, _entries.size() - 1)
	var entry: Dictionary = _entries[_current_idx]
	var tribe_key: String  = entry.get("tribe", "")
	var tribe_data: Dictionary = Global.get_tribe_data(tribe_key)

	# Tribe colour swatch – use get_node_or_null to guard against stale PCK binary
	var hex: String = tribe_data.get("color", "#888888")
	var swatch := get_node_or_null("TribeSwatch") as ColorRect
	if swatch:
		swatch.color = Color(hex)

	# Verse ref + text
	var verse_ref  := get_node_or_null("PageCard/CardContent/VerseRef")  as Label
	var verse_text := get_node_or_null("PageCard/CardContent/VerseText") as Label
	if verse_ref:  verse_ref.text  = entry.get("ref",  "—")
	if verse_text: verse_text.text = entry.get("text", "")

	# Memorised badge
	var memo_lbl := get_node_or_null("PageCard/CardContent/MemoBadge") as Label
	if memo_lbl:
		if VerseVault.is_memorized(entry.get("ref", "")):
			memo_lbl.text = "★ Memorised"
			memo_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4, 1))
		else:
			memo_lbl.text = ""

	# Nature fact (only present on nature-type entries)
	var nature_ref_lbl  := get_node_or_null("PageCard/CardContent/NatureRef")  as Label
	var nature_fact_lbl := get_node_or_null("PageCard/CardContent/NatureFact") as Label
	if entry.get("type", "") == "nature":
		if nature_ref_lbl:  nature_ref_lbl.text  = entry.get("ref", "")
		if nature_fact_lbl: nature_fact_lbl.text = entry.get("fact", "")
	else:
		if nature_ref_lbl:  nature_ref_lbl.text  = ""
		if nature_fact_lbl: nature_fact_lbl.text = ""

	# Page counter
	if _page_label:
		_page_label.text = "%d / %d" % [_current_idx + 1, _entries.size()]

	# Fade in card (safe – if PageCard is absent just skip tween)
	var page_card := get_node_or_null("PageCard")
	if page_card:
		page_card.modulate = Color(1, 1, 1, 0)
		var tw := create_tween()
		tw.tween_property(page_card, "modulate:a", 1.0, 0.35)


func _on_prev() -> void:
	if _current_idx > 0:
		_show_entry(_current_idx - 1)

func _on_next() -> void:
	if _current_idx < _entries.size() - 1:
		_show_entry(_current_idx + 1)

func _on_back() -> void:
	var back_scene := "res://scenes/MainMenu.tscn"
	# If a quest is stored, go back to it (future enhancement)
	var res := get_tree().change_scene_to_file(back_scene)
	if res != OK:
		push_error("VerseVaultScene: failed to go back to %s" % back_scene)
