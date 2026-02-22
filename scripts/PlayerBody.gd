extends CharacterBody3D
# ─────────────────────────────────────────────────────────────────────────────
# PlayerBody.gd  –  Twelve Stones / Ephod Quest
# Top-down adventure player controller.  Used by all 12 World scenes.
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

const SPEED: float = 320.0         # world-units per second – gentle Zelda pace

@export var step_sfx: String = "res://assets/audio/sfx/footstep.wav"

var _facing: Vector3 = Vector3.FORWARD
var _is_moving: bool = false
var _step_timer: float = 0.0
var _visual_built: bool = false

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
		area.name        = "InteractArea"
		area.monitoring  = true
		area.monitorable = false
		var cshp := CollisionShape3D.new()
		var sph  := SphereShape3D.new()
		sph.radius = 80.0      # generous Zelda-style pickup radius
		cshp.shape = sph
		area.add_child(cshp)
		add_child(area)
		area.area_entered.connect(_on_area_entered)
		area.area_exited.connect(_on_area_exited)

	# ── On-screen controls (D-pad + interact button) ─────────────────────────
	if not has_node("HUDControls"):
		_add_hud_controls()

# ─────────────────────────────────────────────────────────────────────────────
# VISUAL — procedural player avatar visible from overhead camera
# ─────────────────────────────────────────────────────────────────────────────
func _build_visual() -> void:
	if _visual_built:
		return
	_visual_built = true

	# Body capsule (visible coloured cylinder, Y=0 at feet, sits on ground)
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 12.0
	body_mesh.height = 30.0
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.82, 0.65, 0.45)   # warm skin tone
	body_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	body_mesh.surface_set_material(0, body_mat)
	var body := MeshInstance3D.new()
	body.name = "BodyMesh"
	body.mesh = body_mesh
	body.position = Vector3(0, 15, 0)     # centre at waist height
	add_child(body)

	# Head sphere (slightly lighter)
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 8.0
	head_mesh.height = 16.0
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.88, 0.72, 0.52)
	head_mesh.surface_set_material(0, head_mat)
	var head := MeshInstance3D.new()
	head.name = "HeadMesh"
	head.mesh = head_mesh
	head.position = Vector3(0, 34, 0)
	add_child(head)

	# Tribe colour ring under feet (glows tribe colour)
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 10.0
	ring_mesh.outer_radius = 16.0
	var ring_mat := StandardMaterial3D.new()
	ring_mat.albedo_color    = Color(1.0, 0.85, 0.2, 0.9)   # gold default; overridden by tribe
	ring_mat.emission_enabled = true
	ring_mat.emission         = Color(1.0, 0.85, 0.2) * 0.6
	ring_mesh.surface_set_material(0, ring_mat)
	var ring := MeshInstance3D.new()
	ring.name     = "TribeRing"
	ring.mesh     = ring_mesh
	ring.position = Vector3(0, 1.5, 0)    # just above ground
	add_child(ring)

	# Name label floating overhead
	var label := Label3D.new()
	label.name      = "NameLabel"
	label.text      = Global.selected_avatar if Global.selected_avatar != "" else "You"
	label.font_size = 18
	label.position  = Vector3(0, 52, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)

# Tint the tribe ring and body to tribe colour
func _tint_body(c: Color) -> void:
	for child in get_children():
		if child is MeshInstance3D:
			var m: Mesh = (child as MeshInstance3D).mesh
			if m != null and m.get_surface_count() > 0:
				var mat: Material = m.surface_get_material(0)
				if mat is StandardMaterial3D:
					if child.name == "TribeRing":
						(mat as StandardMaterial3D).albedo_color = c
						(mat as StandardMaterial3D).emission      = c * 0.5
					# Do NOT recolour body/head — keep natural skin tone

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
		Input.get_axis("move_up",   "move_down")
	)
	# Fall back to touch D-pad
	if dir.length_squared() < 0.01:
		dir = touch_direction

	if dir.length_squared() > 0.01:
		dir = dir.normalized()
		velocity.x = dir.x * SPEED
		velocity.z = dir.z * SPEED
		_facing    = dir
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
		_is_moving  = false
		_step_timer = 0.0

	# Apply gravity so the capsule stays on terrain colliders
	if not is_on_floor():
		velocity.y -= 9.8 * delta * 20.0

	move_and_slide()

# Rotate body mesh to face movement direction
func _update_facing(dir: Vector3) -> void:
	var body := get_node_or_null("BodyMesh") as MeshInstance3D
	if body and dir.length_squared() > 0.01:
		var angle := atan2(dir.x, dir.z)
		body.rotation.y = angle
		var head := get_node_or_null("HeadMesh") as MeshInstance3D
		if head:
			head.rotation.y = angle

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
	layer.name  = "HUDControls"
	layer.layer = 11
	add_child(layer)

	# ── Interact button ──────────────────────────────────────────────────────
	var btn := Button.new()
	btn.text = "✦"
	btn.add_theme_font_size_override("font_size", 28)
	btn.custom_minimum_size = Vector2(72, 72)
	btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	btn.offset_left   = -90.0
	btn.offset_right  = -18.0
	btn.offset_top    = -90.0
	btn.offset_bottom = -18.0
	btn.pressed.connect(func(): interaction_requested.emit())
	layer.add_child(btn)

	# ── D-pad container ──────────────────────────────────────────────────────
	var dpad := Control.new()
	dpad.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	dpad.offset_left   =  12.0
	dpad.offset_right  = 208.0
	dpad.offset_top    = -208.0
	dpad.offset_bottom = -12.0
	layer.add_child(dpad)

	# Arrow layout: [label, Vector3 dir,  x,   y]
	var dir_map: Array = [
		["▲", Vector3( 0, 0, -1),  72.0,   0.0],
		["▼", Vector3( 0, 0,  1),  72.0, 144.0],
		["◄", Vector3(-1, 0,  0),   0.0,  72.0],
		["►", Vector3( 1, 0,  0), 144.0,  72.0],
	]
	for dd in dir_map:
		var b := Button.new()
		b.text = dd[0] as String
		b.add_theme_font_size_override("font_size", 20)
		b.custom_minimum_size = Vector2(56, 56)
		b.position = Vector2(dd[2] as float, dd[3] as float)
		var dv3: Vector3 = dd[1] as Vector3
		b.button_down.connect(func(): touch_direction = dv3)
		b.button_up.connect(func():
			if touch_direction == dv3:
				touch_direction = Vector3.ZERO
		)
		dpad.add_child(b)


signal interaction_requested
signal interactable_entered(node: Node)
signal interactable_exited(node: Node)

const SPEED: float = 180.0   # pixels per second – gentle pace

# Visual layers
@export var step_sfx: String = "res://assets/audio/sfx/footstep.wav"

# Facing direction for sprite flip
var _facing: Vector3 = Vector3.FORWARD
var _is_moving: bool = false
var _step_timer: float = 0.0   # seconds until next footstep sound

# Touch direction injected by on-screen controls
var touch_direction: Vector3 = Vector3.ZERO

func set_touch_direction(dir: Vector2) -> void:
	touch_direction = Vector3(dir.x, 0, dir.y)
	# Build visible player body first, then tint with tribe colour
	_build_visual()

	if Global.selected_tribe != "":
		var td := Global.get_tribe_data(Global.selected_tribe)
		if td.has("color"):
			_tint_sprite(Color(td["color"] as String))

	# Interaction detection area (Area3D around player)
	var area := Area3D.new()
	area.name = "InteractArea"
	var shape := CollisionShape3D.new()
	var cshape := SphereShape3D.new()
	cshape.radius = 52.0
	shape.shape   = cshape
	area.add_child(shape)
	area.monitoring = true
	area.monitorable = false
	add_child(area)
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)

	# Touch interact button (canvas layer, bottom-right)
	_add_interact_button()

# Build a simple visible character so the player is seen on screen
# "By him all things were created" – Colossians 1:16
func _build_visual() -> void:
	# Player sprite (placeholder rectangle for now)
	var sprite := Sprite3D.new()
	sprite.name       = "PlayerSprite"
	sprite.texture = null  # no texture, use modulate
	sprite.modulate = Color(0.8, 0.6, 0.4, 1)  # skin tone
	sprite.position   = Vector3(-16, -24, 0)
	add_child(sprite)

	# Outer glow circle (tribe colour tinted by _tint_sprite)
	var ring := MeshInstance.new()
	ring.name       = "BodyRing"
	ring.mesh = CylinderMesh.new()
	ring.mesh.top_radius = 18
	ring.mesh.bottom_radius = 18
	ring.mesh.height = 1
	ring.material = StandardMaterial3D.new()
	ring.material.albedo_color = Color(0.9, 0.82, 0.55, 1)   # warm sand; tinted in _tint_sprite
	add_child(ring)

	# Face emoji label (floats above)
	var face := Label3D.new()
	face.name     = "FaceLabel"
	face.text     = "🧒"
	face.font_size = 26
	face.position = Vector3(-13, -38, 0)
	add_child(face)

	# Tribe colour swatch under feet
	var dot := MeshInstance.new()
	dot.name    = "TribeDot"
	dot.mesh = CylinderMesh.new()
	dot.mesh.top_radius = 11
	dot.mesh.bottom_radius = 11
	dot.mesh.height = 5
	dot.material = StandardMaterial3D.new()
	dot.material.albedo_color = Color(0.77, 0.12, 0.22, 0.7)   # overwritten by _tint_sprite
	dot.position = Vector3(0, 10, 0)
	add_child(dot)

func _tint_sprite(c: Color) -> void:
	for child in get_children():
		if child is Sprite3D:
			(child as Sprite3D).modulate = c
		elif child is MeshInstance and child.name == "BodyRing":
			(child as MeshInstance).material.albedo_color = c
		elif child is MeshInstance and child.name == "TribeDot":
			(child as MeshInstance).material.albedo_color = Color(c.r, c.g, c.b, 0.75)

# ─────────────────────────────────────────────────────────────────────────────
# MOVEMENT
# ─────────────────────────────────────────────────────────────────────────────
func _physics_process(_delta: float) -> void:
	var dir := Vector3(
		Input.get_axis("move_left", "move_right"),
		0,
		Input.get_axis("move_up",   "move_down")
	)
	if dir.length_squared() < 0.01:
		dir = touch_direction

	if dir.length_squared() > 0.01:
		dir = dir.normalized()
		velocity = dir * SPEED
		_facing   = dir
		_is_moving = true
		_update_sprite_facing(dir)
		# ── Footstep sound — throttled to one per 0.38 s ──────────────────
		# "He guides me along the right paths for his name's sake" – Psalm 23:3
		_step_timer -= _delta
		if _step_timer <= 0.0:
			_step_timer = 0.38
			AudioManager.sfx("footstep")
	else:
		velocity = velocity.move_toward(Vector3.ZERO, SPEED * 2.0 * _delta)
		_is_moving = false
		_step_timer = 0.0   # reset so next step plays immediately on move

	move_and_slide()

func _update_sprite_facing(dir: Vector2) -> void:
	# Flip horizontal sprite based on left/right facing
	for child in get_children():
		if child is Sprite2D:
			(child as Sprite2D).flip_h = dir.x < -0.1

# ─────────────────────────────────────────────────────────────────────────────
# INPUT – keyboard / gamepad interact
# ─────────────────────────────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		interaction_requested.emit()
		get_viewport().set_input_as_handled()

# ─────────────────────────────────────────────────────────────────────────────
# INTERACTION AREA CALLBACKS
# ─────────────────────────────────────────────────────────────────────────────
func _on_area_entered(area: Area2D) -> void:
	# Only react to parent-node interactables (NPC, Chest etc.)
	if area.has_method("on_interact"):
		interactable_entered.emit(area)
	elif area.get_parent() != null and area.get_parent().has_method("on_interact"):
		interactable_entered.emit(area.get_parent())

func _on_area_exited(area: Area2D) -> void:
	if area.has_method("on_interact"):
		interactable_exited.emit(area)
	elif area.get_parent() != null and area.get_parent().has_method("on_interact"):
		interactable_exited.emit(area.get_parent())

# ─────────────────────────────────────────────────────────────────────────────
# TOUCH INTERACT BUTTON
# ─────────────────────────────────────────────────────────────────────────────
func _add_interact_button() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 11
	add_child(layer)
	var btn := Button.new()
	btn.text = "✦"
	btn.add_theme_font_size_override("font_size", 28)
	btn.custom_minimum_size = Vector2(72, 72)
	btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	btn.offset_left   = -90.0
	btn.offset_right  = -18.0
	btn.offset_top    = -90.0
	btn.offset_bottom = -18.0
	btn.pressed.connect(func(): interaction_requested.emit())
	layer.add_child(btn)

	# Touch D-pad for movement
	var dpad := Control.new()
	dpad.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	dpad.offset_left   =  12.0
	dpad.offset_right  = 196.0
	dpad.offset_top    = -196.0
	dpad.offset_bottom = -12.0
	layer.add_child(dpad)

	const DIR_MAP: Array = [
		["▲", Vector2(0, -1),  72.0,   0.0],
		["▼", Vector2(0,  1),  72.0, 144.0],
		["◄", Vector2(-1, 0),   0.0,  72.0],
		["►", Vector2( 1, 0), 144.0,  72.0],
	]
	for dd in DIR_MAP:
		var b := Button.new()
		b.text = dd[0] as String
		b.add_theme_font_size_override("font_size", 20)
		b.custom_minimum_size = Vector2(52, 52)
		b.position = Vector2(dd[2] as float, dd[3] as float)
		var dir_val: Vector2 = dd[1] as Vector2
		b.button_down.connect(func(): touch_direction = dir_val)
		b.button_up.connect(func():
			if touch_direction == dir_val:
				touch_direction = Vector2.ZERO
		)
		dpad.add_child(b)
