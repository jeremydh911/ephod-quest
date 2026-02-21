extends Node3D

# =============================================================================
# OpeningScene.gd  –  Twelve Stones / Ephod Quest
# =============================================================================
# Cinematic 3D opening: Dawn breaks over the Morning Cliffs of Reuben.
# Miriam (age 17, first avatar of Reuben) stands on a cliff ledge looking
# east as the sun rises. Camera slowly pans in. She turns to face you.
# A verse fades in. Then the scene transitions → AnimatedLogo → MainMenu.
#
# All geometry is procedural — no external assets required.
# Run time: ~16 seconds (skippable with tap / Space / Enter).
#
# "He makes the dawn and the darkness." — Amos 4:13
# =============================================================================

const _NEXT_SCENE := "res://scenes/AnimatedLogo.tscn"

# ── colour palette (Morning Cliffs, warm dawn) ────────────────────────────────
const C_SKY_TOP := Color(0.18, 0.22, 0.42, 1) # deep indigo night fading
const C_SKY_MID := Color(0.82, 0.45, 0.18, 1) # amber sunrise band
const C_SKY_HORIZ := Color(0.98, 0.82, 0.50, 1) # bright horizon gold
const C_CLIFF := Color(0.54, 0.44, 0.32, 1) # sandstone
const C_GRASS := Color(0.38, 0.54, 0.26, 1) # sage green
const C_GROUND := Color(0.46, 0.38, 0.24, 1) # dry earth
const C_SKIN := Color(0.80, 0.62, 0.44, 1) # Miriam – warm olive
const C_ROBE := Color(0.72, 0.54, 0.32, 1) # tan/camel cloth
const C_HEAD_WRAP := Color(0.38, 0.28, 0.18, 1) # dark linen wrap
const C_HAIR := Color(0.16, 0.10, 0.06, 1) # deep brown
const C_SUN := Color(1.00, 0.90, 0.50, 1) # warm sun disc

# ── scene nodes ───────────────────────────────────────────────────────────────
var _camera: Camera3D
var _miriam: Node3D # character rig
var _sun_disc: MeshInstance3D
var _sky_quad: MeshInstance3D
var _ui_layer: CanvasLayer
var _verse_label: Label
var _skip_label: Label
var _fade_rect: ColorRect

# ── state ─────────────────────────────────────────────────────────────────────
var _going := false # prevents double-trigger on skip
var _skip_ok := false # allow skip after 0.5 s


# =============================================================================
# ENTRY
# =============================================================================
func _ready() -> void:
	set_process_input(true)

	_build_sky()
	_build_terrain()
	_build_sun()
	_build_character()
	_build_lighting()
	_build_camera()
	_build_ui()

	# Slight delay so the scene is fully instantiated before tweening
	await get_tree().create_timer(0.1).timeout
	_run_cinematic()


# =============================================================================
# INPUT  (skip)
# =============================================================================
func _input(event: InputEvent) -> void:
	if not _skip_ok:
		return
	var pressed: bool = (event is InputEventKey and (event as InputEventKey).pressed) \
	or (event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed) \
	or event.is_action_pressed("ui_accept")
	if pressed:
		_transition_now()

# =============================================================================
# WORLD BUILDING
# =============================================================================


# ── Sky ───────────────────────────────────────────────────────────────────────
func _build_sky() -> void:
	# Large quad far behind everything, gradient tinted by a WorldEnvironment
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = C_SKY_MID
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.90, 0.80, 0.60, 1)
	env.ambient_light_energy = 0.6
	env_node.environment = env
	add_child(env_node)

	# Sky gradient quad — wide plane standing vertically
	var sky := MeshInstance3D.new()
	var plane := QuadMesh.new()
	plane.size = Vector2(120, 50)
	sky.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = C_SKY_HORIZ
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = false
	sky.material_override = mat
	sky.position = Vector3(0, 12, -28)
	_sky_quad = sky
	add_child(sky)


# ── Terrain ───────────────────────────────────────────────────────────────────
func _build_terrain() -> void:
	# Main ground plane
	_add_box(Vector3(0, -0.5, 0), Vector3(80, 1, 60), C_GROUND, 0)
	# Cliff ledge where Miriam stands
	_add_box(Vector3(-8, 2, -4), Vector3(16, 4, 10), C_CLIFF, 0)
	_add_box(Vector3(-8, 4.1, -4), Vector3(16, 0.2, 10), C_GRASS, 0) # grass top
	# Larger plateau behind
	_add_box(Vector3(-8, 1, -18), Vector3(20, 2, 18), C_CLIFF, 0)
	_add_box(Vector3(-8, 2.1, -18), Vector3(20, 0.2, 18), C_GRASS, 0)
	# Rock outcrops
	_add_box(Vector3(6, 0.8, -6), Vector3(3, 1.6, 3), C_CLIFF, 15)
	_add_box(Vector3(-16, 0.6, -2), Vector3(2, 1.2, 2), C_CLIFF, -10)
	_add_box(Vector3(10, 0.5, 4), Vector3(4, 1.0, 3), C_CLIFF, 8)
	# Far background hills
	_add_box(Vector3(28, 3, -22), Vector3(18, 8, 12), C(0.50, 0.42, 0.30), 0)
	_add_box(Vector3(-26, 2, -20), Vector3(14, 5, 10), C(0.48, 0.40, 0.28), 0)
	# Sparse vegetation blobs (olive-green dot masses)
	for i in range(8):
		var px := randf_range(-20, 20)
		var pz := randf_range(2, 14)
		_add_sphere(
			Vector3(px, 0.8, pz),
			0.8 + randf_range(0, 0.6),
			C(0.30 + randf_range(0, 0.12), 0.44 + randf_range(0, 0.1), 0.20),
		)


# ── Sun disc ──────────────────────────────────────────────────────────────────
func _build_sun() -> void:
	var sun := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.8
	sphere.height = 3.6
	sun.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = C_SUN
	mat.emission_enabled = true
	mat.emission = C_SUN * 1.6
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sun.material_override = mat
	sun.position = Vector3(8, 7, -24)
	_sun_disc = sun
	add_child(sun)


# ── Character (Miriam of Reuben, age 17) ─────────────────────────────────────
# "She is clothed with strength and dignity" – Proverbs 31:25
func _build_character() -> void:
	_miriam = Node3D.new()
	_miriam.name = "Miriam"
	# Start position: on the cliff ledge, slightly left, facing east (–Z)
	_miriam.position = Vector3(-9, 4.55, -5)
	_miriam.rotation_degrees = Vector3(0, 160, 0) # facing roughly toward sun
	add_child(_miriam)

	# ── Legs ────────────────────────────────────────────────────────────────
	_char_box(_miriam, Vector3(-0.13, 0.55, 0), Vector3(0.22, 1.1, 0.20), C_ROBE)
	_char_box(_miriam, Vector3(0.13, 0.55, 0), Vector3(0.22, 1.1, 0.20), C_ROBE)

	# ── Lower robe skirt ────────────────────────────────────────────────────
	_char_box(_miriam, Vector3(0, 0.55, 0), Vector3(0.50, 1.1, 0.30), C_ROBE)

	# ── Body torso ──────────────────────────────────────────────────────────
	_char_box(_miriam, Vector3(0, 1.55, 0), Vector3(0.50, 1.0, 0.28), C_ROBE)

	# ── Upper robe / mantle ─────────────────────────────────────────────────
	_char_box(
		_miriam,
		Vector3(0, 1.80, 0),
		Vector3(0.60, 0.65, 0.32),
		C(0.62, 0.46, 0.28),
	)

	# ── Arms ────────────────────────────────────────────────────────────────
	_char_box(_miriam, Vector3(-0.38, 1.55, 0), Vector3(0.18, 0.88, 0.18), C_ROBE)
	_char_box(_miriam, Vector3(0.38, 1.55, 0), Vector3(0.18, 0.88, 0.18), C_ROBE)

	# ── Hands ───────────────────────────────────────────────────────────────
	_char_sphere(_miriam, Vector3(-0.38, 1.08, 0), 0.10, C_SKIN)
	_char_sphere(_miriam, Vector3(0.38, 1.08, 0), 0.10, C_SKIN)

	# ── Neck ────────────────────────────────────────────────────────────────
	_char_box(_miriam, Vector3(0, 2.14, 0), Vector3(0.16, 0.20, 0.16), C_SKIN)

	# ── Head ────────────────────────────────────────────────────────────────
	_char_sphere(_miriam, Vector3(0, 2.58, 0), 0.28, C_SKIN)

	# ── Hair (back, dark brown) ──────────────────────────────────────────────
	_char_sphere(_miriam, Vector3(0, 2.62, 0.08), 0.24, C_HAIR)

	# ── Head wrap (linen, dark) ──────────────────────────────────────────────
	_char_box(_miriam, Vector3(0, 2.72, 0), Vector3(0.60, 0.22, 0.52), C_HEAD_WRAP)
	_char_box(_miriam, Vector3(0, 2.58, 0.22), Vector3(0.56, 0.40, 0.12), C_HEAD_WRAP)
	# Drape over shoulder
	_char_box(
		_miriam,
		Vector3(-0.24, 2.20, 0.10),
		Vector3(0.16, 0.50, 0.12),
		C_HEAD_WRAP,
	)

	# ── Face features (simple) ───────────────────────────────────────────────
	# Eyes
	_char_sphere(_miriam, Vector3(-0.09, 2.60, -0.25), 0.044, Color(0.12, 0.08, 0.04))
	_char_sphere(_miriam, Vector3(0.09, 2.60, -0.25), 0.044, Color(0.12, 0.08, 0.04))
	# Mouth (small dark line)
	_char_box(
		_miriam,
		Vector3(0, 2.50, -0.26),
		Vector3(0.10, 0.025, 0.02),
		Color(0.55, 0.28, 0.22),
	)


# ── Lighting ──────────────────────────────────────────────────────────────────
func _build_lighting() -> void:
	# Main directional "sun" — low angle, warm gold-orange (sunrise)
	var dir_light := DirectionalLight3D.new()
	dir_light.rotation_degrees = Vector3(-18, 45, 0)
	dir_light.light_color = Color(1.0, 0.85, 0.60)
	dir_light.light_energy = 1.2
	dir_light.shadow_enabled = true
	add_child(dir_light)

	# Soft fill from the other side (sky bounce)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-40, -120, 0)
	fill.light_color = Color(0.60, 0.70, 0.90)
	fill.light_energy = 0.35
	fill.shadow_enabled = false
	add_child(fill)


# ── Camera ────────────────────────────────────────────────────────────────────
func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.fov = 55
	# Start far back + high — like a sweeping establishing shot
	_camera.position = Vector3(12, 8, 22)
	_camera.rotation_degrees = Vector3(-14, -28, 0)
	add_child(_camera)
	_camera.make_current()


# =============================================================================
# UI  (verse + skip hint + fade rect)
# =============================================================================
func _build_ui() -> void:
	_ui_layer = CanvasLayer.new()
	add_child(_ui_layer)

	# Fade rect (black)
	_fade_rect = ColorRect.new()
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.color = Color(0, 0, 0, 1)
	_fade_rect.z_index = 10
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(_fade_rect)

	# Verse label — bottom third
	_verse_label = Label.new()
	_verse_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_verse_label.anchor_top = 0.65
	_verse_label.offset_left = 60
	_verse_label.offset_right = -60
	_verse_label.offset_top = 0
	_verse_label.offset_bottom = -60
	_verse_label.text = "\"He makes the dawn and the darkness.\"\n— Amos 4:13"
	_verse_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_verse_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_verse_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_verse_label.modulate = Color(1, 1, 1, 0) # start invisible
	_verse_label.add_theme_font_size_override("font_size", 28)
	_verse_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.80))
	_verse_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	_verse_label.add_theme_constant_override("shadow_offset_x", 2)
	_verse_label.add_theme_constant_override("shadow_offset_y", 2)
	_ui_layer.add_child(_verse_label)

	# Character name bubble — lower-left
	var name_bg := ColorRect.new()
	name_bg.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	name_bg.anchor_top = 1.0
	name_bg.anchor_bottom = 1.0
	name_bg.offset_left = 40
	name_bg.offset_top = -110
	name_bg.offset_right = 280
	name_bg.offset_bottom = -70
	name_bg.color = Color(0, 0, 0, 0.55)
	name_bg.modulate = Color(1, 1, 1, 0)
	_ui_layer.add_child(name_bg)

	var name_label := Label.new()
	name_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	name_label.text = "Miriam  ·  Tribe of Reuben"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(0.98, 0.88, 0.64))
	name_bg.add_child(name_label)

	# Skip label
	_skip_label = Label.new()
	_skip_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_skip_label.anchor_left = 1.0
	_skip_label.offset_left = -200
	_skip_label.offset_top = 20
	_skip_label.offset_right = -20
	_skip_label.offset_bottom = 50
	_skip_label.text = "Tap to skip"
	_skip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_skip_label.add_theme_font_size_override("font_size", 16)
	_skip_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	_skip_label.modulate = Color(1, 1, 1, 0)
	_ui_layer.add_child(_skip_label)

	# Store name_bg reference for animation
	_miriam.set_meta("name_bg", name_bg)


# =============================================================================
# CINEMATIC SEQUENCE
# =============================================================================
func _run_cinematic() -> void:
	# ── Beat 0: fade up from black (1.5 s) ────────────────────────────────────
	var t := create_tween()
	t.tween_property(_fade_rect, "color", Color(0, 0, 0, 0), 1.5)
	await t.finished

	_skip_ok = true
	_show_skip_hint()

	# ── Beat 1: slow camera push-in toward Miriam (5 s) ───────────────────────
	# From establishing shot → intimate medium shot
	var cam_tween := create_tween()
	cam_tween.set_ease(Tween.EASE_IN_OUT)
	cam_tween.set_trans(Tween.TRANS_SINE)
	cam_tween.tween_property(_camera, "position", Vector3(2, 6.4, 8), 5.0)
	cam_tween.parallel().tween_property(
		_camera,
		"rotation_degrees",
		Vector3(-12, -8, 0),
		5.0,
	)

	# ── Beat 1b: sun rises (same 5 s) ─────────────────────────────────────────
	var sun_tween := create_tween()
	sun_tween.tween_property(_sun_disc, "position", Vector3(8, 12, -24), 5.0)
	# Sky brightens
	var sky_tween := create_tween()
	sky_tween.tween_property(
		_sky_quad,
		"material_override:albedo_color",
		Color(1.0, 0.95, 0.80),
		5.0,
	)

	await cam_tween.finished

	# ── Beat 2: Miriam turns to face camera (gentle 1.2 s) ───────────────────
	var turn := create_tween()
	turn.set_ease(Tween.EASE_IN_OUT)
	turn.set_trans(Tween.TRANS_QUAD)
	turn.tween_property(_miriam, "rotation_degrees", Vector3(0, -20, 0), 1.2)
	await turn.finished

	# Show character name plate
	var name_bg = _miriam.get_meta("name_bg")
	var nb_t := create_tween()
	nb_t.tween_property(name_bg, "modulate", Color(1, 1, 1, 1), 0.6)
	await nb_t.finished

	await get_tree().create_timer(1.2).timeout

	# ── Beat 3: camera drifts to wide shot again (3 s) ───────────────────────
	var wide := create_tween()
	wide.set_ease(Tween.EASE_IN_OUT)
	wide.set_trans(Tween.TRANS_SINE)
	wide.tween_property(_camera, "position", Vector3(-2, 7, 12), 3.0)
	wide.parallel().tween_property(
		_camera,
		"rotation_degrees",
		Vector3(-18, 5, 0),
		3.0,
	)
	await wide.finished

	# ── Beat 4: verse text fades in (1.5 s) ──────────────────────────────────
	var vt := create_tween()
	vt.tween_property(_verse_label, "modulate", Color(1, 1, 1, 1), 1.5)
	await vt.finished

	await get_tree().create_timer(2.8).timeout

	# ── Beat 5: fade to black, then transition ────────────────────────────────
	_transition_now()


# =============================================================================
# INTERNAL
# =============================================================================
func _show_skip_hint() -> void:
	var t := create_tween()
	t.tween_property(_skip_label, "modulate", Color(1, 1, 1, 0.55), 0.8)
	await t.finished
	await get_tree().create_timer(2.0).timeout
	var t2 := create_tween()
	t2.tween_property(_skip_label, "modulate", Color(1, 1, 1, 0), 1.2)


func _transition_now() -> void:
	if _going:
		return
	_going = true
	_skip_ok = false
	var t := create_tween()
	t.tween_property(_fade_rect, "color", Color(0, 0, 0, 1), 0.9)
	await t.finished
	get_tree().change_scene_to_file(_NEXT_SCENE)


# =============================================================================
# HELPERS — procedural geometry
# =============================================================================
func _add_box(pos: Vector3, size: Vector3, color: Color, rot_y: float = 0) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	m.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	m.material_override = mat
	m.position = pos
	if rot_y != 0:
		m.rotation_degrees.y = rot_y
	add_child(m)
	return m


func _add_sphere(pos: Vector3, r: float, color: Color) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	m.mesh = sm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	m.material_override = mat
	m.position = pos
	add_child(m)
	return m


func _char_box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	m.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	m.material_override = mat
	m.position = pos
	parent.add_child(m)
	return m


func _char_sphere(parent: Node3D, pos: Vector3, r: float, color: Color) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	m.mesh = sm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	m.material_override = mat
	m.position = pos
	parent.add_child(m)
	return m


# Shorthand colour constructor (avoids repetitive Color() literals)
static func C(r: float, g: float, b: float, a: float = 1.0) -> Color:
	return Color(r, g, b, a)
