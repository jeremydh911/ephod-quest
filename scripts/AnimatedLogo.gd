extends Control
# ─────────────────────────────────────────────────────────────────────────────
# AnimatedLogo.gd – Twelve Stones Animated Intro
#
# Sequence (≈6 seconds total):
#   0.0s  Black screen  →  background art fades in
#   0.8s  12 ephod stones animate into Exodus 28 formation (pop + glow)
#   2.5s  Title "TWELVE STONES" fades in gold
#   3.4s  Subtitle  "Twelve Tribes · One Ephod · One Story"  fades in
#   5.2s  Entire screen fades to black  →  MainMenu
#
# "Behold, how good and how pleasant it is for brethren to dwell together
#  in unity!" – Psalm 133:1
# ─────────────────────────────────────────────────────────────────────────────

# Ephod stone colours (Exodus 28:17-20, row order matches Exodus 28 ordering)
# Reuben→Benjamin  /  4 rows of 3
const STONE_COLORS: Array[Color] = [
	Color(0.77, 0.12, 0.23, 1), # Reuben   – carnelian / ruby
	Color(0.22, 0.55, 0.82, 1), # Simeon   – lapis lazuli
	Color(0.09, 0.60, 0.41, 1), # Levi     – emerald
	Color(0.90, 0.76, 0.10, 1), # Judah    – turquoise / gold
	Color(0.18, 0.45, 0.84, 1), # Dan      – sapphire
	Color(0.85, 0.85, 0.92, 1), # Naphtali – diamond / white
	Color(0.85, 0.42, 0.10, 1), # Gad      – jacinth / amber-red
	Color(0.10, 0.10, 0.10, 1), # Asher    – onyx / black
	Color(0.56, 0.12, 0.78, 1), # Issachar – amethyst
	Color(0.20, 0.72, 0.72, 1), # Zebulun  – chrysolite / sea-green
	Color(0.60, 0.42, 0.26, 1), # Joseph   – shoham / banded stone
	Color(0.78, 0.22, 0.14, 1), # Benjamin – jasper
]

const TRIBE_NAMES: Array[String] = [
	"Reuben","Simeon","Levi","Judah","Dan","Naphtali",
	"Gad","Asher","Issachar","Zebulun","Joseph","Benjamin"
]

const _NEXT_SCENE := "res://scenes/MainMenu.tscn"

var _fade_rect: ColorRect

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Allow skipping with any input
	set_process_input(true)

	# Build all visuals then run sequence
	await _run_intro()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_go_to_main()

# ─────────────────────────────────────────────────────────────────────────────
func _run_intro() -> void:
	var vp := get_viewport().get_visible_rect().size

	# ── 1. Black background ───────────────────────────────────────────────────
	var bg_black := ColorRect.new()
	bg_black.color = Color.BLACK
	bg_black.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg_black)

	# ── 2. Background artwork (img_13 — main menu panorama) ──────────────────
	const ART := "res://assets/sprites/raw/img_13.jpg"
	var bg_art := TextureRect.new()
	bg_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_art.modulate.a = 0.0
	if ResourceLoader.exists(ART):
		bg_art.texture = load(ART)
	add_child(bg_art)

	# ── 3. Overlay vignette (dark edges) ─────────────────────────────────────
	var vignette := ColorRect.new()
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.color = Color(0, 0, 0, 0.45)
	add_child(vignette)

	# ── 4. Gems container — centred, ephod 4×3 grid layout ───────────────────
	var gems_root := Node2D.new()
	gems_root.position = vp * 0.5 + Vector2(0, -40)
	add_child(gems_root)

	var gem_nodes: Array[Node] = []
	var gem_glows: Array[Node] = []

	# 4 rows × 3 cols matching Exodus 28:17-20 ordering
	const COLS   := 3
	const ROWS   := 4
	const GAP    := 54.0   # pixels between gems
	const RADIUS := 14.0   # gem circle radius

	for i in 12:
		var col: int = i % COLS
		var row: int = i / COLS
		var offset := Vector2(
			(col - 1) * GAP,
			(row - 1.5) * GAP
		)

		# Outer glow (larger, semi-transparent)
		var glow := ColorRect.new()
		glow.custom_minimum_size = Vector2(RADIUS * 3.6, RADIUS * 3.6)
		glow.pivot_offset = Vector2(RADIUS * 1.8, RADIUS * 1.8)
		glow.position = Vector2(gems_root.position.x + offset.x - RADIUS * 1.8,
		                        gems_root.position.y + offset.y - RADIUS * 1.8)
		glow.color = Color(STONE_COLORS[i].r, STONE_COLORS[i].g, STONE_COLORS[i].b, 0.0)
		glow.scale = Vector2.ZERO
		add_child(glow)
		gem_glows.append(glow)

		# Gem circle
		var gem := ColorRect.new()
		gem.custom_minimum_size = Vector2(RADIUS * 2, RADIUS * 2)
		gem.pivot_offset = Vector2(RADIUS, RADIUS)
		gem.position = Vector2(gems_root.position.x + offset.x - RADIUS,
		                       gems_root.position.y + offset.y - RADIUS)
		gem.color = STONE_COLORS[i]
		gem.scale = Vector2.ZERO
		add_child(gem)
		gem_nodes.append(gem)

	# ── 5. Title label ────────────────────────────────────────────────────────
	var title_lbl := Label.new()
	title_lbl.text = "TWELVE STONES"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_lbl.add_theme_font_size_override("font_size", 52)
	title_lbl.add_theme_color_override("font_color", Color(1, 0.87, 0.22, 1)) # Pure Gold
	title_lbl.add_theme_color_override("font_shadow_color", Color(0.5, 0.35, 0, 0.9))
	title_lbl.add_theme_constant_override("shadow_offset_x", 2)
	title_lbl.add_theme_constant_override("shadow_offset_y", 3)
	title_lbl.offset_top = vp.y * 0.64
	title_lbl.modulate.a = 0.0
	add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "Twelve Tribes · One Ephod · One Story"
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	sub_lbl.add_theme_font_size_override("font_size", 18)
	sub_lbl.add_theme_color_override("font_color", Color(0.96, 0.90, 0.76, 1)) # Parchment
	sub_lbl.offset_top = vp.y * 0.72
	sub_lbl.modulate.a = 0.0
	add_child(sub_lbl)

	# ── 6. Fade overlay for exit transition ───────────────────────────────────
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.z_index = 99
	add_child(_fade_rect)

	# ── 7. Play sacred spark audio ────────────────────────────────────────────
	const INTRO_SFX := "res://assets/audio/sfx/bells_small.wav"
	if ResourceLoader.exists(INTRO_SFX):
		AudioManager.play_sfx(INTRO_SFX)

	# ── 8. ANIMATE: Background art fade-in ───────────────────────────────────
	var tw := create_tween().set_parallel(true)
	tw.tween_property(bg_art, "modulate:a", 1.0, 1.2).set_ease(Tween.EASE_IN_OUT)
	await tw.finished

	# ── 9. ANIMATE: Stones pop in one by one ─────────────────────────────────
	for i in 12:
		var gt := create_tween().set_parallel(true)
		gt.tween_property(gem_nodes[i], "scale", Vector2.ONE, 0.18)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		gt.tween_property(gem_glows[i], "scale", Vector2.ONE, 0.3)\
			.set_ease(Tween.EASE_OUT)
		gt.tween_property(gem_glows[i], "color:a", 0.35, 0.3)\
			.set_ease(Tween.EASE_IN_OUT)
		# Play a soft chime for the stone
		if i == 0 or i == 6:
			const CHIME := "res://assets/audio/sfx/chime_cascade.wav"
			if ResourceLoader.exists(CHIME):
				AudioManager.play_sfx(CHIME)
		await get_tree().create_timer(0.10).timeout

	await get_tree().create_timer(0.3).timeout

	# ── 10. ANIMATE: Title fade-in ────────────────────────────────────────────
	var tw2 := create_tween()
	tw2.tween_property(title_lbl, "modulate:a", 1.0, 0.70).set_ease(Tween.EASE_IN_OUT)
	await tw2.finished

	await get_tree().create_timer(0.4).timeout

	var tw3 := create_tween()
	tw3.tween_property(sub_lbl, "modulate:a", 1.0, 0.55).set_ease(Tween.EASE_IN)
	await tw3.finished

	await get_tree().create_timer(1.4).timeout

	# ── 11. Fade out → MainMenu ───────────────────────────────────────────────
	_go_to_main()

# ─────────────────────────────────────────────────────────────────────────────
func _go_to_main() -> void:
	set_process_input(false)
	if _fade_rect == null:
		get_tree().change_scene_to_file(_NEXT_SCENE)
		return
	var tw := create_tween()
	tw.tween_property(_fade_rect, "color:a", 1.0, 0.65).set_ease(Tween.EASE_IN)
	await tw.finished
	var res := get_tree().change_scene_to_file(_NEXT_SCENE)
	if res != OK:
		push_error("AnimatedLogo: failed to load MainMenu")