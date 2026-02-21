extends Node
# ─────────────────────────────────────────────────────────────────────────────
# VisualEnvironment.gd  –  Twelve Stones / Ephod Quest
# Tribe-specific rich visual layer: real background artwork + animated gradient
# sky, atmospheric particles, radial ambient glow, cinematic vignette, terrain.
#
# Usage (world scenes – from WorldBase / QuestBase):
#   VisualEnvironment.build(self, tribe_key)
#
# Usage (menu / lobby / finale scenes):
#   VisualEnvironment.add_scene_background(self, "main_menu")
#
# "The heavens declare the glory of God;
#  the skies proclaim the work of his hands." – Psalm 19:1
# ─────────────────────────────────────────────────────────────────────────────

# ── Per-tribe background artwork (img_01–img_12 = Reuben–Benjamin) ───────────
# "He set the earth on its foundations" – Psalm 104:5
# Mapped sequentially to the Exodus 28 ephod order.
# Falls back gracefully to gradient-only if file is missing.
const TRIBE_BG: Dictionary = {
	"reuben":   "res://assets/sprites/raw/img_01.jpg",   # Morning Cliffs
	"simeon":   "res://assets/sprites/raw/img_02.jpg",   # Desert Plains
	"levi":     "res://assets/sprites/raw/img_03.jpg",   # Night Sanctuary
	"judah":    "res://assets/sprites/raw/img_04.jpg",   # Sunlit Hills
	"dan":      "res://assets/sprites/raw/img_05.jpg",   # Foggy Coast
	"naphtali": "res://assets/sprites/raw/img_06.jpg",   # Night Forest
	"gad":      "res://assets/sprites/raw/img_07.jpg",   # Mountain Pass
	"asher":    "res://assets/sprites/raw/img_08.jpg",   # Coastal Shore
	"issachar": "res://assets/sprites/raw/img_09.jpg",   # Starfield Plain
	"zebulun":  "res://assets/sprites/raw/img_10.jpg",   # Harbour Dawn
	"joseph":   "res://assets/sprites/raw/img_11.jpg",   # Fertile Valley
	"benjamin": "res://assets/sprites/raw/img_12.jpg",   # Bronze Hills
}

# ── Named scene backgrounds (img_13 onward) ───────────────────────────────────
const SCENE_BG: Dictionary = {
	"main_menu":   "res://assets/sprites/raw/img_13.jpg",
	"avatar_pick": "res://assets/sprites/raw/img_14.jpg",
	"lobby":       "res://assets/sprites/raw/img_15.jpg",
	"verse_vault": "res://assets/sprites/raw/img_16.jpg",
	"finale":      "res://assets/sprites/raw/img_17.jpg",
}

# ── Per-tribe biome palette ───────────────────────────────────────────────────
# sky_top / sky_bot  : hex strings for gradient shader (no #)
# glow               : hex string for radial accent glow colour
# particle           : RGBA particle colour
# terrain_col        : ground silhouette colour
const BIOMES: Dictionary = {
	"reuben":   {"sky_top":"163a5e","sky_bot":"add6f0","glow":"C0392B",
				 "particle":Color(0.70,0.88,1.00,0.50),"terrain_col":Color(0.55,0.44,0.30,1)},
	"simeon":   {"sky_top":"5c3a0a","sky_bot":"e8c87a","glow":"9B59B6",
				 "particle":Color(0.96,0.84,0.50,0.50),"terrain_col":Color(0.72,0.61,0.38,1)},
	"levi":     {"sky_top":"100820","sky_bot":"3a1860","glow":"DAA520",
				 "particle":Color(1.00,0.90,0.28,0.60),"terrain_col":Color(0.25,0.18,0.38,1)},
	"judah":    {"sky_top":"5e1b00","sky_bot":"f4a460","glow":"FFD700",
				 "particle":Color(1.00,0.85,0.20,0.55),"terrain_col":Color(0.60,0.44,0.18,1)},
	"dan":      {"sky_top":"161e28","sky_bot":"7a8e9e","glow":"2980B9",
				 "particle":Color(0.72,0.80,0.92,0.45),"terrain_col":Color(0.38,0.40,0.44,1)},
	"naphtali": {"sky_top":"280840","sky_bot":"c098d8","glow":"9B59B6",
				 "particle":Color(0.90,0.72,1.00,0.55),"terrain_col":Color(0.30,0.22,0.40,1)},
	"gad":      {"sky_top":"0c1c0c","sky_bot":"5a9a5a","glow":"27AE60",
				 "particle":Color(0.52,0.88,0.52,0.45),"terrain_col":Color(0.22,0.38,0.22,1)},
	"asher":    {"sky_top":"042030","sky_bot":"64a8c8","glow":"00B4D8",
				 "particle":Color(0.60,0.88,1.00,0.55),"terrain_col":Color(0.18,0.40,0.50,1)},
	"issachar": {"sky_top":"02040e","sky_bot":"0e186a","glow":"5C6BC0",
				 "particle":Color(0.88,0.88,1.00,0.65),"terrain_col":Color(0.08,0.10,0.22,1)},
	"zebulun":  {"sky_top":"00203a","sky_bot":"d89040","glow":"F39C12",
				 "particle":Color(1.00,0.92,0.55,0.55),"terrain_col":Color(0.20,0.30,0.38,1)},
	"joseph":   {"sky_top":"0a220a","sky_bot":"80c880","glow":"2ECC71",
				 "particle":Color(0.55,0.92,0.55,0.50),"terrain_col":Color(0.20,0.38,0.20,1)},
	"benjamin": {"sky_top":"180800","sky_bot":"7a4a28","glow":"E67E22",
				 "particle":Color(1.00,0.72,0.25,0.60),"terrain_col":Color(0.34,0.22,0.12,1)},
}

# ── GLSL shaders ──────────────────────────────────────────────────────────────
const _SKY_GLSL: String = "
shader_type canvas_item;
uniform vec4 sky_top : source_color = vec4(0.09,0.23,0.37,1.0);
uniform vec4 sky_bot : source_color = vec4(0.68,0.84,0.94,1.0);
void fragment() {
	float t = pow(UV.y, 0.62);
	vec4 c  = mix(sky_top, sky_bot, t);
	// Alpha 0.62 → the background artwork layer (z=-10) bleeds through,
	// giving a painted-sky feel rather than a flat opaque gradient.
	COLOR   = vec4(c.rgb, 0.62);
}"

const _RADIAL_GLSL: String = "
shader_type canvas_item;
uniform vec4 glow_color : source_color = vec4(1.0,0.7,0.1,0.18);
void fragment() {
	vec2 uv = UV - vec2(0.5);
	float d  = length(uv) * 2.0;
	float a  = pow(clamp(1.0 - d * d, 0.0, 1.0), 2.4);
	COLOR    = vec4(glow_color.rgb, glow_color.a * a);
}"

const _VIGNETTE_GLSL: String = "
shader_type canvas_item;
void fragment() {
	vec2 uv  = UV * 2.0 - 1.0;
	float v  = dot(uv * 0.70, uv * 0.70);
	float a  = clamp(v * v, 0.0, 0.68);
	COLOR    = vec4(0.0, 0.0, 0.0, a);
}"

const _HORIZON_GLSL: String = "
shader_type canvas_item;
uniform vec4 ground_col : source_color = vec4(0.45,0.38,0.26,1.0);
void fragment() {
	float t = pow(UV.y, 3.0);
	float a = clamp(t * 1.8, 0.0, 1.0);
	COLOR   = vec4(ground_col.rgb, a);
}"

# ─────────────────────────────────────────────────────────────────────────────
# PUBLIC – call this once from QuestBase._ready() before _build_ui()
# Returns the biome display label (e.g. "Savannah Ridge") for optional use.
# ─────────────────────────────────────────────────────────────────────────────
static func build(parent: Node, tribe_key: String) -> void:
	var biome: Dictionary = BIOMES.get(tribe_key, BIOMES["reuben"]) as Dictionary
	# Layer order (lowest z first):
	#   -10  background texture artwork
	#    -9  gradient sky (α=0.62 so texture bleeds through)
	#    -8  horizon terrain gradient + haze
	#    -6  radial tribal glow
	#    -4  atmospheric particles
	#     9  cinematic vignette
	var tex_path: String = TRIBE_BG.get(tribe_key, "") as String
	if tex_path != "":
		_add_background_texture(parent, tex_path)
	_add_sky(parent, biome)
	_add_terrain(parent, biome)
	_add_glow(parent, biome)
	_add_particles(parent, biome)
	add_vignette(parent)

# ─────────────────────────────────────────────────────────────────────────────
# PUBLIC – wire a background image into Control-based menu/lobby scenes.
# Call from _ready() before other UI is added.
# "Beautiful in its time – He has made everything beautiful" – Ecclesiastes 3:11
# ─────────────────────────────────────────────────────────────────────────────
static func add_scene_background(parent: Node, scene_key: String) -> void:
	var tex_path: String = SCENE_BG.get(scene_key, "") as String
	if tex_path == "" or not ResourceLoader.exists(tex_path):
		return
	var tex: Texture2D = load(tex_path) as Texture2D
	if tex == null:
		return
	var tr := TextureRect.new()
	tr.name              = "_SceneBG_" + scene_key
	tr.texture           = tex
	tr.expand_mode       = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode      = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	tr.z_index           = -10
	tr.mouse_filter      = Control.MOUSE_FILTER_IGNORE
	# Slight warm modulation keeps the artwork cohesive with the gold palette
	tr.modulate          = Color(1.0, 0.96, 0.90, 1.0)
	parent.add_child(tr)
	parent.move_child(tr, 0)   # push behind all existing children

# ─────────────────────────────────────────────────────────────────────────────
# PRIVATE LAYER BUILDERS
# ─────────────────────────────────────────────────────────────────────────────
static func _add_background_texture(parent: Node, tex_path: String) -> void:
	# Real artwork layer – placed at z=-10 beneath all shaders.
	# The sky gradient sits above at α=0.62 so the image remains visible,
	# creating a hand-painted-sky feel.
	# "How many are your works, LORD! … the earth is full of your creatures." – Psalm 104:24
	if not ResourceLoader.exists(tex_path):
		return
	var tex: Texture2D = load(tex_path) as Texture2D
	if tex == null:
		return
	var tr := TextureRect.new()
	tr.name         = "_VisEnv_BG"
	tr.texture      = tex
	tr.expand_mode  = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	tr.z_index      = -10
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Warm modulation – ties the image to the Desert Sand / Gold palette
	tr.modulate     = Color(1.0, 0.96, 0.90, 1.0)
	parent.add_child(tr)

static func _add_sky(parent: Node, biome: Dictionary) -> void:
	# Animated gradient sky — replaces the flat BG colour
	var rect := ColorRect.new()
	rect.name      = "_VisEnv_Sky"
	rect.z_index   = -9
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)

	var mat := ShaderMaterial.new()
	var shd := Shader.new()
	shd.code   = _SKY_GLSL
	mat.shader = shd

	var top_hex: String = biome.get("sky_top", "163a5e") as String
	var bot_hex: String = biome.get("sky_bot", "add6f0") as String
	var top_col := Color("#" + top_hex)
	var bot_col := Color("#" + bot_hex)
	mat.set_shader_parameter("sky_top", top_col)
	mat.set_shader_parameter("sky_bot", bot_col)
	rect.material = mat
	parent.add_child(rect)

	# Slowly breathe brightness — time of day feeling
	var tw := parent.create_tween()
	tw.set_loops()
	tw.tween_method(func(v: float):
		mat.set_shader_parameter("sky_top", top_col.lightened(v * 0.10))
		mat.set_shader_parameter("sky_bot", bot_col.lightened(v * 0.05))
	, 0.0, 1.0, 14.0).set_ease(Tween.EASE_IN_OUT)
	tw.tween_method(func(v: float):
		mat.set_shader_parameter("sky_top", top_col.lightened((1.0 - v) * 0.10))
		mat.set_shader_parameter("sky_bot", bot_col.lightened((1.0 - v) * 0.05))
	, 0.0, 1.0, 14.0).set_ease(Tween.EASE_IN_OUT)

static func _add_terrain(parent: Node, biome: Dictionary) -> void:
	# Horizon ground gradient — suggests depth without any art assets
	var rect := ColorRect.new()
	rect.name    = "_VisEnv_Terrain"
	rect.z_index = -8
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)

	var mat := ShaderMaterial.new()
	var shd := Shader.new()
	shd.code   = _HORIZON_GLSL
	mat.shader = shd
	var tcol: Color = biome.get("terrain_col", Color(0.45, 0.38, 0.26, 1)) as Color
	mat.set_shader_parameter("ground_col", tcol)
	rect.material = mat
	parent.add_child(rect)

	# Far distance haze: a slightly lighter band in the middle
	var haze := ColorRect.new()
	haze.name   = "_VisEnv_Haze"
	haze.z_index = -8
	haze.mouse_filter = Control.MOUSE_FILTER_IGNORE
	haze.set_anchors_preset(Control.PRESET_HCENTER_WIDE)
	haze.offset_top    = -24.0
	haze.offset_bottom =  24.0
	haze.color = Color(tcol.lightened(0.28).r, tcol.lightened(0.28).g,
					   tcol.lightened(0.28).b, 0.35)
	parent.add_child(haze)

static func _add_glow(parent: Node, biome: Dictionary) -> void:
	# Radial ambient glow in tribe accent colour — placed upper-centre
	var rect := ColorRect.new()
	rect.name   = "_VisEnv_Glow"
	rect.z_index = -6
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_CENTER)
	rect.offset_left   = -340.0
	rect.offset_right  =  340.0
	rect.offset_top    = -280.0
	rect.offset_bottom =  280.0

	var mat := ShaderMaterial.new()
	var shd := Shader.new()
	shd.code   = _RADIAL_GLSL
	mat.shader = shd

	var hex: String = biome.get("glow", "FFD700") as String
	var base := Color("#" + hex)
	mat.set_shader_parameter("glow_color", Color(base.r, base.g, base.b, 0.16))
	rect.material = mat
	parent.add_child(rect)

	# Pulse the glow slowly
	var tw := parent.create_tween()
	tw.set_loops()
	tw.tween_method(func(v: float):
		mat.set_shader_parameter("glow_color", Color(base.r, base.g, base.b, 0.10 + v * 0.16))
	, 0.0, 1.0, 5.0).set_ease(Tween.EASE_IN_OUT)
	tw.tween_method(func(v: float):
		mat.set_shader_parameter("glow_color", Color(base.r, base.g, base.b, 0.26 - v * 0.16))
	, 0.0, 1.0, 5.0).set_ease(Tween.EASE_IN_OUT)

static func _add_particles(parent: Node, biome: Dictionary) -> void:
	# Atmospheric floating particles — dust motes, petals, sparks, stars
	var p := CPUParticles2D.new()
	p.name    = "_VisEnv_Particles"
	p.z_index = -4
	p.emitting              = true
	p.amount                = 32
	p.lifetime              = 10.0
	p.preprocess            = 3.0        # start mid-stream so no empty first seconds
	p.spread                = 160.0
	p.gravity               = Vector2(3.0, -12.0)
	p.initial_velocity_min  = 8.0
	p.initial_velocity_max  = 30.0
	p.angular_velocity_min  = -20.0
	p.angular_velocity_max  =  20.0
	p.scale_amount_min      = 2.5
	p.scale_amount_max      = 7.0
	p.emission_shape        = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(400, 20)
	p.position              = Vector2(320, 590)

	var pcol: Color = biome.get("particle", Color(1, 1, 1, 0.5)) as Color
	p.color = pcol
	parent.add_child(p)

static func add_vignette(parent: Node) -> void:
	# Darkened screen edges — cinematic framing, suggests depth
	var rect := ColorRect.new()
	rect.name   = "_VisEnv_Vignette"
	rect.z_index = 9          # above scene elements, below CanvasLayer (layer 10)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)

	var mat := ShaderMaterial.new()
	var shd := Shader.new()
	shd.code   = _VIGNETTE_GLSL
	mat.shader = shd
	rect.material = mat
	parent.add_child(rect)

# ─────────────────────────────────────────────────────────────────────────────
# HELPER – build a per-dialogue elder portrait panel (call from _build_ui)
# Returns a Control you can add to the left side of the dialogue HBox.
# ─────────────────────────────────────────────────────────────────────────────
static func make_portrait(tribe_color_hex: String) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(72, 72)
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var style := StyleBoxFlat.new()
	var base := Color("#" + tribe_color_hex)
	style.bg_color                 = base.darkened(0.25)
	style.corner_radius_top_left   = 36
	style.corner_radius_top_right  = 36
	style.corner_radius_bottom_left  = 36
	style.corner_radius_bottom_right = 36
	style.border_width_left   = 3
	style.border_width_top    = 3
	style.border_width_right  = 3
	style.border_width_bottom = 3
	style.border_color = base.lightened(0.3)
	panel.add_theme_stylebox_override("panel", style)

	var lbl := Label.new()
	lbl.text = "👤"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 32)
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(lbl)

	# Start border pulse once this panel enters the scene tree
	panel.tree_entered.connect(func():
		var tw := panel.create_tween()
		tw.set_loops()
		tw.tween_method(func(v: float):
			style.border_color = base.lightened(0.2 + v * 0.4)
		, 0.0, 1.0, 2.0).set_ease(Tween.EASE_IN_OUT)
		tw.tween_method(func(v: float):
			style.border_color = base.lightened(0.6 - v * 0.4)
		, 0.0, 1.0, 2.0).set_ease(Tween.EASE_IN_OUT)
	, Object.CONNECT_ONE_SHOT)

	return panel

# ─────────────────────────────────────────────────────────────────────────────
# Returns a richly styled tribal initial badge — the first letter of the tribe
# name large, gem-colored, animated border pulse. Size controls the badge px.
# "Each stone engraved like a seal with one of the twelve tribes" – Exodus 28:21
# ─────────────────────────────────────────────────────────────────────────────
static func make_tribe_initial(tribe_key: String, size: float = 72.0) -> Control:
	# Gem emojis in Exodus 28 ephod row order
	const GEM_EMOJI := {
		"reuben": "🔴", "simeon": "🟡", "levi": "💚", "judah": "🟡",
		"dan": "💙", "naphtali": "💎", "gad": "⬜", "asher": "🟫",
		"issachar": "💜", "zebulun": "🩵", "joseph": "⚫", "benjamin": "🟠",
	}
	# Tribe hex colours (matches Global.TRIBES)
	const TRIBE_HEX := {
		"reuben": "C0392B", "simeon": "8E44AD", "levi": "D4AC0D",
		"judah": "F39C12", "dan": "1ABC9C", "naphtali": "27AE60",
		"gad": "566573", "asher": "F7DC6F", "issachar": "A569BD",
		"zebulun": "2E86C1", "joseph": "E74C3C", "benjamin": "E67E22",
	}
	var hex : String = TRIBE_HEX.get(tribe_key, "8B6F47") as String
	var base := Color("#" + hex)
	var initial : String = tribe_key.substr(0, 1).to_upper() if tribe_key != "" else "?"
	var gem : String = GEM_EMOJI.get(tribe_key, "💎") as String

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(size, size)
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var style := StyleBoxFlat.new()
	style.bg_color                   = base.darkened(0.30)
	style.corner_radius_top_left     = int(size * 0.5)
	style.corner_radius_top_right    = int(size * 0.5)
	style.corner_radius_bottom_left  = int(size * 0.5)
	style.corner_radius_bottom_right = int(size * 0.5)
	style.border_width_left   = 3
	style.border_width_top    = 3
	style.border_width_right  = 3
	style.border_width_bottom = 3
	style.border_color = base.lightened(0.4)
	style.shadow_size  = 8
	style.shadow_color = Color(base.r, base.g, base.b, 0.45)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", -4)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	# Large tribe initial letter
	var lbl := Label.new()
	lbl.text = initial
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", int(size * 0.52))
	lbl.add_theme_color_override("font_color", Color.WHITE)
	# Subtle drop shadow on the letter
	lbl.add_theme_color_override("font_shadow_color", base.darkened(0.6))
	lbl.add_theme_constant_override("shadow_offset_x", 2)
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	vbox.add_child(lbl)

	# Gem emoji sub-label
	var gem_lbl := Label.new()
	gem_lbl.text = gem
	gem_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gem_lbl.add_theme_font_size_override("font_size", int(size * 0.22))
	vbox.add_child(gem_lbl)

	# Animated pulsing border — only starts once added to the scene tree
	panel.tree_entered.connect(func():
		var tw := panel.create_tween()
		tw.set_loops()
		tw.tween_method(func(v: float):
			style.border_color = base.lightened(0.2 + v * 0.5)
			style.shadow_color  = Color(base.r, base.g, base.b, 0.2 + v * 0.35)
		, 0.0, 1.0, 1.6).set_ease(Tween.EASE_IN_OUT)
		tw.tween_method(func(v: float):
			style.border_color = base.lightened(0.7 - v * 0.5)
			style.shadow_color  = Color(base.r, base.g, base.b, 0.55 - v * 0.35)
		, 0.0, 1.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	, Object.CONNECT_ONE_SHOT)

	return panel
