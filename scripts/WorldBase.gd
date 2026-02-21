extends Node3D
class_name WorldBase
# ─────────────────────────────────────────────────────────────────────────────
# WorldBase.gd  –  Twelve Stones / Ephod Quest
# Zelda-like top-down adventure world base class.
# Every tribe world (World1–World12) extends this.
#
# Architecture:
#   Node3D (WorldBase)
#   ├── WorldTerrain        (MeshInstance grounds)
#   ├── Walls               (StaticBody3D collision)
#   ├── PlayerBody          (CharacterBody3D – see PlayerBody.gd)
#   ├── Camera3D            (follows PlayerBody)
#   ├── NPCs/               (Node3D group – NPC.gd instances)
#   ├── Chests/             (Node3D group – TreasureChest.gd instances)
#   ├── SideQuestObjects/   (puzzle objects, collectibles)
#   └── UILayer             (CanvasLayer 10 – HUD, dialogue, minimap)
#
# "Seek and you will find; knock and the door will be opened" – Matthew 7:7
# ─────────────────────────────────────────────────────────────────────────────

const VisualEnvironment := preload("res://scripts/VisualEnvironment.gd")
# AssetRegistry is available globally as an autoload singleton – no preload needed

# ── Subclass fills these ──────────────────────────────────────────────────────
@export var tribe_key:    String = ""
@export var quest_id:     String = ""
@export var next_scene:   String = ""
@export var music_path:   String = "res://assets/audio/music/sacred_spark.wav"
@export var world_name:   String = "Unknown Land"
@export var world_bounds: Rect2  = Rect2(-1000, -800, 2000, 1600)

# ── Internal state ────────────────────────────────────────────────────────────
var _tribe_data:       Dictionary = {}
var _stone_collected:  bool = false
var _dialogue_queue:   Array = []
var _interaction_target: Node = null   # NPC or Chest the player is near
var _side_quest_log:   Array[String] = []  # IDs of active side quests

# ── UI nodes ──────────────────────────────────────────────────────────────────
var _ui_canvas:        CanvasLayer
var _fade_rect:        ColorRect
var _dialogue_panel:   PanelContainer
var _dialogue_portrait: Control
var _dlg_portrait_img: TextureRect   # SVG elder / avatar portrait
var _dialogue_name:    Label
var _dialogue_text:    Label
var _dialogue_btn:     Button
var _interaction_hint: Label         # "Press ✦ to speak" floating prompt
var _hud_tribe_label:  Label
var _hud_quest_label:  Label
var _minimap_canvas:   CanvasLayer
var _verse_panel:      PanelContainer
var _verse_ref:        Label
var _verse_text:       Label
var _verse_input:      LineEdit
var _verse_btn:        Button
var _nature_panel:     PanelContainer
var _nature_text:      Label
var _nature_verse:     Label
var _nature_btn:       Button
var _stone_label:      Label
var _sq_panel:         PanelContainer   # side-quest tracker panel
var _sq_label:         Label

# ── Player reference ──────────────────────────────────────────────────────────
var _player: CharacterBody3D
var _hint_tween: Tween          # stored so we can kill it on exit
var _stone_hud_label: Label     # reference for live update

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_tribe_data = Global.get_tribe_data(tribe_key)
	_setup_camera()
	_build_hud()
	_connect_player()
	_add_touch_controls()
	_init_mini_game_container()        # ensure container ready before on_world_ready()
	# Auto-select tribe music if not explicitly overridden by subclass
	# "Each tribe praised God in its own voice" (narrative – Twelve Stones)
	if music_path == "res://assets/audio/music/sacred_spark.wav" and tribe_key != "":
		music_path = AssetRegistry.music(tribe_key)
	AudioManager.play_music(music_path)
	if tribe_key != "":
		AudioManager.play_tribe_ambient(tribe_key)
	_fade_in()
	await get_tree().create_timer(0.7).timeout
	on_world_ready()   # subclass entry point

func _add_touch_controls() -> void:
	# Virtual joystick — loaded at runtime for safety (preload would fail on PC desktop without file)
	var tc_path := "res://scenes/TouchControls.tscn"
	if ResourceLoader.exists(tc_path):
		var packed = load(tc_path) as PackedScene
		if packed:
			var touch_controls = packed.instantiate()
			_ui_canvas.add_child(touch_controls)

func _process(delta: float) -> void:
	if _player:
		var cam = get_node_or_null("Camera3D")
		if cam:
			var target_pos = _player.position + Vector3(0, 5, 5)
			cam.position = cam.position.lerp(target_pos, delta * 5.0)
			cam.look_at(_player.position, Vector3.UP)

func on_world_ready() -> void:
	_add_lighting()
	_add_sky()
	_add_backdrop()           # tribe artwork as far-plane panorama
	_add_atmospheric_props()  # scattered trees, rocks, bushes

# Default world intro — subclasses override this to show tribe-specific opening dialogue
# "The LORD makes his face shine on you" – Numbers 6:25
func _show_world_intro() -> void:
	var elder: String = _tribe_data.get("elder", "Elder") as String
	var tname: String = world_name if world_name != "Unknown Land" else tribe_key.capitalize() + " Land"
	show_dialogue([
		{"name": tname,
		 "text": "Welcome to " + tname + ". Speak with " + elder + " to begin your quest."}
	])
	update_quest_log("Find " + elder + "\nto begin your quest")

# ─────────────────────────────────────────────────────────────────────────────
# LIGHTING AND ENVIRONMENT
# ─────────────────────────────────────────────────────────────────────────────
func _add_lighting() -> void:
	# ── Key light: warm sun from upper-front-right ────────────────────────────
	# "The sun rises, and they slip away; they return and lie down in their dens." – Psalm 104:22
	var biome: Dictionary = VisualEnvironment.BIOMES.get(tribe_key, VisualEnvironment.BIOMES["reuben"]) as Dictionary
	var glow_hex: String  = biome.get("glow", "FFD700") as String
	var tribe_color       := Color("#" + glow_hex)

	var sun := DirectionalLight3D.new()
	sun.name = "SunLight"
	sun.rotation_degrees     = Vector3(-55.0, 30.0, 0.0)
	sun.light_color          = Color(1.0, 0.96, 0.88, 1.0)   # warm daylight
	sun.light_energy         = 1.8
	sun.shadow_enabled       = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_max_distance = 150.0
	add_child(sun)

	# ── Fill light: sky-tinted, from upper-rear-left (mimics open sky bounce) ─
	var fill := DirectionalLight3D.new()
	fill.name = "FillLight"
	fill.rotation_degrees = Vector3(-30.0, -160.0, 0.0)
	fill.light_color      = Color(
		tribe_color.r * 0.5 + 0.5,
		tribe_color.g * 0.5 + 0.5,
		tribe_color.b * 0.5 + 0.5, 1.0
	).lightened(0.3)
	fill.light_energy  = 0.45
	fill.shadow_enabled = false
	add_child(fill)

	# ── Accent OmniLight: tribe-colored warm glow near player spawn ───────────
	var accent := OmniLight3D.new()
	accent.name = "AccentLight"
	accent.position = Vector3(0.0, 3.0, 4.0)   # near default spawn area
	accent.light_color  = tribe_color.lightened(0.2)
	accent.light_energy = 1.2
	accent.omni_range   = 18.0
	accent.shadow_enabled = false
	add_child(accent)

	# Softly pulse the accent — time-of-day warmth effect
	# "His light shines in the darkness" – John 1:5
	var tw := create_tween()
	tw.set_loops()
	tw.tween_property(accent, "light_energy", 0.7, 4.0).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(accent, "light_energy", 1.2, 4.0).set_ease(Tween.EASE_IN_OUT)

func _add_sky() -> void:
	# Tribe-specific procedural sky using biome palette – "The heavens declare the glory of God" – Psalm 19:1
	var biome: Dictionary = VisualEnvironment.BIOMES.get(tribe_key, VisualEnvironment.BIOMES["reuben"]) as Dictionary
	var sky_top  := Color("#" + str(biome.get("sky_top",  "163a5e")))
	var sky_bot  := Color("#" + str(biome.get("sky_bot",  "add6f0")))
	var glow_col := Color("#" + str(biome.get("glow",     "aaaaff"))).lightened(0.3)

	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color         = sky_top
	sky_mat.sky_horizon_color     = sky_bot
	sky_mat.sky_curve             = 0.15
	sky_mat.ground_bottom_color   = sky_bot.darkened(0.5)
	sky_mat.ground_horizon_color  = sky_bot.darkened(0.2)
	sky_mat.sun_angle_max         = 30.0
	sky_mat.sun_curve             = 0.12

	var sky_node := Sky.new()
	sky_node.sky_material = sky_mat

	var env := Environment.new()
	env.sky                              = sky_node
	env.background_mode                  = Environment.BG_SKY
	env.ambient_light_source             = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_sky_contribution   = 0.8
	env.ambient_light_color              = glow_col
	env.ambient_light_energy             = 0.5
	env.tonemap_mode                     = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure                 = 1.1
	env.fog_enabled                      = true
	env.fog_density                      = 0.004
	env.fog_sky_affect                   = 0.3

	# ── Glow / Bloom — makes gold surfaces and lights radiate warmth ──────────
	# "His face was like the sun shining in all its brilliance." – Revelation 1:16
	env.glow_enabled         = true
	env.glow_intensity       = 0.6
	env.glow_strength        = 1.2
	env.glow_bloom           = 0.08
	env.glow_blend_mode      = Environment.GLOW_BLEND_MODE_ADDITIVE
	env.glow_normalized      = false

	# ── Ambient Occlusion (SSAO) — adds depth in corners and under foliage ────
	env.ssao_enabled         = true
	env.ssao_radius          = 1.0
	env.ssao_intensity       = 1.2
	env.ssao_power           = 1.5
	env.ssao_detail          = 0.5
	env.ssao_horizon         = 0.06
	env.ssao_sharpness       = 0.98

	# ── SSIL (Screen Space Indirect Lighting) — warm bounced light ────────────
	env.ssil_enabled         = true
	env.ssil_radius          = 5.0
	env.ssil_intensity       = 0.5
	env.ssil_sharpness       = 0.98

	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)

# ─────────────────────────────────────────────────────────────────────────────
# BACKDROP BILLBOARD
# Places the tribe's painted artwork (img_01–12) as a large flat quad far
# behind the scene. Creates the "painted panorama" depth feel of games like
# Ori and the Blind Forest / Hollow Knight.
# "The heavens declare the glory of God" – Psalm 19:1
# ─────────────────────────────────────────────────────────────────────────────
func _add_backdrop() -> void:
	var tex_path: String = VisualEnvironment.TRIBE_BG.get(tribe_key, "") as String
	if tex_path == "" or not ResourceLoader.exists(tex_path):
		return
	var tex: Texture2D = load(tex_path) as Texture2D
	if tex == null:
		return

	# Large vertical plane far behind the play area — acts as horizon painting
	var mesh   := QuadMesh.new()
	mesh.size  = Vector2(400.0, 120.0)   # wide panorama, tall enough to fill sky

	var mat    := StandardMaterial3D.new()
	mat.albedo_texture          = tex
	mat.shading_mode            = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode               = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test           = false
	mat.billboard_mode          = BaseMaterial3D.BILLBOARD_DISABLED
	# Slight warm modulation stays consistent with the Desert Sand / Gold palette
	mat.albedo_color            = Color(1.0, 0.96, 0.90, 1.0)

	var mi := MeshInstance3D.new()
	mi.name     = "_Backdrop"
	mi.mesh     = mesh
	mi.material_override = mat
	# Centered horizontally, raised to sit at horizon height, pushed far back
	mi.position = Vector3(0.0, 25.0, -180.0)
	# Never receives or casts shadows — purely a visual backdrop
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.gi_mode     = GeometryInstance3D.GI_MODE_DISABLED
	add_child(mi)

# ─────────────────────────────────────────────────────────────────────────────
# ATMOSPHERIC PROPS
# Scatters trees, boulders, and bushes around the world boundaries to create
# ambient depth and a sense of a living, breathing landscape.
# "Trees of the LORD are well watered, the cedars of Lebanon." – Psalm 104:16
# ─────────────────────────────────────────────────────────────────────────────
func _add_atmospheric_props() -> void:
	if tribe_key == "":
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(tribe_key)   # deterministic per tribe so layout is stable

	var terrain_col: Color = (VisualEnvironment.BIOMES.get(tribe_key,
			VisualEnvironment.BIOMES["reuben"]) as Dictionary).get(
			"terrain_col", Color(0.3, 0.5, 0.2, 1)) as Color

	# ── Trees (capsule trunk + sphere canopy) – 12 scattered around outer ring ─
	var tree_tex  := AssetRegistry.prop("tree_leaf")
	var bark_tex  := AssetRegistry.prop("tree_bark")
	for i in 12:
		var angle := rng.randf() * TAU
		var dist  := rng.randf_range(18.0, 35.0)
		var pos   := Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)
		var height := rng.randf_range(3.5, 6.0)
		var trunk_r := rng.randf_range(0.25, 0.45)
		_spawn_tree(pos, height, trunk_r, bark_tex, tree_tex, terrain_col, rng)

	# ── Boulders – 8 rocks at varying distances ───────────────────────────────
	var rock_tex := AssetRegistry.prop("rock_prop")
	for j in 8:
		var angle := rng.randf() * TAU
		var dist  := rng.randf_range(8.0, 28.0)
		var pos   := Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)
		var scale_v := Vector3(
			rng.randf_range(0.5, 1.4),
			rng.randf_range(0.4, 1.0),
			rng.randf_range(0.6, 1.3)
		)
		_spawn_rock(pos, scale_v, rock_tex)

	# ── Bushes – 16 small clusters ────────────────────────────────────────────
	var bush_tex := AssetRegistry.prop("bush")
	for k in 16:
		var angle := rng.randf() * TAU
		var dist  := rng.randf_range(4.0, 24.0)
		var pos   := Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)
		_spawn_bush(pos, rng.randf_range(0.5, 1.1), bush_tex, terrain_col)

func _spawn_tree(pos: Vector3, height: float, trunk_r: float,
		bark_tex: String, leaf_tex: String, leaf_col: Color,
		rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.position = pos
	add_child(root)

	# Trunk
	var trunk_mi := MeshInstance3D.new()
	var trunk_m  := CapsuleMesh.new()
	trunk_m.radius = trunk_r;  trunk_m.height = height * 0.6
	trunk_mi.mesh  = trunk_m
	trunk_mi.position = Vector3(0, height * 0.3, 0)
	var bark_mat := _tex_mat(bark_tex, Color(0.55, 0.38, 0.18, 1))
	trunk_mi.material_override = bark_mat
	trunk_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	root.add_child(trunk_mi)

	# Canopy — two overlapping spheres for organic silhouette
	var r1      := trunk_r * rng.randf_range(2.5, 4.0)
	var canopy1 := MeshInstance3D.new()
	var sph1    := SphereMesh.new()
	sph1.radius = r1;  sph1.height = r1 * 1.8
	canopy1.mesh     = sph1
	canopy1.position = Vector3(0, height * 0.72, 0)
	var leaf_mat := _tex_mat(leaf_tex, leaf_col.darkened(0.1))
	canopy1.material_override = leaf_mat
	canopy1.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	root.add_child(canopy1)

	var canopy2 := MeshInstance3D.new()
	var sph2    := SphereMesh.new()
	sph2.radius = r1 * 0.7;  sph2.height = r1 * 1.2
	canopy2.mesh     = sph2
	canopy2.position = Vector3(r1 * 0.45, height * 0.85, r1 * 0.15)
	canopy2.material_override = leaf_mat
	canopy2.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	root.add_child(canopy2)

	# Gentle perpetual sway — "the branches shall shake like cedars" – Psalm 72:16
	var tw := root.create_tween()
	tw.set_loops()
	var sway := rng.randf_range(0.8, 2.2)
	tw.tween_property(root, "rotation_degrees:z",  sway, rng.randf_range(2.5, 4.5)).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(root, "rotation_degrees:z", -sway, rng.randf_range(2.5, 4.5)).set_ease(Tween.EASE_IN_OUT)

func _spawn_rock(pos: Vector3, scale_v: Vector3, rock_tex: String) -> void:
	var mi  := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.4 * scale_v.x, 1.0 * scale_v.y, 1.2 * scale_v.z)
	mi.mesh     = box
	mi.position = pos + Vector3(0, box.size.y * 0.5, 0)
	mi.rotation_degrees = Vector3(0, randf() * 360.0, randf() * 8.0)
	mi.material_override = _tex_mat(rock_tex, Color(0.55, 0.52, 0.48, 1))
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(mi)

func _spawn_bush(pos: Vector3, size: float, bush_tex: String, tint: Color) -> void:
	var mi  := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = size;  sph.height = size * 1.3
	mi.mesh     = sph
	mi.position = pos + Vector3(0, size * 0.6, 0)
	mi.material_override = _tex_mat(bush_tex, tint.lightened(0.15))
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)

## Internal helper: create a StandardMaterial3D with a texture, fallback color,
## and sensible roughness/tiling for outdoor surfaces.
func _tex_mat(tex_path: String, fallback: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	if tex_path != "" and ResourceLoader.exists(tex_path):
		mat.albedo_texture = load(tex_path) as Texture2D
		mat.uv1_scale      = Vector3(3.0, 3.0, 1.0)   # natural tiling
	else:
		mat.albedo_color = fallback
	mat.roughness      = 0.85
	mat.metallic       = 0.0
	mat.metallic_specular = 0.2
	return mat

# ─────────────────────────────────────────────────────────────────────────────
# CAMERA SETUP
# ─────────────────────────────────────────────────────────────────────────────
func _setup_camera() -> void:
	var cam: Camera3D = get_node_or_null("Camera3D")
	if cam == null:
		cam = Camera3D.new()
		cam.name = "Camera3D"
		add_child(cam)
	cam.fov = 75.0   # field of view
	cam.near = 0.1
	cam.far = 1000.0
	# Position camera above and behind player
	if _player:
		cam.position = _player.position + Vector3(0, 10, 10)
		cam.look_at(_player.position, Vector3.UP)
	_player = get_node_or_null("PlayerBody") as CharacterBody3D
	if _player:
		# For 3D, keep camera as child of world, update position in _process
		cam.position = _player.position + Vector3(0, 5, 5)
		cam.look_at(_player.position, Vector3.UP)

# ─────────────────────────────────────────────────────────────────────────────
# HUD BUILDER
# "Set your minds on things above" – Colossians 3:2
# ─────────────────────────────────────────────────────────────────────────────
func _build_hud() -> void:
	_ui_canvas = CanvasLayer.new()
	_ui_canvas.layer = 10
	add_child(_ui_canvas)

	# Fade rect
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 1)
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_canvas.add_child(_fade_rect)

	# ── Tribe + Quest HUD bar (top) ───────────────────────────────────────────
	var top_bar := PanelContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_bottom = 56.0
	var top_style := StyleBoxFlat.new()
	var tcolor := Color("#" + (_tribe_data.get("color", "8B6F47") as String))
	top_style.bg_color = Color(tcolor.r, tcolor.g, tcolor.b, 0.72)
	top_style.corner_radius_bottom_left  = 10
	top_style.corner_radius_bottom_right = 10
	top_style.content_margin_left  = 12
	top_style.content_margin_right = 12
	top_style.content_margin_top   = 6
	top_style.content_margin_bottom = 6
	top_bar.add_theme_stylebox_override("panel", top_style)
	_ui_canvas.add_child(top_bar)

	var top_hbox := HBoxContainer.new()
	top_bar.add_child(top_hbox)

	# Tribal initial badge — identifies the active tribe at a glance
	# "Each stone engraved with one of the twelve tribes" – Exodus 28:21
	var _hud_initial := VisualEnvironment.make_tribe_initial(tribe_key, 40.0)
	top_hbox.add_child(_hud_initial)

	_hud_tribe_label = Label.new()
	_hud_tribe_label.text = "  " + world_name
	_hud_tribe_label.add_theme_font_size_override("font_size", 18)
	_hud_tribe_label.modulate = Color(1, 0.92, 0.6, 1)
	_hud_tribe_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(_hud_tribe_label)

	_hud_quest_label = Label.new()
	_hud_quest_label.text = ""
	_hud_quest_label.add_theme_font_size_override("font_size", 13)
	_hud_quest_label.modulate = Color(0.9, 0.9, 0.9, 0.85)
	top_hbox.add_child(_hud_quest_label)

	# Stones collected counter – live-updated on Global.stones_changed
	# gems_reference_sheet.jpg provides a visual thumbnail of all 12 ephod stones
	var gems_ref := "res://assets/sprites/ui/gems_reference_sheet.jpg"
	if ResourceLoader.exists(gems_ref):
		var gem_thumb := TextureRect.new()
		gem_thumb.texture = load(gems_ref)
		gem_thumb.custom_minimum_size = Vector2(40, 22)
		gem_thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		gem_thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		gem_thumb.modulate = Color(1, 1, 1, 0.88)
		top_hbox.add_child(gem_thumb)
	_stone_hud_label = Label.new()
	_stone_hud_label.text = " %d/12" % Global.stones.size()
	_stone_hud_label.add_theme_font_size_override("font_size", 14)
	_stone_hud_label.modulate = Color(1, 0.88, 0.22, 1)
	top_hbox.add_child(_stone_hud_label)
	# Update whenever a stone is collected anywhere in the game
	# "I have chosen you and have not rejected you" – Isaiah 41:9
	Global.stones_changed.connect(func(): _stone_hud_label.text = " %d/12" % Global.stones.size())

	# ── Interaction hint (floats near player, shown when near interactable) ───
	_interaction_hint = Label.new()
	_interaction_hint.text = "✦ Tap to speak"
	_interaction_hint.add_theme_font_size_override("font_size", 16)
	_interaction_hint.modulate = Color(1, 0.95, 0.6, 1)
	_interaction_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_interaction_hint.offset_top    = -130.0
	_interaction_hint.offset_bottom = -90.0
	_interaction_hint.offset_left   = -160.0
	_interaction_hint.offset_right  =  160.0
	_interaction_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_interaction_hint.visible = false
	_ui_canvas.add_child(_interaction_hint)

	# ── Side Quest tracker panel (bottom-right) ───────────────────────────────
	_sq_panel = PanelContainer.new()
	_sq_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_sq_panel.offset_left   = -280.0
	_sq_panel.offset_right  = -8.0
	_sq_panel.offset_top    = -160.0
	_sq_panel.offset_bottom = -8.0
	var sq_style := StyleBoxFlat.new()
	sq_style.bg_color = Color(0.05, 0.05, 0.05, 0.72)
	sq_style.corner_radius_top_left    = 10
	sq_style.corner_radius_top_right   = 10
	sq_style.corner_radius_bottom_left = 10
	sq_style.corner_radius_bottom_right = 10
	sq_style.border_width_left   = 1
	sq_style.border_width_top    = 1
	sq_style.border_width_right  = 1
	sq_style.border_width_bottom = 1
	sq_style.border_color = Color(0.8, 0.7, 0.2, 0.6)
	sq_style.content_margin_left   = 10
	sq_style.content_margin_right  = 10
	sq_style.content_margin_top    = 8
	sq_style.content_margin_bottom = 8
	_sq_panel.add_theme_stylebox_override("panel", sq_style)
	_ui_canvas.add_child(_sq_panel)

	var sq_vb := VBoxContainer.new()
	sq_vb.add_theme_constant_override("separation", 4)
	_sq_panel.add_child(sq_vb)

	var sq_title := Label.new()
	sq_title.text = "📜 Quests"
	sq_title.add_theme_font_size_override("font_size", 13)
	sq_title.modulate = Color(1, 0.88, 0.22, 1)
	sq_vb.add_child(sq_title)

	_sq_label = Label.new()
	_sq_label.text = "Speak with the elder to begin."
	_sq_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sq_label.add_theme_font_size_override("font_size", 12)
	_sq_label.modulate = Color(0.9, 0.9, 0.9, 0.9)
	sq_vb.add_child(_sq_label)

	# ── Dialogue panel ────────────────────────────────────────────────────────
	_build_dialogue_ui()

	# ── Verse panel ───────────────────────────────────────────────────────────
	_build_verse_ui()

	# ── Nature fact panel ─────────────────────────────────────────────────────
	_build_nature_ui()

	# ── Stone collect label ───────────────────────────────────────────────────
	_stone_label = Label.new()
	_stone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stone_label.add_theme_font_size_override("font_size", 30)
	_stone_label.modulate = Color(1.0, 0.88, 0.0, 0.0)
	_stone_label.set_anchors_preset(Control.PRESET_CENTER)
	_stone_label.offset_left   = -300.0
	_stone_label.offset_right  =  300.0
	_stone_label.offset_top    = -60.0
	_stone_label.offset_bottom =  60.0
	_ui_canvas.add_child(_stone_label)

func _build_dialogue_ui() -> void:
	# Gold-bordered parchment card — slides up from bottom
	# "Let your conversation be full of grace" – Colossians 4:6
	_dialogue_panel = PanelContainer.new()
	_dialogue_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_dialogue_panel.offset_top    = -220.0
	_dialogue_panel.offset_bottom = -12.0
	_dialogue_panel.offset_left   =  40.0
	_dialogue_panel.offset_right  = -40.0
	var tc := Color("#" + (_tribe_data.get("color", "8B6F47") as String))
	# Try parchment texture first; fall back to flat dark card
	var parchment := "res://assets/sprites/ui/panel_parchment.jpg"
	if ResourceLoader.exists(parchment):
		var dp := StyleBoxTexture.new()
		dp.texture               = load(parchment) as Texture2D
		# 9-patch margins — preserve scroll borders, stretch the center
		dp.texture_margin_left   = 130.0
		dp.texture_margin_right  = 130.0
		dp.texture_margin_top    =  70.0
		dp.texture_margin_bottom =  70.0
		dp.content_margin_left   =  18.0
		dp.content_margin_right  =  18.0
		dp.content_margin_top    =  14.0
		dp.content_margin_bottom =  14.0
		_dialogue_panel.add_theme_stylebox_override("panel", dp)
	else:
		var dp := StyleBoxFlat.new()
		dp.bg_color = Color(0.96, 0.90, 0.76, 0.97)   # warm parchment cream
		dp.corner_radius_top_left     = 14
		dp.corner_radius_top_right    = 14
		dp.corner_radius_bottom_left  = 14
		dp.corner_radius_bottom_right = 14
		dp.border_width_left   = 2;  dp.border_width_right  = 2
		dp.border_width_top    = 2;  dp.border_width_bottom = 2
		dp.border_color = tc.lightened(0.3)
		dp.shadow_size  = 10;  dp.shadow_color = Color(0, 0, 0, 0.5)
		dp.content_margin_left = 14;  dp.content_margin_right  = 14
		dp.content_margin_top  = 12;  dp.content_margin_bottom = 12
		_dialogue_panel.add_theme_stylebox_override("panel", dp)
	_ui_canvas.add_child(_dialogue_panel)
	_dialogue_panel.visible = false

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	_dialogue_panel.add_child(hbox)

	# Portrait stack: SVG image on top, tribe initial badge as fallback
	# "Grey hair is a crown of splendour" – Proverbs 16:31
	var portrait_stack := Control.new()
	portrait_stack.custom_minimum_size = Vector2(72, 80)
	hbox.add_child(portrait_stack)
	_dialogue_portrait = VisualEnvironment.make_tribe_initial(tribe_key, 72.0)
	portrait_stack.add_child(_dialogue_portrait)
	_dlg_portrait_img = TextureRect.new()
	_dlg_portrait_img.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_dlg_portrait_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_dlg_portrait_img.custom_minimum_size = Vector2(64, 80)
	_dlg_portrait_img.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dlg_portrait_img.visible = false
	portrait_stack.add_child(_dlg_portrait_img)

	var dvb := VBoxContainer.new()
	dvb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dvb.add_theme_constant_override("separation", 6)
	hbox.add_child(dvb)

	_dialogue_name = Label.new()
	_dialogue_name.add_theme_font_size_override("font_size", 16)
	# Dark brown on parchment — readable over warm cream texture
	_dialogue_name.modulate = Color(0.35, 0.18, 0.04, 1)
	_dialogue_name.add_theme_color_override("font_color", Color(0.35, 0.18, 0.04, 1))
	dvb.add_child(_dialogue_name)

	_dialogue_text = Label.new()
	_dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_text.add_theme_font_size_override("font_size", 17)
	# Near-black text is crisp on the warm parchment background
	_dialogue_text.add_theme_color_override("font_color", Color(0.12, 0.08, 0.04, 1))
	dvb.add_child(_dialogue_text)

	_dialogue_btn = Button.new()
	_dialogue_btn.text = "Continue…"
	_dialogue_btn.custom_minimum_size = Vector2(140, 44)
	_dialogue_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	_dialogue_btn.pressed.connect(_advance_dialogue)
	dvb.add_child(_dialogue_btn)

func _build_verse_ui() -> void:
	_verse_panel = _make_panel(Color(0.97, 0.94, 0.83, 0.97))
	_verse_panel.set_anchors_preset(Control.PRESET_CENTER)
	_verse_panel.offset_left = -360.0;  _verse_panel.offset_right  = 360.0
	_verse_panel.offset_top  = -200.0;  _verse_panel.offset_bottom = 200.0
	_ui_canvas.add_child(_verse_panel)
	_verse_panel.visible = false

	var vvb := VBoxContainer.new()
	vvb.add_theme_constant_override("separation", 12)
	_verse_panel.add_child(vvb)

	# Tribe initial in verse scroll header — reinforces tribal identity
	var _verse_initial_row := HBoxContainer.new()
	_verse_initial_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_verse_initial_row.add_theme_constant_override("separation", 14)
	vvb.add_child(_verse_initial_row)
	var _vi := VisualEnvironment.make_tribe_initial(tribe_key, 56.0)
	_verse_initial_row.add_child(_vi)

	var t := Label.new()
	t.text = "✦ A Word for You ✦"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 22)
	t.modulate = Color(0.55, 0.38, 0.05, 1)
	vvb.add_child(t)

	_verse_ref = Label.new()
	_verse_ref.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_verse_ref.add_theme_font_size_override("font_size", 16)
	_verse_ref.modulate = Color(0.5, 0.35, 0.05, 1)
	vvb.add_child(_verse_ref)

	_verse_text = Label.new()
	_verse_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_verse_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_verse_text.add_theme_font_size_override("font_size", 17)
	vvb.add_child(_verse_text)

	var mem := Label.new()
	mem.text = "Type the first few words to memorise (or tap Skip):"
	mem.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mem.add_theme_font_size_override("font_size", 13)
	mem.modulate = Color(0.45, 0.45, 0.45, 1)
	vvb.add_child(mem)

	_verse_input = LineEdit.new()
	_verse_input.placeholder_text = "Begin typing the verse…"
	_verse_input.custom_minimum_size = Vector2(0, 44)
	vvb.add_child(_verse_input)

	_verse_btn = Button.new()
	_verse_btn.text = "Skip for now"
	_verse_btn.custom_minimum_size = Vector2(0, 44)
	_verse_btn.pressed.connect(_on_verse_done)
	vvb.add_child(_verse_btn)

	_verse_input.text_submitted.connect(func(_t): _on_verse_done())

func _build_nature_ui() -> void:
	_nature_panel = _make_panel(Color(0.87, 0.97, 0.87, 0.97))
	_nature_panel.set_anchors_preset(Control.PRESET_CENTER)
	_nature_panel.offset_left = -360.0;  _nature_panel.offset_right  = 360.0
	_nature_panel.offset_top  = -210.0;  _nature_panel.offset_bottom = 210.0
	_ui_canvas.add_child(_nature_panel)
	_nature_panel.visible = false

	var nvb := VBoxContainer.new()
	nvb.add_theme_constant_override("separation", 12)
	_nature_panel.add_child(nvb)

	var nt := Label.new()
	nt.text = "🌿 God's Creation Speaks"
	nt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nt.add_theme_font_size_override("font_size", 22)
	nt.modulate = Color(0.12, 0.48, 0.12, 1)
	nvb.add_child(nt)

	_nature_text = Label.new()
	_nature_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_nature_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_nature_text.add_theme_font_size_override("font_size", 16)
	nvb.add_child(_nature_text)

	nvb.add_child(HSeparator.new())

	_nature_verse = Label.new()
	_nature_verse.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_nature_verse.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_nature_verse.add_theme_font_size_override("font_size", 15)
	_nature_verse.modulate = Color(0.12, 0.38, 0.10, 1)
	nvb.add_child(_nature_verse)

	_nature_btn = Button.new()
	_nature_btn.text = "Thank you, God! ✦"
	_nature_btn.custom_minimum_size = Vector2(0, 48)
	_nature_btn.pressed.connect(_on_nature_done)
	nvb.add_child(_nature_btn)

# ─────────────────────────────────────────────────────────────────────────────
# STONE COLLECTION
# "The stone the builders rejected has become the cornerstone" – Psalm 118:22
# ─────────────────────────────────────────────────────────────────────────────
func _collect_stone() -> void:
	if _stone_collected:
		return
	_stone_collected = true
	Global.add_stone(tribe_key)
	Global.complete_quest(quest_id)
	AudioManager.play_sfx("res://assets/audio/sfx/stone_unlock.wav")

	var stone_name: String = _tribe_data.get("stone_name", "Stone")
	var tribe_display: String = _tribe_data.get("display", tribe_key.capitalize())
	_stone_label.text = "✦ %s Stone Collected!\nTribe of %s" % [stone_name, tribe_display]

	# ── Gem popup: centred card showing the tribe SVG gem ─────────────────
	# "A ruby, a topaz and a beryl…each engraved like a seal" – Exodus 28:17
	_show_gem_popup(tribe_key, stone_name, tribe_display)

	# Glow in the HUD stone label
	var tw := create_tween()
	tw.tween_property(_stone_label, "modulate:a", 1.0, 0.5)

	# Golden particle burst (joy!)
	var particles := GPUParticles3D.new()
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 2.0
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 45.0
	mat.gravity = Vector3(0, -9.8, 0)
	mat.initial_velocity_min = 5.0
	mat.initial_velocity_max = 10.0
	mat.color = Color(1.0, 0.9, 0.0, 1.0)  # Golden sparkles
	particles.process_material = mat
	particles.amount = 50
	particles.lifetime = 2.0
	particles.one_shot = true
	add_child(particles)
	if _player:
		particles.position = _player.position + Vector3(0, 1, 0)

	tw.tween_interval(3.5)
	tw.tween_callback(_go_next)

func _show_gem_popup(t_key: String, stone_name: String, tribe_display: String) -> void:
	# Full-screen overlay dims scene, centred card shows the gem SVG
	# "You are precious in my eyes" – Isaiah 43:4
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_canvas.add_child(overlay)

	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left   = -160.0
	card.offset_right  =  160.0
	card.offset_top    = -210.0
	card.offset_bottom =  210.0
	card.modulate.a    = 0.0
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.98, 0.95, 0.85, 0.97)
	sb.corner_radius_top_left     = 18
	sb.corner_radius_top_right    = 18
	sb.corner_radius_bottom_left  = 18
	sb.corner_radius_bottom_right = 18
	sb.border_width_left   = 3;  sb.border_width_right  = 3
	sb.border_width_top    = 3;  sb.border_width_bottom = 3
	sb.border_color = Color("#FFD700")
	sb.shadow_size  = 18;  sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.content_margin_left = 22;  sb.content_margin_right  = 22
	sb.content_margin_top  = 18;  sb.content_margin_bottom = 18
	card.add_theme_stylebox_override("panel", sb)
	_ui_canvas.add_child(card)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(vb)

	# Gem SVG image (128 × 128) — tribe's own faceted stone
	var gem_svg := AssetRegistry.gem(t_key)
	if gem_svg != "" and ResourceLoader.exists(gem_svg):
		var gem_img := TextureRect.new()
		gem_img.texture = load(gem_svg) as Texture2D
		gem_img.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		gem_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		gem_img.custom_minimum_size = Vector2(128, 128)
		gem_img.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		vb.add_child(gem_img)

	var title_lbl := Label.new()
	title_lbl.text = stone_name + " Stone"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 22)
	title_lbl.add_theme_color_override("font_color", Color("#8B4A00"))
	title_lbl.modulate = Color("#FFD700")
	vb.add_child(title_lbl)

	var tribe_lbl := Label.new()
	tribe_lbl.text = "Tribe of %s" % tribe_display
	tribe_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tribe_lbl.add_theme_font_size_override("font_size", 16)
	tribe_lbl.add_theme_color_override("font_color", Color(0.3, 0.18, 0.05, 1))
	vb.add_child(tribe_lbl)

	var verse_lbl := Label.new()
	verse_lbl.text = "\"You are precious in my eyes…\"\n– Isaiah 43:4"
	verse_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	verse_lbl.add_theme_font_size_override("font_size", 13)
	verse_lbl.add_theme_color_override("font_color", Color(0.45, 0.30, 0.10, 1))
	verse_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(verse_lbl)

	# Animate: overlay fades to 0.55, card scales in, then fades out
	var pop := create_tween()
	pop.tween_property(overlay, "color:a", 0.55, 0.4)
	pop.parallel().tween_property(card, "modulate:a", 1.0, 0.45)
	pop.parallel().tween_property(card, "scale", Vector2(1.0, 1.0), 0.45).from(Vector2(0.4, 0.4)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	pop.tween_interval(2.2)
	pop.tween_property(card,    "modulate:a", 0.0, 0.5)
	pop.parallel().tween_property(overlay, "color:a", 0.0, 0.5)
	pop.tween_callback(func():
		card.queue_free()
		overlay.queue_free()
	)

func _go_next() -> void:
	_fade_out_and_change(next_scene if next_scene != "" else "res://scenes/Finale.tscn")

# ─────────────────────────────────────────────────────────────────────────────
# PLAYER CONNECTION
# ─────────────────────────────────────────────────────────────────────────────
func _connect_player() -> void:
	_player = get_node_or_null("PlayerBody") as CharacterBody3D
	if _player == null:
		push_error("[WorldBase] No 'PlayerBody' CharacterBody3D found in %s" % name)
		return
	# Listen for interaction events from the player
	if _player.has_signal("interaction_requested"):
		_player.interaction_requested.connect(_on_player_interact)
	if _player.has_signal("interactable_entered"):
		_player.interactable_entered.connect(_on_interactable_entered)
	if _player.has_signal("interactable_exited"):
		_player.interactable_exited.connect(_on_interactable_exited)

# ─────────────────────────────────────────────────────────────────────────────
# INTERACTION SYSTEM
# "Ask and it will be given to you; seek and you will find" – Matthew 7:7
# ─────────────────────────────────────────────────────────────────────────────
func _on_interactable_entered(node: Node) -> void:
	_interaction_target = node
	var label_text: String = "✦ Tap to interact"
	if node.has_method("get_interaction_label"):
		label_text = node.get_interaction_label() as String
	_interaction_hint.text = label_text
	_interaction_hint.visible = true
	# Kill any previous pulse tween before creating a new one
	# (prevents tween stacking when player moves between NPCs quickly)
	if _hint_tween and _hint_tween.is_valid():
		_hint_tween.kill()
	_hint_tween = create_tween()
	_hint_tween.set_loops()
	_hint_tween.tween_property(_interaction_hint, "modulate:a", 0.5, 0.7).set_ease(Tween.EASE_IN_OUT)
	_hint_tween.tween_property(_interaction_hint, "modulate:a", 1.0, 0.7).set_ease(Tween.EASE_IN_OUT)

func _on_interactable_exited(node: Node) -> void:
	if _interaction_target == node:
		_interaction_target = null
		_interaction_hint.visible = false
		_interaction_hint.modulate.a = 1.0   # reset alpha so hint is clean next time
		if _hint_tween and _hint_tween.is_valid():
			_hint_tween.kill()
			_hint_tween = null

func _on_player_interact() -> void:
	if _interaction_target == null:
		return
	# Block interaction while any UI overlay is active
	# "There is a time for everything" – Ecclesiastes 3:1
	if _dialogue_panel.visible or _verse_panel.visible or _nature_panel.visible:
		return
	if _interaction_target.has_method("on_interact"):
		_interaction_target.on_interact(self)

# ─────────────────────────────────────────────────────────────────────────────
# DIALOGUE SYSTEM  –  "Col 4:6 – Let your conversation be full of grace"
# ─────────────────────────────────────────────────────────────────────────────
func show_dialogue(lines: Array) -> void:
	_dialogue_queue = lines.duplicate()
	_dialogue_panel.visible = true
	# Pause player movement during dialogue
	if _player:
		_player.set_physics_process(false)
	_slide_dialogue_in()
	_advance_dialogue()

func _slide_dialogue_in() -> void:
	_dialogue_panel.offset_top    = 100.0
	_dialogue_panel.offset_bottom = 300.0
	var tw := create_tween()
	tw.tween_property(_dialogue_panel, "offset_top",    -220.0, 0.38).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.parallel().tween_property(_dialogue_panel, "offset_bottom", -12.0, 0.38).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _advance_dialogue() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	if _dialogue_queue.is_empty():
		_dialogue_panel.visible = false
		# Resume player movement
		if _player:
			_player.set_physics_process(true)
		return
	var line: Dictionary = _dialogue_queue.pop_front()
	var speaker: String = line.get("name", "") as String
	_dialogue_name.text = speaker
	_dialogue_text.text = line.get("text", "") as String
	_dialogue_btn.text  = "Continue…" if _dialogue_queue.size() > 0 else "I understand ✦"
	# Lofi voice murmur – each character has their own warmth
	# "A gentle answer turns away wrath" – Proverbs 15:1
	AudioManager.play_voice(speaker)
	# Portrait: try tribe elder SVG first; fall back to emoji badge
	# "I will look on them with favour" – Leviticus 26:9
	var _elder_svg := AssetRegistry.elder(tribe_key)
	var _is_elder  := speaker.to_lower().contains("elder")
	if _dlg_portrait_img != null:
		if _is_elder and _elder_svg != "" and ResourceLoader.exists(_elder_svg):
			_dlg_portrait_img.texture = load(_elder_svg) as Texture2D
			_dlg_portrait_img.visible = true
			if _dialogue_portrait != null:
				_dialogue_portrait.visible = false
		else:
			_dlg_portrait_img.visible = false
			if _dialogue_portrait != null:
				_dialogue_portrait.visible = true
				var lbl: Label = _dialogue_portrait.get_child(0) as Label
				if lbl != null:
					if speaker.to_lower() == "you":
						lbl.text = "🧒"
					elif _is_elder:
						lbl.text = "👴"
					else:
						lbl.text = "💬"
	if line.has("callback") and line["callback"] is Callable:
		var cb: Callable = line["callback"]
		_dialogue_btn.pressed.disconnect(_advance_dialogue)
		_dialogue_btn.pressed.connect(func():
			_dialogue_btn.pressed.connect(_advance_dialogue)
			_advance_dialogue()
			cb.call()
		, CONNECT_ONE_SHOT)

# ─────────────────────────────────────────────────────────────────────────────
# VERSE SYSTEM  –  "Your word is a lamp to my feet" – Psalm 119:105
# ─────────────────────────────────────────────────────────────────────────────
func show_verse_scroll(ref_text: String, verse_body: String) -> void:
	_verse_ref.text  = ref_text
	_verse_text.text = verse_body
	_verse_input.text = ""
	_verse_panel.visible = true
	AudioManager.play_sfx("res://assets/audio/sfx/verse_reveal.wav")
	if _player:
		_player.set_physics_process(false)

func _on_verse_done() -> void:
	var typed: String = _verse_input.text.strip_edges().to_lower()
	var first_words: String = _verse_text.text.to_lower().left(30)
	if typed.length() >= 6 and first_words.begins_with(typed.left(6)):
		# Award heart badge for memorisation attempt
		var key_str: String = _verse_ref.text
		if not Global.heart_badges.has(key_str):
			Global.heart_badges.append(key_str)
			_verse_btn.text = "✦ Heart Badge Earned! ✦"
			AudioManager.play_sfx("res://assets/audio/sfx/heart_badge.wav")
			await get_tree().create_timer(1.4).timeout
	AudioManager.play_sfx("res://assets/audio/sfx/ui_close.wav")
	_verse_panel.visible = false
	if _player:
		_player.set_physics_process(true)
	show_nature_fact()

func show_nature_fact() -> void:
	var fact: String  = _tribe_data.get("nature_fact",      "God's creation is wonderful.") as String
	var vref: String  = _tribe_data.get("nature_verse_ref", "") as String
	var vtext: String = _tribe_data.get("nature_verse",     "") as String
	_nature_text.text  = fact
	_nature_verse.text = "\"" + vtext + "\"\n– " + vref if vref != "" else vtext
	_nature_panel.visible = true
	AudioManager.play_sfx("res://assets/audio/sfx/ui_open.wav")
	if _player:
		_player.set_physics_process(false)

func _on_nature_done() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/ui_close.wav")
	_nature_panel.visible = false
	if _player:
		_player.set_physics_process(true)
	_collect_stone()

# ─────────────────────────────────────────────────────────────────────────────
# SIDE QUEST HELPERS
# ─────────────────────────────────────────────────────────────────────────────
func update_quest_log(text: String) -> void:
	_sq_label.text = text
	# Pulse the panel to alert the player
	var tw := create_tween()
	tw.tween_property(_sq_panel, "modulate:a", 0.4, 0.2).set_ease(Tween.EASE_IN)
	tw.tween_property(_sq_panel, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)

func set_world_name(display: String) -> void:
	_hud_tribe_label.text = "⛰ " + display

# ─────────────────────────────────────────────────────────────────────────────
# FADE HELPERS
# ─────────────────────────────────────────────────────────────────────────────
func _fade_in() -> void:
	var tw := create_tween()
	tw.tween_property(_fade_rect, "color:a", 0.0, 1.0).set_ease(Tween.EASE_IN_OUT)

# ─────────────────────────────────────────────────────────────────────────────
# UTILITY
# ─────────────────────────────────────────────────────────────────────────────
# ─────────────────────────────────────────────────────────────────────────────
# QUESTBASE COMPATIBILITY SHIM
# Allows Quest3–12 (originally QuestBase) to work inside WorldBase with only
# minimal code changes.  New worlds should use inline _ui_canvas panels instead
# (see Quest1 / Quest2 for the recommended pattern).
# "Every good gift is from above" – James 1:17
# ─────────────────────────────────────────────────────────────────────────────

## Lazy-created centred panel.  Quest scripts use this as their mini-game host.
var _mini_game_container: PanelContainer

func _init_mini_game_container() -> void:
	if _mini_game_container and is_instance_valid(_mini_game_container):
		return
	_mini_game_container = PanelContainer.new()
	_mini_game_container.name = "MiniGameContainer"
	_mini_game_container.set_anchors_preset(Control.PRESET_CENTER)
	_mini_game_container.offset_left   = -340.0
	_mini_game_container.offset_right  =  340.0
	_mini_game_container.offset_top    = -280.0
	_mini_game_container.offset_bottom =  280.0
	_mini_game_container.visible       = false
	var sty := StyleBoxFlat.new()
	sty.bg_color = Color(0.05, 0.04, 0.03, 0.97)
	sty.corner_radius_top_left     = 14
	sty.corner_radius_top_right    = 14
	sty.corner_radius_bottom_left  = 14
	sty.corner_radius_bottom_right = 14
	sty.border_color = Color(0.82, 0.72, 0.18, 1)
	sty.border_width_left   = 2; sty.border_width_right  = 2
	sty.border_width_top    = 2; sty.border_width_bottom = 2
	sty.content_margin_left   = 16; sty.content_margin_right  = 16
	sty.content_margin_top    = 16; sty.content_margin_bottom = 16
	_mini_game_container.add_theme_stylebox_override("panel", sty)
	_ui_canvas.add_child(_mini_game_container)

## Instantiate TapMinigame.tscn into *parent*, wire callbacks.
## Returns {"root": Node} so subclass can compare dicts as IDs.
func build_tap_minigame(parent: Node, goal: int,
		prompt_text: String, time_limit: float = 15.0) -> Dictionary:
	var mg = preload("res://scenes/minigames/TapMinigame.tscn").instantiate()
	mg.goal       = goal
	mg.prompt     = prompt_text
	mg.time_limit = time_limit
	parent.add_child(mg)
	# Pass the minigame's own result dict through so subclass gets actual data
	mg.minigame_complete.connect(func(r: Dictionary): on_minigame_complete(r))
	mg.minigame_timeout.connect(func(r: Dictionary):  on_minigame_timeout(r))
	return {"root": mg}

## Instantiate RhythmMinigame.tscn into *parent*, wire callbacks.
func build_rhythm_minigame(parent: Node, beat_dur: float, beats: int,
		goal_score: int, prompt_text: String) -> Dictionary:
	var mg = preload("res://scenes/minigames/RhythmMinigame.tscn").instantiate()
	mg.beat_duration = beat_dur
	mg.total_beats   = beats
	mg.goal_score    = goal_score
	mg.prompt        = prompt_text
	parent.add_child(mg)
	# Pass the minigame's own result dict through so subclass gets actual data
	mg.minigame_complete.connect(func(r: Dictionary): on_minigame_complete(r))
	mg.minigame_timeout.connect(func(r: Dictionary):  on_minigame_timeout(r))
	return {"root": mg}

## Instantiate SwipeMinigame.tscn into *parent*, wire callbacks.
## "Run with perseverance the race marked out for us" – Hebrews 12:1
func build_swipe_minigame(parent: Node, goal: int,
		prompt_text: String, time_limit: float = 15.0) -> Dictionary:
	var mg = preload("res://scenes/minigames/SwipeMinigame.tscn").instantiate()
	mg.goal       = goal
	mg.prompt     = prompt_text
	mg.time_limit = time_limit
	parent.add_child(mg)
	mg.minigame_complete.connect(func(r: Dictionary): on_minigame_complete(r))
	mg.minigame_timeout.connect(func(r: Dictionary):  on_minigame_timeout(r))
	return {"root": mg}

## Instantiate SortingMinigame.tscn into *parent*, wire callbacks.
## "To every thing there is a season, and a time to every purpose" – Ecclesiastes 3:1
func build_sorting_minigame(parent: Node, goal: int,
		prompt_text: String, time_limit: float = 15.0) -> Dictionary:
	var mg = preload("res://scenes/minigames/SortingMinigame.tscn").instantiate()
	mg.goal       = goal
	mg.prompt     = prompt_text
	mg.time_limit = time_limit
	parent.add_child(mg)
	mg.minigame_complete.connect(func(r: Dictionary): on_minigame_complete(r))
	mg.minigame_timeout.connect(func(r: Dictionary):  on_minigame_timeout(r))
	return {"root": mg}

## Instantiate DialogueChoiceMinigame.tscn into *parent*, wire callbacks.
## "Let your conversation be always full of grace" – Colossians 4:6
func build_dialogue_choice_minigame(parent: Node, goal: int,
		prompt_text: String) -> Dictionary:
	var mg = preload("res://scenes/minigames/DialogueChoiceMinigame.tscn").instantiate()
	mg.goal   = goal
	mg.prompt = prompt_text
	parent.add_child(mg)
	mg.minigame_complete.connect(func(r: Dictionary): on_minigame_complete(r))
	mg.minigame_timeout.connect(func(r: Dictionary):  on_minigame_timeout(r))
	return {"root": mg}

## Build an inline tower-defence minigame directly in *parent* (no scene).
## Matches the QuestBase signature exactly for drop-in migration.
## "He is a shield to those who take refuge in him" – Proverbs 30:5
func build_tower_defense_minigame(parent: Node, goal: int,
		prompt_text: String, time_limit: float = 25.0) -> Dictionary:
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	parent.add_child(root)

	var plbl := Label.new()
	plbl.text = prompt_text
	plbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	plbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	plbl.add_theme_font_size_override("font_size", 18)
	root.add_child(plbl)

	var stronghold := Label.new()
	stronghold.text = "🏰 Stronghold Defense 🏰"
	stronghold.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stronghold.add_theme_font_size_override("font_size", 24)
	root.add_child(stronghold)

	var prog := ProgressBar.new()
	prog.min_value = 0.0;  prog.max_value = float(goal);  prog.value = 0.0
	prog.custom_minimum_size = Vector2(0, 28)
	root.add_child(prog)

	var wave_lbl := Label.new()
	wave_lbl.text = "Wave: 1 / %d" % goal
	wave_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(wave_lbl)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 15)
	root.add_child(btn_row)

	var place_btn := Button.new()
	place_btn.text = "Place Tower\n🏹"
	place_btn.custom_minimum_size = Vector2(120, 60)
	btn_row.add_child(place_btn)

	var defend_btn := Button.new()
	defend_btn.text = "Defend!\n⚔️"
	defend_btn.custom_minimum_size = Vector2(120, 60)
	btn_row.add_child(defend_btn)

	var towers         := [0]
	var waves_defeated := [0]
	var done           := [false]
	var invaders       := ["🐺 Wolf", "🦌 Deer", "🐻 Bear", "🦊 Fox"]
	var result := {"root": root, "wave_label": wave_lbl, "bar": prog}

	var spawn_invader := func():
		stronghold.text = "🏰 %s approaches! 🏰" % invaders.pick_random()

	var check_defense := func():
		if done[0]: return
		if (towers[0] as int) > 0:
			waves_defeated[0] += 1
			prog.value = waves_defeated[0]
			wave_lbl.text = "Wave: %d / %d" % [waves_defeated[0] + 1, goal]
			AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
			stronghold.text = "🏰 Wave defeated! 🏰"
			if waves_defeated[0] >= goal:
				done[0] = true
				place_btn.disabled = true;  defend_btn.disabled = true
				stronghold.text = "🏰 Stronghold Secured! 🏰"
				on_minigame_complete(result)
			else:
				towers[0] = max(0, towers[0] - 1)
				await get_tree().create_timer(0.8).timeout
				spawn_invader.call()
		else:
			AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
			stronghold.text = "🏰 Breached! Place towers first. 🏰"
			await get_tree().create_timer(1.0).timeout
			spawn_invader.call()

	place_btn.pressed.connect(func():
		towers[0] += 1
		AudioManager.play_sfx("res://assets/audio/sfx/tap.wav")
		stronghold.text = "🏰 Tower placed! (%d) 🏰" % towers[0]
	)
	defend_btn.pressed.connect(check_defense)
	spawn_invader.call()

	if time_limit > 0.0:
		get_tree().create_timer(time_limit).timeout.connect(func():
			if not done[0]:
				done[0] = true
				place_btn.disabled = true;  defend_btn.disabled = true
				stronghold.text = "Time's up! Defense holds."
				on_minigame_timeout(result)
		)
	return result

## Virtual — subclass overrides to handle specific mini-game result dispatch.
func on_minigame_complete(_result: Dictionary) -> void:
	pass

func on_minigame_timeout(_result: Dictionary) -> void:
	pass

## Convenience: show quest verse (matches the QuestBase helper name used by old quests)
func _show_quest_verse() -> void:
	show_verse_scroll(
		_tribe_data.get("quest_verse_ref", "") as String,
		_tribe_data.get("quest_verse", "") as String
	)

func _make_panel(bg: Color) -> PanelContainer:
	var p := PanelContainer.new()
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left     = 12
	s.corner_radius_top_right    = 12
	s.corner_radius_bottom_left  = 12
	s.corner_radius_bottom_right = 12
	s.shadow_size = 8
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.content_margin_left   = 18
	s.content_margin_right  = 18
	s.content_margin_top    = 16
	s.content_margin_bottom = 16
	p.add_theme_stylebox_override("panel", s)
	return p

# ─────────────────────────────────────────────────────────────────────────────
# TERRAIN HELPERS
# "He set the earth on its foundations" – Psalm 104:5
# ─────────────────────────────────────────────────────────────────────────────
func _tr(pos: Vector3, size: Vector3, texture: String) -> void:
	# terrain() call: if texture is a bare semantic key (e.g. "grass") use
	# AssetRegistry; if it contains a "/" or "." assume a full/UUID path.
	var tex_path: String
	if texture.contains("/") or texture.contains("."):
		tex_path = "res://assets/textures/" + texture if not texture.begins_with("res://") else texture
	elif texture == "":
		tex_path = AssetRegistry.tribe_terrain(tribe_key)
	else:
		tex_path = AssetRegistry.terrain(texture)

	var terrain := MeshInstance3D.new()
	var plane   := PlaneMesh.new()
	plane.size  = Vector2(size.x, size.z)
	terrain.mesh = plane
	terrain.position = pos + Vector3(0, size.y / 2.0, 0)
	terrain.material_override = _tex_mat(tex_path, Color(0.55, 0.44, 0.28, 1))
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var body  := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = size
	body.add_child(shape)
	terrain.add_child(body)
	add_child(terrain)

func _wall(pos: Vector3, size: Vector3, texture: String) -> void:
	var tex_path: String
	if texture.contains("/") or texture.contains("."):
		tex_path = "res://assets/textures/" + texture if not texture.begins_with("res://") else texture
	elif texture == "":
		tex_path = AssetRegistry.tribe_wall(tribe_key)
	else:
		tex_path = AssetRegistry.wall(texture)

	var wall_mi := MeshInstance3D.new()
	var box     := BoxMesh.new()
	box.size    = size
	wall_mi.mesh     = box
	wall_mi.position = pos + Vector3(0, size.y / 2.0, 0)
	wall_mi.material_override = _tex_mat(tex_path, Color(0.48, 0.40, 0.30, 1))
	wall_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

	var body  := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = size
	body.add_child(shape)
	wall_mi.add_child(body)
	add_child(wall_mi)

# ─────────────────────────────────────────────────────────────────────────────
# NPC HELPERS
# "Do not forget to show hospitality to strangers" – Hebrews 13:2
# ─────────────────────────────────────────────────────────────────────────────
func _build_npc(key: String, pos: Vector3, texture: String) -> void:
	# "Do not forget to show hospitality to strangers" – Hebrews 13:2
	# Character = collision Area3D + layered mesh (body capsule + head sphere)
	var npc := Area3D.new()
	npc.position      = pos
	npc.collision_layer = 4   # NPC layer
	npc.collision_mask  = 1   # Player layer
	npc.set_meta("key", key)

	# Collision capsule
	var shape := CollisionShape3D.new()
	var caps  := CapsuleShape3D.new()
	caps.radius = 0.45;  caps.height = 1.7
	shape.shape = caps
	shape.position = Vector3(0, 0.85, 0)
	npc.add_child(shape)

	# ── Determine textures ────────────────────────────────────────────────────
	var skin_path: String
	var robe_path: String
	if texture != "" and not texture.begins_with("res://"):
		# Legacy UUID filename passed directly
		skin_path = "res://assets/textures/" + texture
		robe_path = AssetRegistry.tribe_robe(tribe_key)
	else:
		skin_path = AssetRegistry.tribe_skin(tribe_key)
		robe_path = AssetRegistry.tribe_robe(tribe_key)

	# ── Body (robe / tunic) – main capsule ───────────────────────────────────
	var body_mi   := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.42;  body_mesh.height = 1.35
	body_mi.mesh     = body_mesh
	body_mi.position = Vector3(0, 0.68, 0)
	body_mi.material_override = _tex_mat(robe_path, Color(0.72, 0.58, 0.38, 1))
	body_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	npc.add_child(body_mi)

	# ── Head (skin) – sphere on top ───────────────────────────────────────────
	var head_mi   := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.28;  head_mesh.height = 0.56
	head_mi.mesh     = head_mesh
	head_mi.position = Vector3(0, 1.56, 0)
	head_mi.material_override = _tex_mat(skin_path, Color(0.88, 0.70, 0.52, 1))
	head_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	npc.add_child(head_mi)

	# ── Gentle idle bob animation ─────────────────────────────────────────────
	var tw := create_tween()
	tw.set_loops()
	tw.tween_property(npc, "position:y", pos.y + 0.12, 1.8).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(npc, "position:y", pos.y,         1.8).set_ease(Tween.EASE_IN_OUT)

	# ── Interaction zone ──────────────────────────────────────────────────────
	npc.body_entered.connect(func(body: Node3D):
		if body == _player:
			_interaction_target = npc
			_interaction_hint.text = "✦ Tap to speak with " + key.capitalize()
			_interaction_hint.visible = true
	)
	npc.body_exited.connect(func(body: Node3D):
		if body == _player and _interaction_target == npc:
			_interaction_target = null
			_interaction_hint.visible = false
	)
	add_child(npc)

# ─────────────────────────────────────────────────────────────────────────────
# CHEST HELPERS
# "Ask and it will be given to you" – Matthew 7:7
# ─────────────────────────────────────────────────────────────────────────────
func _chest(pos: Vector3, key: String, label: String) -> void:
	# "Ask and it will be given to you" – Matthew 7:7
	var chest := Area3D.new()
	chest.position      = pos
	chest.collision_layer = 8  # Chest layer
	chest.collision_mask  = 1  # Player layer
	chest.set_meta("key",   key)
	chest.set_meta("label", label)

	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = Vector3(1.0, 0.75, 0.7)
	shape.position = Vector3(0, 0.375, 0)
	chest.add_child(shape)

	# ── Body (wooden box) ─────────────────────────────────────────────────────
	var body_mi   := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(1.0, 0.5, 0.7)
	body_mi.mesh   = body_mesh
	body_mi.position = Vector3(0, 0.25, 0)
	body_mi.material_override = _tex_mat(
		AssetRegistry.wall("cedar"),
		Color(0.55, 0.38, 0.18, 1)
	)
	body_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	chest.add_child(body_mi)

	# ── Lid (gold-trim box on top) ────────────────────────────────────────────
	var lid_mi   := MeshInstance3D.new()
	var lid_mesh := BoxMesh.new()
	lid_mesh.size = Vector3(1.04, 0.26, 0.74)
	lid_mi.mesh   = lid_mesh
	lid_mi.position = Vector3(0, 0.63, 0)
	lid_mi.material_override = _tex_mat(
		AssetRegistry.wall("gold"),
		Color(0.82, 0.66, 0.15, 1)
	)
	lid_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	chest.add_child(lid_mi)

	# Soft golden glow OmniLight near chest
	var glow := OmniLight3D.new()
	glow.light_color  = Color(1.0, 0.9, 0.35, 1)
	glow.light_energy = 0.7
	glow.omni_range   = 5.0
	glow.position     = Vector3(0, 1.0, 0)
	chest.add_child(glow)

	# Pulse glow
	var tw := create_tween()
	tw.set_loops()
	tw.tween_property(glow, "light_energy", 0.3, 1.2).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(glow, "light_energy", 0.7, 1.2).set_ease(Tween.EASE_IN_OUT)

	chest.body_entered.connect(func(body: Node3D):
		if body == _player:
			_interaction_target = chest
			_interaction_hint.text = "✦ Tap to open " + label
			_interaction_hint.visible = true
	)
	chest.body_exited.connect(func(body: Node3D):
		if body == _player and _interaction_target == chest:
			_interaction_target = null
			_interaction_hint.visible = false
	)
	add_child(chest)

# ─────────────────────────────────────────────────────────────────────────────
# COLLECTIBLE HELPERS
# "Seek and you will find" – Matthew 7:7
# ─────────────────────────────────────────────────────────────────────────────
func _place_collectible(pos: Vector3, type: String, callback: Callable) -> void:
	var collectible := Area3D.new()
	collectible.position = pos
	collectible.collision_layer = 16  # Collectible layer
	collectible.collision_mask = 1    # Player layer
	
	var shape := CollisionShape3D.new()
	shape.shape = SphereShape3D.new()
	shape.shape.radius = 0.5
	collectible.add_child(shape)
	
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	mesh.mesh = sphere
	var mat := StandardMaterial3D.new()
	if type == "butterfly":
		mat.albedo_color = Color(1.0, 0.5, 0.8, 1.0)  # Pink butterfly
		mat.emission = Color(1.0, 0.8, 1.0, 0.5)  # Gentle glow
	elif type == "flower":
		mat.albedo_color = Color(1.0, 1.0, 0.5, 1.0)  # Yellow flower
	else:
		mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	mesh.material_override = mat
	collectible.add_child(mesh)
	
	collectible.body_entered.connect(func(body):
		if body == _player:
			collectible.queue_free()
			callback.call()
	)
	
	add_child(collectible)

# ─────────────────────────────────────────────────────────────────────────────
# TOUCH MINI-GAME HELPERS
# "Be still and know that I am God" – Psalm 46:10
# ─────────────────────────────────────────────────────────────────────────────
func build_touch_tap_minigame(parent: Node, goal: int, prompt: String, time_limit: float) -> Dictionary:
	# Enhanced tap mini-game with touch feedback
	var container := Control.new()
	container.name = "TouchTapMinigame"
	container.set_anchors_preset(PRESET_FULL_RECT)
	parent.add_child(container)
	
	var result := {
		"root": container,
		"taps": 0,
		"goal": goal,
		"start_time": Time.get_time_since_startup(),
		"time_limit": time_limit,
		"completed": false
	}
	
	# Visual feedback area
	var tap_zone := ColorRect.new()
	tap_zone.name = "TapZone"
	tap_zone.set_anchors_preset(PRESET_FULL_RECT)
	tap_zone.color = Color(1, 1, 1, 0.1)
	container.add_child(tap_zone)
	
	# Progress indicator
	var progress := ProgressBar.new()
	progress.name = "Progress"
	progress.set_anchors_preset(PRESET_TOP_WIDE)
	progress.position.y = 50
	progress.size.y = 30
	progress.max_value = goal
	progress.value = 0
	container.add_child(progress)
	
	# Prompt label
	var label := Label.new()
	label.name = "Prompt"
	label.text = prompt
	label.set_anchors_preset(PRESET_CENTER_TOP)
	label.position.y = 20
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(label)
	
	# Touch input handling
	container.gui_input.connect(func(event: InputEvent):
		if event is InputEventScreenTouch and event.pressed:
			result.taps += 1
			progress.value = result.taps
			
			# Visual feedback
			var feedback := ColorRect.new()
			feedback.size = Vector2(100, 100)
			feedback.position = event.position - Vector2(50, 50)
			feedback.color = Color(1, 1, 0, 0.5)
			container.add_child(feedback)
			
			var tw := create_tween()
			tw.tween_property(feedback, "modulate:a", 0.0, 0.3)
			tw.tween_callback(feedback.queue_free)
			
			# Check completion
			if result.taps >= goal:
				result.completed = true
				on_minigame_complete(result)
	)
	
	# Time limit
	var timer := Timer.new()
	timer.wait_time = time_limit
	timer.one_shot = true
	timer.timeout.connect(func():
		if not result.completed:
			on_minigame_timeout(result)
	)
	container.add_child(timer)
	timer.start()
	
	return result

func build_touch_rhythm_minigame(parent: Node, beat_duration: float, beats: int, goal: int, prompt: String) -> Dictionary:
	# Rhythm mini-game with touch timing
	var container := Control.new()
	container.name = "TouchRhythmMinigame"
	container.set_anchors_preset(PRESET_FULL_RECT)
	parent.add_child(container)
	
	var result := {
		"root": container,
		"hits": 0,
		"goal": goal,
		"current_beat": 0,
		"beats": beats,
		"beat_duration": beat_duration,
		"completed": false
	}
	
	# Beat indicator
	var beat_indicator := ColorRect.new()
	beat_indicator.name = "BeatIndicator"
	beat_indicator.set_anchors_preset(PRESET_CENTER)
	beat_indicator.size = Vector2(200, 200)
	beat_indicator.color = Color(0, 1, 0, 0.3)
	container.add_child(beat_indicator)
	
	# Prompt label
	var label := Label.new()
	label.name = "Prompt"
	label.text = prompt
	label.set_anchors_preset(PRESET_CENTER_TOP)
	label.position.y = 20
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(label)
	
	# Progress indicator
	var progress := ProgressBar.new()
	progress.name = "Progress"
	progress.set_anchors_preset(PRESET_TOP_WIDE)
	progress.position.y = 50
	progress.size.y = 30
	progress.max_value = goal
	progress.value = 0
	container.add_child(progress)
	
	# Beat timing
	var beat_timer := Timer.new()
	beat_timer.wait_time = beat_duration
	beat_timer.timeout.connect(func():
		result.current_beat += 1
		
		# Visual beat pulse
		var tw := create_tween()
		tw.tween_property(beat_indicator, "scale", Vector2(1.2, 1.2), beat_duration * 0.3)
		tw.tween_property(beat_indicator, "scale", Vector2.ONE, beat_duration * 0.7)
		
		if result.current_beat >= beats:
			beat_timer.stop()
			if not result.completed:
				on_minigame_timeout(result)
	)
	container.add_child(beat_timer)
	beat_timer.start()
	
	# Touch input handling
	container.gui_input.connect(func(event: InputEvent):
		if event is InputEventScreenTouch and event.pressed and result.current_beat < beats:
			var timing_accuracy = abs(fmod(Time.get_time_since_startup(), beat_duration) - beat_duration * 0.5)
			if timing_accuracy < beat_duration * 0.3:  # Good timing window
				result.hits += 1
				progress.value = result.hits
				
				# Success feedback
				var feedback := ColorRect.new()
				feedback.size = Vector2(50, 50)
				feedback.position = event.position - Vector2(25, 25)
				feedback.color = Color(0, 1, 0, 0.8)
				container.add_child(feedback)
				
				var tw := create_tween()
				tw.tween_property(feedback, "modulate:a", 0.0, 0.5)
				tw.tween_callback(feedback.queue_free)
				
				# Check completion
				if result.hits >= goal:
					result.completed = true
					beat_timer.stop()
					on_minigame_complete(result)
			else:
				# Miss feedback
				var feedback := ColorRect.new()
				feedback.size = Vector2(30, 30)
				feedback.position = event.position - Vector2(15, 15)
				feedback.color = Color(1, 0, 0, 0.6)
				container.add_child(feedback)
				
				var tw := create_tween()
				tw.tween_property(feedback, "modulate:a", 0.0, 0.3)
				tw.tween_callback(feedback.queue_free)
	)
	
	return result
