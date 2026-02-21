extends Control
# ─────────────────────────────────────────────────────────────────────────────
# AvatarPick.gd  –  Tribe & Avatar selection screen
# Populates TribeGrid from Global.TRIBES, then shows that tribe's avatars.
# Saves selection to Global.selected_tribe / Global.selected_avatar and
# routes to the correct Quest scene.
# "Before I formed you in the womb I knew you" – Jeremiah 1:5
# ─────────────────────────────────────────────────────────────────────────────

# ── Quest scene routing (tribe_key → scene path) ────────────────────────────
const QUEST_SCENES: Dictionary = {
	"reuben":   "res://scenes/World1.tscn",
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
	"benjamin": "res://scenes/Quest12.tscn",
}

# ── Tribe display order (Exodus 28 ephod rows) ───────────────────────────────
const TRIBE_ORDER: Array[String] = [
	"reuben", "simeon", "levi", "judah", "dan", "naphtali",
	"gad", "asher", "issachar", "zebulun", "joseph", "benjamin"
]

# ── Node references ──────────────────────────────────────────────────────────
@onready var _tribe_grid:    GridContainer  = $Margin/VBox/Content/LeftPanel/LeftVBox/TribeScroll/TribeGrid
@onready var _right_panel:   PanelContainer = $Margin/VBox/Content/RightPanel
@onready var _tribe_title:   Label          = $Margin/VBox/Content/RightPanel/RightScroll/RightVBox/TribeTitleLabel
@onready var _tribe_trait:   Label          = $Margin/VBox/Content/RightPanel/RightScroll/RightVBox/TribeTraitLabel
@onready var _avatar_grid:   GridContainer  = $Margin/VBox/Content/RightPanel/RightScroll/RightVBox/AvatarGrid
@onready var _verse_ref:     Label          = $Margin/VBox/Content/RightPanel/RightScroll/RightVBox/VersePanel/VerseVBox/VerseRefLabel
@onready var _verse_text:    Label          = $Margin/VBox/Content/RightPanel/RightScroll/RightVBox/VersePanel/VerseVBox/VerseTextLabel
@onready var _back_tribe_btn:Button         = $Margin/VBox/Content/RightPanel/RightScroll/RightVBox/BackTribeBtn
@onready var _confirm_btn:   Button         = $Margin/VBox/Footer/ConfirmBtn
@onready var _selection_lbl: Label          = $Margin/VBox/Footer/SelectionLabel
@onready var _back_menu_btn: Button         = $Margin/VBox/Header/BackMenuBtn

var _selected_tribe:  String = ""
var _selected_avatar: String = ""

const VisualEnvironment := preload("res://scripts/VisualEnvironment.gd")

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	# "Before I formed you in the womb I knew you" – Jeremiah 1:5
	VisualEnvironment.add_scene_background(self, "avatar_pick")

	# "Soft Tap of Yes" — the gentle affirming moment of choosing  (1 Samuel 16:7)
	const AVATAR_MUSIC := "res://assets/audio/music/soft_tap_of_yes.wav"
	AudioManager.play_music(AVATAR_MUSIC if ResourceLoader.exists(AVATAR_MUSIC) else "res://assets/audio/music/sacred_spark.wav")
	_build_tribe_grid()
	_back_tribe_btn.pressed.connect(_show_tribe_list)
	_back_menu_btn.pressed.connect(_go_back_menu)
	_confirm_btn.pressed.connect(_confirm_selection)
	_right_panel.visible = false
	_confirm_btn.visible = false

# ─────────────────────────────────────────────────────────────────────────────
# BUILD TRIBE GRID
# ─────────────────────────────────────────────────────────────────────────────
func _build_tribe_grid() -> void:
	for child in _tribe_grid.get_children():
		child.queue_free()

	for tribe_key in TRIBE_ORDER:
		var data: Dictionary = Global.TRIBES.get(tribe_key, {})
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 52)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# Two-line label: tribe name + stone name
		var stone: String = data.get("stone_name", "")
		btn.text = "%s\n(%s)" % [data.get("display", tribe_key.capitalize()), stone] if stone else data.get("display", tribe_key.capitalize())
		# Tribe-coloured background
		var hex: String = data.get("color", "#888888")
		var col := Color(hex)
		var style := StyleBoxFlat.new()
		style.bg_color          = col
		style.corner_radius_top_left     = 8
		style.corner_radius_top_right    = 8
		style.corner_radius_bottom_left  = 8
		style.corner_radius_bottom_right = 8
		style.content_margin_left  = 8
		style.content_margin_right = 8
		btn.add_theme_stylebox_override("normal", style)
		var hover_style := style.duplicate() as StyleBoxFlat
		hover_style.bg_color = col.lightened(0.18)
		btn.add_theme_stylebox_override("hover", hover_style)
		btn.add_theme_color_override("font_color",       Color.WHITE)
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(func(): _on_tribe_selected(tribe_key))
		_tribe_grid.add_child(btn)

# ─────────────────────────────────────────────────────────────────────────────
# TRIBE SELECTED — populate right panel
# ─────────────────────────────────────────────────────────────────────────────
func _on_tribe_selected(tribe_key: String) -> void:
	_selected_tribe  = tribe_key
	_selected_avatar = ""
	_confirm_btn.visible = false
	_selection_lbl.text  = ""

	var data: Dictionary = Global.TRIBES.get(tribe_key, {})
	_tribe_title.text = data.get("display", tribe_key.capitalize())
	_tribe_trait.text = data.get("trait", "")
	_verse_ref.text   = data.get("quest_verse_ref", "")
	_verse_text.text  = '"' + data.get("quest_verse", "") + '"'

	_build_avatar_grid(tribe_key)
	_right_panel.visible = true
	AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")

# ─────────────────────────────────────────────────────────────────────────────
# BUILD AVATAR CARDS
# ─────────────────────────────────────────────────────────────────────────────
func _build_avatar_grid(tribe_key: String) -> void:
	for child in _avatar_grid.get_children():
		child.queue_free()
	var avatars: Array = Global.AVATARS.get(tribe_key, [])
	var tribe_col := Color(Global.TRIBES.get(tribe_key, {}).get("color", "#888888"))
	for av in avatars:
		_avatar_grid.add_child(_make_avatar_card(av, tribe_col))

# ─────────────────────────────────────────────────────────────────────────────
# AVATAR SVG MAPPER  — translate Global.AVATARS properties → SVG path
# "I am fearfully and wonderfully made" – Psalm 139:14
# ─────────────────────────────────────────────────────────────────────────────
static func _avatar_svg_path(av: Dictionary) -> String:
	var skin_raw: String = (av.get("skin", "medium") as String).to_lower()
	var hair_raw: String = (av.get("hair", "black curly") as String).to_lower()
	var eyes_raw: String = (av.get("eyes", "brown") as String).to_lower()

	# Map descriptive skin → SVG key
	var skin_key: String = "medium"
	if skin_raw.contains("light") or skin_raw.contains("pale") or skin_raw.contains("fair") or skin_raw == "beige":
		skin_key = "light"
	elif skin_raw.contains("deep") or skin_raw.contains("mahogany") or skin_raw.contains("rich brown"):
		skin_key = "deep"
	elif skin_raw.contains("olive") or skin_raw.contains("copper"):
		skin_key = "olive"

	# Map descriptive hair → SVG key
	var hair_key: String = "black_curly"
	if hair_raw.contains("loc"):
		hair_key = "dark_locs"
	elif hair_raw.contains("wave") or hair_raw.contains("wavy") or hair_raw.contains("curl") or hair_raw.contains("coil") or hair_raw.contains("crop"):
		hair_key = "black_curly"
	elif hair_raw.contains("braid") or hair_raw.contains("bun") or hair_raw.contains("updo") or hair_raw.contains("plait") or hair_raw.contains("long") or hair_raw.contains("auburn") or hair_raw.contains("copper"):
		hair_key = "gold_straight"
	elif hair_raw.contains("brown") or hair_raw.contains("dark wav") or hair_raw.contains("blond") or hair_raw.contains("gold"):
		hair_key = "brown_waves"

	# Map eye colour → e1 (warm) / e2 (cool)
	var eye_key: String = "e1"
	if eyes_raw.contains("blue") or eyes_raw.contains("green") or eyes_raw.contains("grey") or eyes_raw.contains("gray"):
		eye_key = "e2"

	var path := "res://assets/sprites/avatars/avatar_%s_%s_%s.svg" % [skin_key, hair_key, eye_key]
	if ResourceLoader.exists(path):
		return path
	# Fallback to any light/black_curly/e1
	return "res://assets/sprites/avatars/avatar_light_black_curly_e1.svg"

func _make_avatar_card(av: Dictionary, tribe_col: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(160, 0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	# Portrait: SVG avatar image → fallback to coloured initial swatch
	# "God sees not as man sees…God looks at the heart" – 1 Samuel 16:7
	var svg_path := _avatar_svg_path(av)
	if ResourceLoader.exists(svg_path):
		var portrait := TextureRect.new()
		portrait.texture = load(svg_path) as Texture2D
		portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.custom_minimum_size = Vector2(0, 80)
		portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(portrait)
	else:
		# Fallback: coloured swatch with initial letter
		var swatch := ColorRect.new()
		swatch.color = tribe_col.darkened(0.1)
		swatch.custom_minimum_size = Vector2(0, 64)
		vbox.add_child(swatch)
		var init_lbl := Label.new()
		init_lbl.text = av.get("name", "?")[0]
		init_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		init_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		init_lbl.add_theme_font_size_override("font_size", 32)
		init_lbl.add_theme_color_override("font_color", Color.WHITE)
		init_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		swatch.add_child(init_lbl)

	# Name + age
	var name_lbl := Label.new()
	name_lbl.text = "%s, %d" % [av.get("name", ""), av.get("age", 0)]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 16)
	vbox.add_child(name_lbl)

	# Backstory
	var story_lbl := Label.new()
	story_lbl.text = av.get("backstory", "")
	story_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_lbl.add_theme_font_size_override("font_size", 12)
	story_lbl.modulate = Color(0.35, 0.27, 0.1, 1)
	vbox.add_child(story_lbl)

	# Gameplay edge
	var edge_lbl := Label.new()
	edge_lbl.text = "✦ " + av.get("gameplay_edge", "")
	edge_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	edge_lbl.add_theme_font_size_override("font_size", 12)
	edge_lbl.modulate = Color(0.6, 0.4, 0.0, 1)
	vbox.add_child(edge_lbl)

	# Choose button
	var select_btn := Button.new()
	select_btn.text = "Choose"
	select_btn.custom_minimum_size = Vector2(0, 44)
	var av_key: String = av.get("key", "")
	var av_name: String = av.get("name", "")
	select_btn.pressed.connect(func(): _on_avatar_selected(av_key, av_name))
	vbox.add_child(select_btn)

	return panel

# ─────────────────────────────────────────────────────────────────────────────
# AVATAR SELECTED
# ─────────────────────────────────────────────────────────────────────────────
func _on_avatar_selected(avatar_key: String, avatar_name: String) -> void:
	_selected_avatar = avatar_key
	var tribe_display: String = Global.TRIBES.get(_selected_tribe, {}).get("display", _selected_tribe)
	_selection_lbl.text  = "%s  ·  Tribe of %s" % [avatar_name, tribe_display]
	_confirm_btn.visible = true
	AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")

# ─────────────────────────────────────────────────────────────────────────────
# CONFIRM — save to Global and load quest
# ─────────────────────────────────────────────────────────────────────────────
func _confirm_selection() -> void:
	if _selected_tribe == "" or _selected_avatar == "":
		return
	Global.selected_tribe  = _selected_tribe
	Global.selected_avatar = _selected_avatar
	Global.save_game()
	AudioManager.play_sfx("res://assets/audio/sfx/stone_unlock.wav")
	var scene_path: String = QUEST_SCENES.get(_selected_tribe, "res://scenes/Quest1.tscn")
	var result := get_tree().change_scene_to_file(scene_path)
	if result != OK:
		push_error("[AvatarPick] Failed to load %s — error %d" % [scene_path, result])

# ─────────────────────────────────────────────────────────────────────────────
# BACK HELPERS
# ─────────────────────────────────────────────────────────────────────────────
func _show_tribe_list() -> void:
	_right_panel.visible = false
	_selected_tribe  = ""
	_selected_avatar = ""
	_confirm_btn.visible = false
	_selection_lbl.text  = ""

func _go_back_menu() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	var result := get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	if result != OK:
		push_error("[AvatarPick] Failed to return to MainMenu — error %d" % result)

