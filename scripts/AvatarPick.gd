extends Control
# ─────────────────────────────────────────────────────────────────────────────
# AvatarPick.gd  –  Twelve Stones / Ephod Quest
# Tribe selection grid → avatar cards → confirm → save to Global → next scene.
# "Before I formed you in the womb I knew you" – Jeremiah 1:5
# ─────────────────────────────────────────────────────────────────────────────

# ── Node refs ────────────────────────────────────────────────────────────────
@onready var _tribe_grid:       GridContainer  = $Margin/VBox/Content/LeftPanel/LeftVBox/TribeScroll/TribeGrid
@onready var _right_panel:      PanelContainer = $Margin/VBox/Content/RightPanel
@onready var _right_vbox:       VBoxContainer  = $Margin/VBox/Content/RightPanel/RightScroll/RightVBox
@onready var _tribe_title:      Label          = $Margin/VBox/Content/RightPanel/RightScroll/RightVBox/TribeTitleLabel
@onready var _tribe_trait:      Label          = $Margin/VBox/Content/RightPanel/RightScroll/RightVBox/TribeTraitLabel
@onready var _avatar_grid:      GridContainer  = $Margin/VBox/Content/RightPanel/RightScroll/RightVBox/AvatarGrid
@onready var _verse_ref_label:  Label          = $Margin/VBox/Content/RightPanel/RightScroll/RightVBox/VersePanel/VerseVBox/VerseRefLabel
@onready var _verse_text_label: Label          = $Margin/VBox/Content/RightPanel/RightScroll/RightVBox/VersePanel/VerseVBox/VerseTextLabel
@onready var _back_tribe_btn:   Button         = $Margin/VBox/Content/RightPanel/RightScroll/RightVBox/BackTribeBtn
@onready var _back_menu_btn:    Button         = $Margin/VBox/Header/BackMenuBtn

# Tribe order — matches Exodus 28 ephod stone order
const TRIBE_ORDER: Array[String] = [
	"reuben", "simeon", "levi", "judah",
	"dan", "naphtali", "gad", "asher",
	"issachar", "zebulun", "joseph", "benjamin"
]

var _selected_tribe: String = ""
var _selected_avatar: Dictionary = {}

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	# Psalm 139:14 – each player is unique, made with intention
	AudioManager.play_music("res://assets/audio/music/avatar_pick.ogg")
	_back_menu_btn.pressed.connect(_on_back_menu)
	_back_tribe_btn.pressed.connect(_on_back_tribes)
	_populate_tribe_grid()

# ─────────────────────────────────────────────────────────────────────────────
# TRIBE GRID
# ─────────────────────────────────────────────────────────────────────────────
func _populate_tribe_grid() -> void:
	for child in _tribe_grid.get_children():
		child.queue_free()

	for tribe_key in TRIBE_ORDER:
		var data: Dictionary = Global.get_tribe_data(tribe_key)
		var col := Color(data.get("color", "#888888"))

		var card := _make_tribe_card(tribe_key, data, col)
		_tribe_grid.add_child(card)

func _make_tribe_card(tribe_key: String, data: Dictionary, col: Color) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(130, 100)

	# Tinted background
	var ss := StyleBoxFlat.new()
	ss.bg_color = Color(col.r, col.g, col.b, 0.22)
	ss.border_color = col
	ss.set_border_width_all(2)
	ss.set_corner_radius_all(10)
	card.add_theme_stylebox_override("panel", ss)

	var vb := VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 6)
	card.add_child(vb)

	# Gem colour circle placeholder
	var gem_rect := ColorRect.new()
	gem_rect.color = col
	gem_rect.custom_minimum_size = Vector2(36, 36)
	gem_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vb.add_child(gem_rect)

	var name_lbl := Label.new()
	name_lbl.text = data.get("display", tribe_key.capitalize())
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 15)
	vb.add_child(name_lbl)

	var gem_lbl := Label.new()
	gem_lbl.text = data.get("stone_name", "")
	gem_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gem_lbl.add_theme_font_size_override("font_size", 11)
	gem_lbl.modulate = Color(0.5, 0.38, 0.15, 1)
	vb.add_child(gem_lbl)

	# Already-collected indicator
	if tribe_key in Global.stones:
		var done_lbl := Label.new()
		done_lbl.text = "✓ Stone Collected"
		done_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		done_lbl.add_theme_font_size_override("font_size", 11)
		done_lbl.modulate = Color(0.15, 0.6, 0.25, 1)
		vb.add_child(done_lbl)

	# Touch-friendly button overlay
	var btn := Button.new()
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.anchors_preset = Control.PRESET_FULL_RECT
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.add_child(btn)
	btn.pressed.connect(func(): _on_tribe_selected(tribe_key))

	return card

# ─────────────────────────────────────────────────────────────────────────────
# AVATAR PANEL
# ─────────────────────────────────────────────────────────────────────────────
func _on_tribe_selected(tribe_key: String) -> void:
	_selected_tribe = tribe_key
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")

	var data := Global.get_tribe_data(tribe_key)
	var col  := Color(data.get("color", "#888888"))

	# Update labels
	_tribe_title.text = "Tribe of %s" % data.get("display", tribe_key.capitalize())
	_tribe_title.modulate = col
	_tribe_trait.text = data.get("trait", "")

	# Verse preview
	_verse_ref_label.text = "✦ " + data.get("quest_verse_ref", "")
	_verse_text_label.text = "\"" + data.get("quest_verse", "") + "\""

	# Populate avatar cards
	for child in _avatar_grid.get_children():
		child.queue_free()
	var avatars := Global.get_avatars_for_tribe(tribe_key)
	for av in avatars:
		var card := _make_avatar_card(av, col)
		_avatar_grid.add_child(card)

	_right_panel.visible = true
	# Animate panel in with a gentle tween
	_right_panel.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_right_panel, "modulate:a", 1.0, 0.35)

func _make_avatar_card(av: Dictionary, col: Color) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 220)

	var ss := StyleBoxFlat.new()
	ss.bg_color = Color(1.0, 0.98, 0.93, 1.0)
	ss.border_color = col
	ss.set_border_width_all(2)
	ss.set_corner_radius_all(12)
	card.add_theme_stylebox_override("panel", ss)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	card.add_child(vb)

	# Portrait placeholder (coloured rect; replace with Texture2D when art ready)
	var portrait := ColorRect.new()
	portrait.color = Color(col.r, col.g, col.b, 0.35)
	portrait.custom_minimum_size = Vector2(0, 80)
	portrait.size_flags_horizontal = Control.SIZE_FILL
	vb.add_child(portrait)

	# Name + age
	var name_lbl := Label.new()
	name_lbl.text = av.get("name", "") + "  (age %d)" % av.get("age", 0)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 15)
	vb.add_child(name_lbl)

	# Diversity detail (skin / build) in small muted text
	var detail_lbl := Label.new()
	detail_lbl.text = av.get("skin", "") + " · " + av.get("build", "")
	detail_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_lbl.add_theme_font_size_override("font_size", 11)
	detail_lbl.modulate = Color(0.5, 0.39, 0.2, 1)
	vb.add_child(detail_lbl)

	# Backstory
	var story_lbl := Label.new()
	story_lbl.text = av.get("backstory", "")
	story_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_lbl.add_theme_font_size_override("font_size", 12)
	story_lbl.size_flags_horizontal = Control.SIZE_FILL
	vb.add_child(story_lbl)

	# Gameplay edge
	var edge_lbl := Label.new()
	edge_lbl.text = "✦ " + av.get("gameplay_edge", "")
	edge_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	edge_lbl.add_theme_font_size_override("font_size", 11)
	edge_lbl.modulate = col
	vb.add_child(edge_lbl)

	# Select button
	var btn := Button.new()
	btn.text = "Choose %s" % av.get("name", "")
	btn.custom_minimum_size = Vector2(0, 44)
	btn.add_theme_font_size_override("font_size", 14)
	vb.add_child(btn)
	btn.pressed.connect(func(): _on_avatar_selected(av))

	return card

# ─────────────────────────────────────────────────────────────────────────────
# CONFIRM SELECTION
# ─────────────────────────────────────────────────────────────────────────────
func _on_avatar_selected(av: Dictionary) -> void:
	# "You did not choose me, but I chose you" – John 15:16
	_selected_avatar = av
	AudioManager.play_sfx("res://assets/audio/sfx/select.wav")

	Global.selected_tribe  = _selected_tribe
	Global.selected_avatar = av.get("key", "")
	Global.save_game()

	# Show brief confirmation overlay, then proceed
	_show_confirm_then_continue()

func _show_confirm_then_continue() -> void:
	# Build a simple overlay label
	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	add_child(overlay)

	var lbl := Label.new()
	var av_name: String = _selected_avatar.get("name", "")
	var tribe_display: String = Global.get_tribe_data(_selected_tribe).get("display", "")
	lbl.text = "Shalom, %s!\nYou walk with the tribe of %s." % [av_name, tribe_display]
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.anchors_preset = Control.PRESET_FULL_RECT
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.modulate = Color(1, 1, 1, 0)
	overlay.add_child(lbl)

	var tw := create_tween()
	tw.tween_property(overlay, "color", Color(0, 0, 0, 0.72), 0.4)
	tw.parallel().tween_property(lbl, "modulate", Color(1, 1, 1, 1), 0.4)
	tw.tween_interval(1.8)
	tw.tween_callback(_go_to_quest)

func _go_to_quest() -> void:
	# If already in multiplayer, let MultiplayerLobby handle scene transition
	if multiplayer.multiplayer_peer != null:
		MultiplayerLobby.start_game()
		return
	# Single-player: go to Quest for selected tribe (or Quest1 as fallback)
	# Quest numbers follow IMPLEMENTATION order, not Exodus 28 tribe order.
	# Quest1=Reuben, Quest2=Judah, Quest3=Levi, Quest4=Dan, Quest5-12=stubs
	var quest_map: Dictionary = {
		"reuben":   "res://scenes/Quest1.tscn",
		"judah":    "res://scenes/Quest2.tscn",
		"levi":     "res://scenes/Quest3.tscn",
		"dan":      "res://scenes/Quest4.tscn",
		"naphtali": "res://scenes/Quest5.tscn",
		"simeon":   "res://scenes/Quest6.tscn",
		"gad":      "res://scenes/Quest7.tscn",
		"asher":    "res://scenes/Quest8.tscn",
		"issachar": "res://scenes/Quest9.tscn",
		"zebulun":  "res://scenes/Quest10.tscn",
		"joseph":   "res://scenes/Quest11.tscn",
		"benjamin": "res://scenes/Quest12.tscn"
	}
	var target: String = quest_map.get(_selected_tribe, "res://scenes/Quest1.tscn")
	var result := get_tree().change_scene_to_file(target)
	if result != OK:
		# Quest not yet built — fall back to Quest1
		result = get_tree().change_scene_to_file("res://scenes/Quest1.tscn")
		if result != OK:
			push_error("[AvatarPick] Cannot load quest scene. error=%d" % result)

# ─────────────────────────────────────────────────────────────────────────────
# NAVIGATION
# ─────────────────────────────────────────────────────────────────────────────
func _on_back_tribes() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	_right_panel.visible = false
	_selected_tribe = ""
	_selected_avatar = {}

func _on_back_menu() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	var result := get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	if result != OK:
		push_error("[AvatarPick] Failed to return to main menu. error=%d" % result)
