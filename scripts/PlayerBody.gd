extends CharacterBody3D

# ─────────────────────────────────────────────────────────────────────────────
# PlayerBody.gd  –  Twelve Stones / Ephod Quest
# Top-down adventure player controller.  Used by all 12 World scenes.
# Visual is built by Character.gd (procedural 3D cartoon body).
#
# Signals:
#   interaction_requested  – player pressed interact button
#   interactable_entered   – NPC/Chest Area3D overlaps
#   interactable_exited    – NPC/Chest Area3D left
#
# "He guides me along the right paths for his name's sake" – Psalm 23:3
# ─────────────────────────────────────────────────────────────────────────────

signal interaction_requested
signal interactable_entered(node: Node)
signal interactable_exited(node: Node)

const SPEED: float = 320.0 # world-units per second – gentle Zelda pace

@export var step_sfx: String = "res://assets/audio/sfx/footstep.wav"

var _facing: Vector3 = Vector3.FORWARD
var _is_moving: bool = false
var _step_timer: float = 0.0
var _visual_built: bool = false

# Reference to the Character.gd node (set in _build_visual)
var _character_node: Node3D = null

# Touch direction set by on-screen D-pad (Vector3 XZ plane)
var touch_direction: Vector3 = Vector3.ZERO


# ─────────────────────────────────────────────────────────────────────────────
# INITIALISE  –  build visuals, interaction area, and HUD controls ONCE
# "By him all things were created" – Colossians 1:16
# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_visual()

	# Apply tribe colour tint
	if Global.selected_tribe != "":
		var td := Global.get_tribe_data(Global.selected_tribe)
		if td.has("color"):
			_tint_body(Color(td["color"] as String))

	# ── Interaction detection sphere (Area3D) ────────────────────────────────
	# Guard: only add if not already present (editor-placed or duplicate call)
	if not has_node("InteractArea"):
		var area := Area3D.new()
		area.name = "InteractArea"
		area.monitoring = true
		area.monitorable = false
		var cshp := CollisionShape3D.new()
		var sph := SphereShape3D.new()
		sph.radius = 80.0 # generous Zelda-style pickup radius
		cshp.shape = sph
		area.add_child(cshp)
		add_child(area)
		area.area_entered.connect(_on_area_entered)
		area.area_exited.connect(_on_area_exited)

	# ── On-screen controls (D-pad + interact button) ─────────────────────────
	if not has_node("HUDControls"):
		_add_hud_controls()


# ─────────────────────────────────────────────────────────────────────────────
# VISUAL — procedural cartoon avatar built by Character.gd
# "I am fearfully and wonderfully made" — Psalm 139:14
# ─────────────────────────────────────────────────────────────────────────────
func _build_visual() -> void:
	if _visual_built:
		return
	_visual_built = true

	# ── Resolve tribe / avatar data ──────────────────────────────────────────
	var td: Dictionary = {}
	if Global.selected_tribe != "":
		td = Global.get_tribe_data(Global.selected_tribe)

	# ── Build Character.gd node ───────────────────────────────────────────────
	# Character is a Node3D that builds its own mesh hierarchy in _ready().
	# Set all properties BEFORE add_child so _ready() gets the right values.
	var char_node: Node3D = load("res://scripts/Character.gd").new()
	char_node.name = "CharacterVisual"
	char_node.tribe_key   = Global.selected_tribe if Global.selected_tribe != "" else "reuben"
	char_node.role        = "avatar"

	# Pull avatar metadata for age/skin/hair if available
	var av_key: String = Global.selected_avatar
	if av_key != "" and Global.AVATARS.has(Global.selected_tribe):
		for av in Global.AVATARS[Global.selected_tribe]:
			if (av as Dictionary).get("key", "") == av_key:
				char_node.age = (av as Dictionary).get("age", 17) as int
				var skin_str: String = (av as Dictionary).get("skin", "medium") as String
				# Map descriptive skin strings to Character.gd skin_tone keys
				if "light" in skin_str or "fair" in skin_str or "pale" in skin_str:
					char_node.skin_tone = "light"
				elif "dark" in skin_str or "deep" in skin_str or "mahogany" in skin_str:
					char_node.skin_tone = "dark"
				else:
					char_node.skin_tone = "medium"
				break

	# Scale up from Character.gd's unit scale (≈1.6m) to match world units
	# WorldBase uses ~3200 unit play area; players are ~30 units tall ≈ 1/100 scale
	char_node.scale = Vector3.ONE * 18.0

	# Sit at ground level (Character.gd root is at foot level)
	char_node.position = Vector3.ZERO

	add_child(char_node)
	_character_node = char_node

	# ── Tribe glow ring under feet ────────────────────────────────────────────
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 10.0
	ring_mesh.outer_radius = 16.0
	var ring_mat := StandardMaterial3D.new()
	var ring_col: Color = Color(1.0, 0.85, 0.2)
	if td.has("color"):
		ring_col = Color(td["color"] as String)
	ring_mat.albedo_color     = ring_col
	ring_mat.emission_enabled = true
	ring_mat.emission         = ring_col * 0.6
	ring_mesh.surface_set_material(0, ring_mat)
	var ring := MeshInstance3D.new()
	ring.name     = "TribeRing"
	ring.mesh     = ring_mesh
	ring.position = Vector3(0.0, 1.5, 0.0)
	add_child(ring)

	# ── Floating name label ───────────────────────────────────────────────────
	var label := Label3D.new()
	label.name      = "NameLabel"
	label.text      = Global.selected_avatar if Global.selected_avatar != "" else "You"
	label.font_size = 18
	label.position  = Vector3(0.0, 52.0, 0.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)


# Tint the tribe ring to the tribe colour.
# Character.gd manages its own robe color via tribe_key — nothing to override here.
func _tint_body(c: Color) -> void:
	var ring := get_node_or_null("TribeRing") as MeshInstance3D
	if ring and ring.mesh != null and ring.mesh.get_surface_count() > 0:
		var mat := ring.mesh.surface_get_material(0) as StandardMaterial3D
		if mat:
			mat.albedo_color = c
			mat.emission     = c * 0.5


# Legacy public API kept for backward-compat (called by some quest scripts)
func set_touch_direction(dir: Vector2) -> void:
	touch_direction = Vector3(dir.x, 0.0, dir.y)


# ─────────────────────────────────────────────────────────────────────────────
# MOVEMENT   –  WASD / arrow keys + touch D-pad
# "He makes my feet like the feet of a deer" – Habakkuk 3:19
# ─────────────────────────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	# Keyboard / gamepad
	var dir := Vector3(
		Input.get_axis("move_left", "move_right"),
		0.0,
		Input.get_axis("move_up", "move_down"),
	)
	# Fall back to touch D-pad
	if dir.length_squared() < 0.01:
		dir = touch_direction

	if dir.length_squared() > 0.01:
		dir = dir.normalized()
		velocity.x = dir.x * SPEED
		velocity.z = dir.z * SPEED
		_facing = dir
		_is_moving = true
		_update_facing(dir)
		# Footstep SFX throttled
		_step_timer -= delta
		if _step_timer <= 0.0:
			_step_timer = 0.38
			AudioManager.sfx("footstep")
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 2.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, SPEED * 2.0 * delta)
		_is_moving = false
		_step_timer = 0.0

	# Apply gravity so the capsule stays on terrain colliders
	if not is_on_floor():
		velocity.y -= 9.8 * delta * 20.0

	move_and_slide()


# Rotate Character visual to face movement direction
func _update_facing(dir: Vector3) -> void:
	if _character_node != null and dir.length_squared() > 0.01:
		var angle := atan2(dir.x, dir.z)
		_character_node.rotation.y = angle


# ─────────────────────────────────────────────────────────────────────────────
# INPUT – keyboard / gamepad interact
# ─────────────────────────────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		interaction_requested.emit()
		get_viewport().set_input_as_handled()


# ─────────────────────────────────────────────────────────────────────────────
# INTERACTION AREA CALLBACKS  (Area3D signals)
# ─────────────────────────────────────────────────────────────────────────────
func _on_area_entered(area: Area3D) -> void:
	var target: Node = area if area.has_method("on_interact") else null
	if target == null and area.get_parent() != null:
		target = area.get_parent() if area.get_parent().has_method("on_interact") else null
	if target:
		interactable_entered.emit(target)


func _on_area_exited(area: Area3D) -> void:
	var target: Node = area if area.has_method("on_interact") else null
	if target == null and area.get_parent() != null:
		target = area.get_parent() if area.get_parent().has_method("on_interact") else null
	if target:
		interactable_exited.emit(target)


# ─────────────────────────────────────────────────────────────────────────────
# HUD CONTROLS  –  D-pad (bottom-left) + Interact button (bottom-right)
# "Let everything be done decently and in order." – 1 Corinthians 14:40
# ─────────────────────────────────────────────────────────────────────────────
func _add_hud_controls() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUDControls"
	layer.layer = 11
	add_child(layer)

	# ── Interact button ──────────────────────────────────────────────────────
	var btn := Button.new()
	btn.text = "✦"
	btn.add_theme_font_size_override("font_size", 28)
	btn.custom_minimum_size = Vector2(72, 72)
	btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	btn.offset_left = -90.0
	btn.offset_right = -18.0
	btn.offset_top = -90.0
	btn.offset_bottom = -18.0
	btn.pressed.connect(func(): interaction_requested.emit())
	layer.add_child(btn)

	# ── D-pad container ──────────────────────────────────────────────────────
	var dpad := Control.new()
	dpad.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	dpad.offset_left = 12.0
	dpad.offset_right = 208.0
	dpad.offset_top = -208.0
	dpad.offset_bottom = -12.0
	layer.add_child(dpad)

	# Arrow layout: [label, Vector3 dir,  x,   y]
	var dir_map: Array = [
		["▲", Vector3(0, 0, -1), 72.0, 0.0],
		["▼", Vector3(0, 0, 1), 72.0, 144.0],
		["◄", Vector3(-1, 0, 0), 0.0, 72.0],
		["►", Vector3(1, 0, 0), 144.0, 72.0],
	]
	for dd in dir_map:
		var b := Button.new()
		b.text = dd[0] as String
		b.add_theme_font_size_override("font_size", 20)
		b.custom_minimum_size = Vector2(56, 56)
		b.position = Vector2(dd[2] as float, dd[3] as float)
		var dv3: Vector3 = dd[1] as Vector3
		b.button_down.connect(func(): touch_direction = dv3)
		b.button_up.connect(
			func():
				if touch_direction == dv3:
					touch_direction = Vector3.ZERO
		)
		dpad.add_child(b)
