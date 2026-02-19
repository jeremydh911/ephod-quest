extends Control
# ─────────────────────────────────────────────────────────────────────────────
# VerseVaultScene.gd  –  Flip-page Journal of collected verses and nature facts
# Shows tribe colour swatch, verse reference, verse text, nature fact,
# and a memorised badge glow.  Navigate Prev / Next between unlocked entries.
# ─────────────────────────────────────────────────────────────────────────────

var _entries: Array[Dictionary] = []
var _current_idx: int = 0

func _ready() -> void:
	_entries = VerseVault.get_all_entries()
	if _entries.is_empty():
		# Fall-back: show first entry regardless of unlock state
		_entries = VerseVault.VAULT.duplicate()

	($NavRow/PrevBtn as Button).pressed.connect(_on_prev)
	($NavRow/NextBtn as Button).pressed.connect(_on_next)
	($BackBtn        as Button).pressed.connect(_on_back)

	_show_entry(_current_idx)

func _show_entry(idx: int) -> void:
	if _entries.is_empty():
		return
	_current_idx = clamp(idx, 0, _entries.size() - 1)
	var entry: Dictionary = _entries[_current_idx]
	var tribe_key: String  = entry.get("tribe", "")
	var tribe_data: Dictionary = Global.get_tribe_data(tribe_key)

	# Tribe colour swatch
	var hex: String = tribe_data.get("color", "#888888")
	($TribeSwatch as ColorRect).color = Color(hex)

	# Verse ref + text
	($PageCard/CardContent/VerseRef  as Label).text = entry.get("ref",  "—")
	($PageCard/CardContent/VerseText as Label).text = entry.get("text", "")

	# Memorised badge
	var memo_lbl := $PageCard/CardContent/MemoBadge as Label
	if VerseVault.is_memorized(entry.get("ref", "")):
		memo_lbl.text = "★ Memorised"
		memo_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4, 1))
	else:
		memo_lbl.text = ""

	# Nature fact (only present on nature-type entries)
	var nature_ref_lbl  := $PageCard/CardContent/NatureRef  as Label
	var nature_fact_lbl := $PageCard/CardContent/NatureFact as Label
	if entry.get("type", "") == "nature":
		nature_ref_lbl.text  = entry.get("ref", "")
		nature_fact_lbl.text = entry.get("fact", "")
	else:
		nature_ref_lbl.text  = ""
		nature_fact_lbl.text = ""

	# Page counter
	($NavRow/PageLabel as Label).text = "%d / %d" % [_current_idx + 1, _entries.size()]

	# Fade in card
	$PageCard.modulate = Color(1, 1, 1, 0)
	var tw := create_tween()
	tw.tween_property($PageCard, "modulate:a", 1.0, 0.35)

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
