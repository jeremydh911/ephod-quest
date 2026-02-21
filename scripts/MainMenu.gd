extends Control
# =============================================================================
# MainMenu.gd  –  Twelve Stones / Ephod Quest
# =============================================================================
# VISUAL LAYERS (back → front):
#   [0] Sky gradient panel       — indigo-night → amber-gold, breathing tween
#   [1] Stars panel              — scattered white dots (night sky residue)
#   [2] Horizon glow bar         — soft warm sunrise strip
#   [3] Distant hills silhouette — 5 gentle hill panels
#   [4] Tribe silhouettes        — 12 tiny figure outlines on horizon
#   [5] Ground strip             — dark earth baseline
#   [6] CPUParticles2D           — golden dust motes drifting upward
#   [7] Ephod breastplate        — 4×3 gem grid, gold frame, shoulder chains
#   [8] Title "TWELVE STONES"    — large letters, pop-in one-by-one
#   [9] Subtitle                 — "Twelve Tribes · One Ephod · One Story"
#  [10] Buttons (from .tscn)     — styled in _style_buttons()
#  [11] Rotating verse strip     — bottom, small italic label
#  [12] Fade rect                — full-screen black, z=100
#
# "Behold, how good and how pleasant it is for brethren to dwell
#  together in unity!" – Psalm 133:1
# =============================================================================

# ── Ephod stone colours (Exodus 28:17-20, Reuben→Benjamin) ───────────────────
const STONE_COLORS: Array[Color] = [
	Color(0.85, 0.12, 0.18, 1), # Reuben   – carnelian / ruby-red
	Color(0.10, 0.32, 0.75, 1), # Simeon   – lapis lazuli
	Color(0.08, 0.62, 0.38, 1), # Levi     – emerald
	Color(0.92, 0.78, 0.08, 1), # Judah    – turquoise / gold (chrysolite)
	Color(0.14, 0.50, 0.88, 1), # Dan      – sapphire
	Color(0.92, 0.92, 0.96, 1), # Naphtali – diamond / white crystal
	Color(0.88, 0.44, 0.08, 1), # Gad      – jacinth / amber-orange
	Color(0.06, 0.06, 0.08, 1), # Asher    – onyx / deep black
	Color(0.58, 0.10, 0.80, 1), # Issachar – amethyst
	Color(0.18, 0.78, 0.72, 1), # Zebulun  – chrysolite / sea-green
	Color(0.62, 0.44, 0.26, 1), # Joseph   – shoham banded stone
	Color(0.80, 0.20, 0.12, 1), # Benjamin – jasper / fiery red
]

const TRIBE_NAMES: Array[String] = [
	"Reuben","Simeon","Levi","Judah","Dan","Naphtali",
	"Gad","Asher","Issachar","Zebulun","Joseph","Benjamin"
]

# Rotating verses shown at the bottom of the menu
const BOTTOM_VERSES: Array[String] = [
	"\"Trust in the LORD with all your heart.\"  — Proverbs 3:5",
	"\"He makes the dawn and the darkness.\"  — Amos 4:13",
	"\"Twelve stones… one for each of the tribes.\"  — Exodus 28:21",
	"\"The LORD bless you and keep you.\"  — Numbers 6:24",
	"\"I am the way and the truth and the life.\"  — John 14:6",
	"\"How good it is when brethren dwell together in unity!\"  — Psalm 133:1",
]

# ── colours ───────────────────────────────────────────────────────────────────
const C_SKY_TOP    := Color(0.06, 0.05, 0.15, 1)   # deep night indigo
const C_SKY_BOT    := Color(0.84, 0.56, 0.22, 1)   # warm amber sunrise
const C_HORIZON    := Color(1.00, 0.92, 0.60, 1)   # bright gold horizon glow
const C_GROUND     := Color(0.22, 0.18, 0.12, 1)   # dark ochre earth
const C_EPHOD_GOLD := Color(0.90, 0.76, 0.28, 1)   # burnished gold
const C_TITLE      := Color(1.00, 0.94, 0.68, 1)   # warm cream-gold title
const C_BTN_BG     := Color(0.06, 0.04, 0.02, 0.76)# near-black translucent
const C_BTN_BORDER := Color(0.78, 0.62, 0.22, 1)   # gold border
const C_BTN_TEXT   := Color(0.98, 0.92, 0.72, 1)   # warm cream text

# ── state ─────────────────────────────────────────────────────────────────────
var _fade_rect: ColorRect
var _gem_rects: Array[ColorRect] = []   # 12 gem ColorRects for pulsing
var _verse_label: Label
var _verse_index: int = 0

# =============================================================================
# ENTRY
# =============================================================================
func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# Play music
	const MUSIC := "res://assets/audio/music/gathering_at_the_gates.wav"
	AudioManager.play_music(MUSIC if ResourceLoader.exists(MUSIC) else "")

	# Load save — show Continue if progress exists
	Global.load_game()

	# Build visuals (back → front)
	_build_sky()
	_build_stars()
	_build_horizon_glow()
	_build_hills()
	_build_tribe_silhouettes()
	_build_ground()
	_build_particles()
	_build_ephod()
	_build_title()
	_build_subtitle()
	_build_verse_strip()
	_style_buttons()
	_build_fade_rect()

	# Wire buttons
	$Buttons/Continue.visible = Global.stones.size() > 0
	$Buttons/Continue.pressed.connect(_on_continue)
	$Buttons/Start.pressed.connect(_on_start)
	$Buttons/Multiplayer.pressed.connect(_on_multiplayer)
	$Buttons/VerseVault.pressed.connect(_on_verse_vault)
	$Buttons/Support.pressed.connect(_on_support)
	$Buttons/Quit.pressed.connect(_on_quit)

	# Raise buttons above all background layers
	move_child($Buttons, get_child_count() - 2)  # just below fade rect

	# Animate verse cycling
	_start_verse_cycle()

	# Entrance: fade in from black
	_fade_rect.color = Color(0, 0, 0, 1)
	var t := create_tween()
	t.tween_property(_fade_rect, "color", Color(0, 0, 0, 0), 1.4)

# =============================================================================
# LAYER 0 — SKY GRADIENT
# =============================================================================
func _build_sky() -> void:
	# Two overlapping rects fade between night-top and warm-bottom
	var sky := Panel.new()
	sky.set_anchors_preset(Control.PRESET_FULL_RECT)
	sky.z_index = -20
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = C_SKY_BOT    # will be gradient-faked with two layers
	sky.add_theme_stylebox_override("panel", style)
	add_child(sky)

	# Top dark overlay — gradient via shader-free hack: a semi-transparent
	# dark rect that covers the top 60%
	var dark_top := ColorRect.new()
	dark_top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	dark_top.anchor_bottom = 0.62
	dark_top.color = C_SKY_TOP
	dark_top.z_index = -19
	dark_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dark_top)

	# Breathing tween — sky subtly warms over 20 s loop
	var tw := create_tween().set_loops()
	tw.tween_method(func(v: float) -> void:
		style.bg_color = C_SKY_BOT.lerp(Color(0.98, 0.74, 0.34, 1), v * 0.18)
	, 0.0, 1.0, 10.0).set_ease(Tween.EASE_IN_OUT)
	tw.tween_method(func(v: float) -> void:
		style.bg_color = Color(0.98, 0.74 + v * 0.02, 0.34, 1).lerp(C_SKY_BOT, v * 0.18)
	, 0.0, 1.0, 10.0).set_ease(Tween.EASE_IN_OUT)

# =============================================================================
# LAYER 1 — STARS
# =============================================================================
func _build_stars() -> void:
	var vp := get_viewport_rect().size
	for i in range(55):
		var s := ColorRect.new()
		var sz := randf_range(1.5, 3.5)
		s.custom_minimum_size = Vector2(sz, sz)
		s.size = Vector2(sz, sz)
		s.position = Vector2(randf_range(0, vp.x), randf_range(0, vp.y * 0.52))
		s.color = Color(1, 1, 1, randf_range(0.25, 0.75))
		s.z_index = -18
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(s)
		# Twinkle each star independently
		var st := create_tween().set_loops()
		st.tween_property(s, "color:a", randf_range(0.05, 0.20), randf_range(0.8, 2.6)) \
			.set_ease(Tween.EASE_IN_OUT)
		st.tween_property(s, "color:a", randf_range(0.50, 0.85), randf_range(0.8, 2.6)) \
			.set_ease(Tween.EASE_IN_OUT)

# =============================================================================
# LAYER 2 — HORIZON GLOW BAR
# =============================================================================
func _build_horizon_glow() -> void:
	var vp := get_viewport_rect().size
	var bar := ColorRect.new()
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.anchor_top    = 0.58
	bar.anchor_bottom = 0.68
	bar.color = Color(C_HORIZON.r, C_HORIZON.g, C_HORIZON.b, 0.55)
	bar.z_index = -17
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bar)
	# Pulse gently
	var gt := create_tween().set_loops()
	gt.tween_property(bar, "color:a", 0.72, 4.0).set_ease(Tween.EASE_IN_OUT)
	gt.tween_property(bar, "color:a", 0.38, 4.0).set_ease(Tween.EASE_IN_OUT)

# =============================================================================
# LAYER 3 — DISTANT HILLS
# =============================================================================
func _build_hills() -> void:
	# Soft hill silhouettes painted as rounded rect panels
	var vp := get_viewport_rect().size
	var hill_data := [
		[0.0,  0.60, 0.45, 0.70, Color(0.36, 0.28, 0.18, 0.85)],
		[0.25, 0.62, 0.30, 0.70, Color(0.30, 0.24, 0.14, 0.90)],
		[0.55, 0.61, 0.35, 0.70, Color(0.34, 0.26, 0.16, 0.87)],
		[0.78, 0.63, 0.28, 0.70, Color(0.28, 0.22, 0.13, 0.92)],
		[0.88, 0.60, 0.20, 0.70, Color(0.32, 0.25, 0.15, 0.88)],
	]
	for d in hill_data:
		var h := Panel.new()
		h.anchor_left   = d[0]
		h.anchor_top    = d[1]
		h.anchor_right  = d[0] + d[2]
		h.anchor_bottom = d[3]
		h.layout_mode = 1
		h.z_index = -16
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sty := StyleBoxFlat.new()
		sty.bg_color           = d[4]
		sty.corner_radius_top_left  = 300
		sty.corner_radius_top_right = 300
		h.add_theme_stylebox_override("panel", sty)
		add_child(h)

# =============================================================================
# LAYER 4 — TRIBE SILHOUETTES (12 tiny figures on the horizon)
# "He sets the solitary in families." – Psalm 68:6
# =============================================================================
func _build_tribe_silhouettes() -> void:
	var vp := get_viewport_rect().size
	var y_base: float = vp.y * 0.635   # stand on the horizon line
	var total: float  = vp.x * 0.72
	var start_x: float = vp.x * 0.14
	var spacing: float = total / 11.0

	for i in range(12):
		var fig := _make_figure(i)
		var cx: float = start_x + spacing * float(i)
		fig.position = Vector2(cx - 6, y_base - 32)
		fig.z_index = -15
		add_child(fig)
		# Gentle bob animation
		var bob := create_tween().set_loops()
		bob.tween_property(fig, "position:y",
			y_base - 32 - randf_range(2, 5), randf_range(1.8, 3.2)).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(fig, "position:y",
			y_base - 32, randf_range(1.8, 3.2)).set_ease(Tween.EASE_IN_OUT)

func _make_figure(tribe_idx: int) -> Control:
	# Tiny silhouette: head circle + body rect, tribe accent colour
	var c := Control.new()
	c.custom_minimum_size = Vector2(12, 32)

	var col: Color = STONE_COLORS[tribe_idx]
	col.a = 0.72

	var body := ColorRect.new()
	body.position = Vector2(1, 12)
	body.size = Vector2(10, 20)
	body.color = col
	c.add_child(body)

	var head := ColorRect.new()
	head.position = Vector2(2, 0)
	head.size = Vector2(8, 10)
	head.color = col
	c.add_child(head)
	return c

# =============================================================================
# LAYER 5 — GROUND
# =============================================================================
func _build_ground() -> void:
	var ground := ColorRect.new()
	ground.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	ground.anchor_top = 0.66
	ground.color = C_GROUND
	ground.z_index = -14
	ground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ground)

# =============================================================================
# LAYER 6 — GOLDEN MOTE PARTICLES
# =============================================================================
func _build_particles() -> void:
	var parts := CPUParticles2D.new()
	parts.z_index = -5
	parts.emitting             = true
	parts.amount               = 50
	parts.lifetime             = 10.0
	parts.preprocess           = 5.0
	parts.gravity              = Vector2(3.0, -22.0)
	parts.initial_velocity_min = 8.0
	parts.initial_velocity_max = 30.0
	parts.scale_amount_min     = 1.8
	parts.scale_amount_max     = 5.0
	parts.spread               = 180.0
	parts.emission_shape       = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	parts.emission_rect_extents = Vector2(500, 6)
	parts.color                = Color(1.0, 0.88, 0.22, 0.50)
	var vp := get_viewport_rect().size
	parts.position             = Vector2(vp.x / 2.0, vp.y * 0.72)
	add_child(parts)

# =============================================================================
# LAYER 7 — EPHOD BREASTPLATE
# "You shall set in it four rows of stones." – Exodus 28:17
# =============================================================================
func _build_ephod() -> void:
	var vp := get_viewport_rect().size
	var cx: float = vp.x * 0.5
	var cy: float = vp.y * 0.30   # upper-center

	# Dimensions
	const GEM_W  := 48.0
	const GEM_H  := 44.0
	const GAP_X  := 10.0
	const GAP_Y  := 8.0
	const ROWS   := 4
	const COLS   := 3
	const BORDER := 14.0

	var grid_w: float = COLS * GEM_W + (COLS - 1) * GAP_X
	var grid_h: float = ROWS * GEM_H + (ROWS - 1) * GAP_Y
	var frame_w: float = grid_w + BORDER * 2
	var frame_h: float = grid_h + BORDER * 2 + 24   # extra bottom for UT pocket

	var left: float  = cx - frame_w / 2.0
	var top: float   = cy - frame_h / 2.0

	# ── Shoulder straps (chains) ───────────────────────────────────────────────
	for sx in [-1, 1]:
		var strap := Panel.new()
		strap.position = Vector2(left + frame_w * (0.5 + sx * 0.42) - 4, top - 28)
		strap.size     = Vector2(8, 36)
		strap.z_index  = 0
		strap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var ss := StyleBoxFlat.new()
		ss.bg_color = C_EPHOD_GOLD
		ss.corner_radius_top_left  = 4
		ss.corner_radius_top_right = 4
		strap.add_theme_stylebox_override("panel", ss)
		add_child(strap)

	# ── Outer gold frame ──────────────────────────────────────────────────────
	var frame := Panel.new()
	frame.position = Vector2(left, top)
	frame.size     = Vector2(frame_w, frame_h)
	frame.z_index  = 1
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fs := StyleBoxFlat.new()
	fs.bg_color              = C_EPHOD_GOLD
	fs.corner_radius_top_left     = 10
	fs.corner_radius_top_right    = 10
	fs.corner_radius_bottom_left  = 10
	fs.corner_radius_bottom_right = 10
	frame.add_theme_stylebox_override("panel", fs)
	add_child(frame)

	# Frame glow oscillation
	var ftw := create_tween().set_loops()
	ftw.tween_method(func(v: float) -> void:
		fs.bg_color = C_EPHOD_GOLD.lerp(Color(1.0, 0.92, 0.50, 1), v * 0.35)
	, 0.0, 1.0, 3.5).set_ease(Tween.EASE_IN_OUT)
	ftw.tween_method(func(v: float) -> void:
		fs.bg_color = Color(1.0, 0.92, 0.50, 1).lerp(C_EPHOD_GOLD, v * 0.35)
	, 0.0, 1.0, 3.5).set_ease(Tween.EASE_IN_OUT)

	# ── Inner dark linen backing ───────────────────────────────────────────────
	var backing := Panel.new()
	backing.position = Vector2(left + 5, top + 5)
	backing.size     = Vector2(frame_w - 10, frame_h - 10)
	backing.z_index  = 2
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bs := StyleBoxFlat.new()
	bs.bg_color              = Color(0.12, 0.09, 0.06, 1)
	bs.corner_radius_top_left     = 6
	bs.corner_radius_top_right    = 6
	bs.corner_radius_bottom_left  = 6
	bs.corner_radius_bottom_right = 6
	backing.add_theme_stylebox_override("panel", bs)
	add_child(backing)

	# ── Urim & Thummim pocket (bottom centre, Exodus 28:30) ───────────────────
	var ut := Panel.new()
	ut.position = Vector2(left + frame_w / 2.0 - 18, top + frame_h - BORDER - 6)
	ut.size     = Vector2(36, 14)
	ut.z_index  = 3
	ut.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var uts := StyleBoxFlat.new()
	uts.bg_color              = Color(0.88, 0.88, 0.94, 1)
	uts.corner_radius_top_left     = 4
	uts.corner_radius_top_right    = 4
	uts.corner_radius_bottom_left  = 4
	uts.corner_radius_bottom_right = 4
	ut.add_theme_stylebox_override("panel", uts)
	add_child(ut)

	# ── 12 Gems (4 rows × 3 columns) ─────────────────────────────────────────
	# Row order matches Exodus 28:17-20 (Reuben top-right → Benjamin bottom-left)
	# Each gem is a rounded Panel
	for row in range(ROWS):
		for col in range(COLS):
			var idx: int = row * COLS + col
			var gem := Panel.new()
			gem.position = Vector2(
				left + BORDER + col * (GEM_W + GAP_X),
				top  + BORDER + row * (GEM_H + GAP_Y)
			)
			gem.size    = Vector2(GEM_W, GEM_H)
			gem.z_index = 4
			gem.mouse_filter = Control.MOUSE_FILTER_IGNORE

			var gc := STONE_COLORS[idx]
			var gs := StyleBoxFlat.new()
			gs.bg_color              = gc
			gs.corner_radius_top_left     = 8
			gs.corner_radius_top_right    = 8
			gs.corner_radius_bottom_left  = 8
			gs.corner_radius_bottom_right = 8
			gs.border_width_left   = 2
			gs.border_width_right  = 2
			gs.border_width_top    = 2
			gs.border_width_bottom = 2
			gs.border_color = Color(1, 1, 1, 0.35)
			gem.add_theme_stylebox_override("panel", gs)
			add_child(gem)
			_gem_rects.append(gem as ColorRect)  # stored for pulsing (type mismatch OK)
			# Store the StyleBoxFlat so we can animate it
			gem.set_meta("style", gs)
			gem.set_meta("base_color", gc)

			# Gem inner highlight dot
			var dot := ColorRect.new()
			dot.position = Vector2(GEM_W * 0.22, GEM_H * 0.15)
			dot.size     = Vector2(GEM_W * 0.28, GEM_H * 0.22)
			dot.color    = Color(1, 1, 1, 0.30)
			gem.add_child(dot)

			# Tribe name tooltip label beneath gem
			var tl := Label.new()
			tl.position = Vector2(-4, GEM_H + 2)
			tl.size     = Vector2(GEM_W + 8, 14)
			tl.text     = TRIBE_NAMES[idx]
			tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tl.add_theme_font_size_override("font_size", 9)
			tl.add_theme_color_override("font_color", gc.lightened(0.3))
			tl.modulate.a = 0.75
			gem.add_child(tl)

			# Staggered pulse tween per gem
			var delay := float(idx) * 0.16
			var ptw := create_tween()
			ptw.tween_interval(delay)
			ptw.tween_callback(func() -> void:
				var loop_tw := create_tween().set_loops()
				loop_tw.tween_method(func(v: float) -> void:
					var s: StyleBoxFlat = gem.get_meta("style")
					var base: Color = gem.get_meta("base_color")
					s.bg_color = base.lerp(Color(
						minf(base.r + 0.28, 1.0),
						minf(base.g + 0.22, 1.0),
						minf(base.b + 0.18, 1.0),
						1.0), v)
				, 0.0, 1.0, 0.85 + idx * 0.04).set_ease(Tween.EASE_IN_OUT)
				loop_tw.tween_method(func(v: float) -> void:
					var s: StyleBoxFlat = gem.get_meta("style")
					var base: Color = gem.get_meta("base_color")
					s.bg_color = Color(
						minf(base.r + 0.28, 1.0),
						minf(base.g + 0.22, 1.0),
						minf(base.b + 0.18, 1.0),
						1.0).lerp(base, v)
				, 0.0, 1.0, 0.85 + idx * 0.04).set_ease(Tween.EASE_IN_OUT)
			)

# =============================================================================
# LAYER 8 — TITLE  "TWELVE STONES"
# =============================================================================
func _build_title() -> void:
	var vp := get_viewport_rect().size

	# Shadow / backing bar — semi-transparent dark, spans title width
	var bar := ColorRect.new()
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.anchor_top    = 0.0
	bar.anchor_bottom = 0.0
	bar.offset_top    = 10
	bar.offset_bottom = 56
	bar.color         = Color(0, 0, 0, 0.38)
	bar.z_index       = 8
	bar.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	add_child(bar)

	# Main title label
	var title := Label.new()
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.anchor_top    = 0.0
	title.anchor_bottom = 0.0
	title.offset_top    = 8
	title.offset_bottom = 60
	title.offset_left   = 20
	title.offset_right  = -20
	title.text          = "TWELVE  STONES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", C_TITLE)
	title.add_theme_color_override("font_shadow_color", Color(0.7, 0.5, 0.0, 0.8))
	title.add_theme_constant_override("shadow_offset_x", 3)
	title.add_theme_constant_override("shadow_offset_y", 3)
	title.z_index = 9
	title.modulate.a = 0.0
	add_child(title)

	# Small decorative gem row under title
	var gem_row := HBoxContainer.new()
	gem_row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	gem_row.anchor_top    = 0.0
	gem_row.anchor_bottom = 0.0
	gem_row.offset_top    = 60
	gem_row.offset_bottom = 72
	gem_row.alignment     = BoxContainer.ALIGNMENT_CENTER
	gem_row.z_index       = 9
	gem_row.modulate.a    = 0.0
	for i in range(12):
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(10, 10)
		dot.color = STONE_COLORS[i]
		gem_row.add_child(dot)
		var sep := Control.new()
		sep.custom_minimum_size = Vector2(4, 10)
		gem_row.add_child(sep)
	add_child(gem_row)

	# Fade in title + gem row with slight delay
	await get_tree().create_timer(0.3).timeout
	var tw := create_tween()
	tw.tween_property(title, "modulate:a", 1.0, 1.2).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(gem_row, "modulate:a", 1.0, 1.4).set_ease(Tween.EASE_OUT)

# =============================================================================
# LAYER 9 — SUBTITLE
# =============================================================================
func _build_subtitle() -> void:
	var sub := Label.new()
	sub.set_anchors_preset(Control.PRESET_TOP_WIDE)
	sub.anchor_top    = 0.0
	sub.anchor_bottom = 0.0
	sub.offset_top    = 74
	sub.offset_bottom = 100
	sub.offset_left   = 20
	sub.offset_right  = -20
	sub.text          = "Twelve Tribes  ·  One Ephod  ·  One Story"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 17)
	sub.add_theme_color_override("font_color", Color(0.98, 0.88, 0.64, 1))
	sub.z_index = 9
	sub.modulate.a = 0.0
	add_child(sub)

	await get_tree().create_timer(0.8).timeout
	var tw := create_tween()
	tw.tween_property(sub, "modulate:a", 0.85, 1.4).set_ease(Tween.EASE_OUT)

# =============================================================================
# LAYER 10 — BUTTON STYLING
# Beautiful scroll-parchment look with gold left accent
# =============================================================================
func _style_buttons() -> void:
	# Button accent colours — each gets a unique left gem-accent strip
	var accent_cols: Array[Color] = [
		STONE_COLORS[3],   # Continue  – Judah gold
		STONE_COLORS[0],   # Start     – Reuben carnelian
		STONE_COLORS[4],   # Multiplayer – Dan sapphire
		STONE_COLORS[9],   # VerseVault  – Zebulun chrysolite
		STONE_COLORS[6],   # Support   – Gad jacinth
		STONE_COLORS[11],  # Quit      – Benjamin jasper
	]
	var buttons: Array[Button] = [
		$Buttons/Continue as Button,
		$Buttons/Start    as Button,
		$Buttons/Multiplayer as Button,
		$Buttons/VerseVault  as Button,
		$Buttons/Support  as Button,
		$Buttons/Quit     as Button,
	]

	for i in range(buttons.size()):
		var btn   := buttons[i]
		var acol  := accent_cols[i]

		# Normal style
		var normal := StyleBoxFlat.new()
		normal.bg_color              = C_BTN_BG
		normal.border_color          = C_BTN_BORDER
		normal.border_width_left     = 5
		normal.border_width_right    = 1
		normal.border_width_top      = 1
		normal.border_width_bottom   = 1
		normal.corner_radius_top_left     = 6
		normal.corner_radius_top_right    = 6
		normal.corner_radius_bottom_left  = 6
		normal.corner_radius_bottom_right = 6
		# Left accent coloured stripe
		var accent_style := StyleBoxFlat.new()
		accent_style.bg_color            = acol
		accent_style.corner_radius_top_left     = 4
		accent_style.corner_radius_bottom_left  = 4
		normal.border_color = acol.lerp(C_BTN_BORDER, 0.6)
		normal.border_width_left = 4

		# Hover style (brighter)
		var hover := normal.duplicate() as StyleBoxFlat
		hover.bg_color = C_BTN_BG.lerp(acol, 0.18)
		hover.border_color = acol

		# Pressed style
		var pressed_style := normal.duplicate() as StyleBoxFlat
		pressed_style.bg_color = acol.darkened(0.45)

		btn.add_theme_stylebox_override("normal",  normal)
		btn.add_theme_stylebox_override("hover",   hover)
		btn.add_theme_stylebox_override("pressed", pressed_style)
		btn.add_theme_font_size_override("font_size", 19)
		btn.add_theme_color_override("font_color",         C_BTN_TEXT)
		btn.add_theme_color_override("font_hover_color",   Color(1, 1, 1, 1))
		btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 0.8))

		# Slide + fade-in entrance (staggered)
		btn.modulate.a = 0.0
		btn.position.x += 40
		var btw := create_tween()
		btw.tween_interval(0.4 + float(i) * 0.09)
		btw.tween_property(btn, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)
		btw.parallel().tween_property(btn, "position:x",
			btn.position.x - 40, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# =============================================================================
# LAYER 11 — ROTATING VERSE STRIP
# =============================================================================
func _build_verse_strip() -> void:
	# Dark bar at very bottom
	var strip := ColorRect.new()
	strip.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	strip.anchor_top  = 1.0
	strip.offset_top  = -36
	strip.color       = Color(0, 0, 0, 0.55)
	strip.z_index     = 6
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(strip)

	_verse_label = Label.new()
	_verse_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_verse_label.anchor_top   = 1.0
	_verse_label.offset_top   = -34
	_verse_label.offset_bottom = 0
	_verse_label.offset_left  = 30
	_verse_label.offset_right = -30
	_verse_label.text         = BOTTOM_VERSES[0]
	_verse_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_verse_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	_verse_label.add_theme_font_size_override("font_size", 14)
	_verse_label.add_theme_color_override("font_color", Color(1, 0.95, 0.78, 0.90))
	_verse_label.z_index = 7
	add_child(_verse_label)

func _start_verse_cycle() -> void:
	while true:
		await get_tree().create_timer(6.0).timeout
		var fade_out := create_tween()
		fade_out.tween_property(_verse_label, "modulate:a", 0.0, 0.6)
		await fade_out.finished
		_verse_index = (_verse_index + 1) % BOTTOM_VERSES.size()
		_verse_label.text = BOTTOM_VERSES[_verse_index]
		var fade_in := create_tween()
		fade_in.tween_property(_verse_label, "modulate:a", 1.0, 0.8)

# =============================================================================
# LAYER 12 — FADE RECT
# =============================================================================
func _build_fade_rect() -> void:
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.z_index = 100
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade_rect)

# =============================================================================
# BUTTON HANDLERS
# =============================================================================
func _on_continue() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	await _fade_out()
	var r := get_tree().change_scene_to_file("res://scenes/AvatarPick.tscn")
	if r != OK: push_error("[MainMenu] AvatarPick failed: %d" % r)

func _on_start() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	Global.selected_tribe   = ""
	Global.selected_avatar  = ""
	Global.stones.clear()
	Global.memorized_verses.clear()
	Global.completed_quests.clear()
	await _fade_out()
	var r := get_tree().change_scene_to_file("res://scenes/AvatarPick.tscn")
	if r != OK: push_error("[MainMenu] AvatarPick failed: %d" % r)

func _on_multiplayer() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	await _fade_out()
	var r := get_tree().change_scene_to_file("res://scenes/Lobby.tscn")
	if r != OK: push_error("[MainMenu] Lobby failed: %d" % r)

func _on_verse_vault() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	await _fade_out()
	var r := get_tree().change_scene_to_file("res://scenes/VerseVaultScene.tscn")
	if r != OK: push_error("[MainMenu] VerseVault failed: %d" % r)

func _on_support() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	var dialog := AcceptDialog.new()
	dialog.title = "Support Twelve Stones"
	dialog.dialog_text = "Enjoying the journey?\n\nYour voluntary gift helps us build all 12 tribal worlds.\n\nKo-fi: ko-fi.com/ephodquest\nPayPal: paypal.me/ephodquest\n\nThank you — shalom!"
	add_child(dialog)
	dialog.popup_centered()

func _on_quit() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	await _fade_out()
	get_tree().quit()

# =============================================================================
# HELPERS
# =============================================================================
func _fade_out() -> void:
	var tw := create_tween()
	tw.tween_property(_fade_rect, "color:a", 1.0, 0.55)
	await tw.finished
