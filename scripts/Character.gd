# ─────────────────────────────────────────────────────────────────────────────
# Character.gd  --  Twelve Stones / Ephod Quest
# Procedural 3D cartoon character. NO sprite sheets required.
# Builds entirely from primitive meshes + Tween-based animations.
# Tribe colour, age scaling, role sizing all applied at runtime.
#
# Usage:
#   var char := Character.new()
#   char.tribe_key = "reuben"
#   char.role      = "avatar"   # "elder" | "npc"
#   char.age       = 17
#   add_child(char)             # _ready() builds everything
#   char.set_state(Character.AnimationState.WALK)
#
# "Before I formed you in the womb I knew you" - Jeremiah 1:5
# ─────────────────────────────────────────────────────────────────────────────

extends Node3D

# ── Tribe data (Exodus 28 ephod order) ──────────────────────────────────────
const TRIBES: Dictionary = {
	"reuben":   {"color": "#8B6F47", "stone": "sardius",    "trait": "firstborn strength"},
	"simeon":   {"color": "#DAA520", "stone": "topaz",      "trait": "zealous justice"},
	"levi":     {"color": "#FFD700", "stone": "carbuncle",  "trait": "priestly service"},
	"judah":    {"color": "#9ACD32", "stone": "emerald",    "trait": "royal leadership"},
	"dan":      {"color": "#1E90FF", "stone": "sapphire",   "trait": "judicial wisdom"},
	"naphtali": {"color": "#8A2BE2", "stone": "diamond",    "trait": "graceful agility"},
	"gad":      {"color": "#32CD32", "stone": "jacinth",    "trait": "warrior courage"},
	"asher":    {"color": "#00CED1", "stone": "agate",      "trait": "blessed abundance"},
	"issachar": {"color": "#9370DB", "stone": "amethyst",   "trait": "learned insight"},
	"zebulun":  {"color": "#FFA500", "stone": "chrysolite", "trait": "mariner fortune"},
	"joseph":   {"color": "#228B22", "stone": "beryl",      "trait": "fruitful blessing"},
	"benjamin": {"color": "#DC143C", "stone": "jasper",     "trait": "raptor swiftness"},
}

# ── Role configs ──────────────────────────────────────────────────────────────
const ROLES: Dictionary = {
	"avatar": {"scale": 1.00, "has_pet": true},
	"elder":  {"scale": 1.20, "has_pet": false},
	"npc":    {"scale": 0.90, "has_pet": false},
}

# ── Animation state machine ──────────────────────────────────────────────────
enum AnimationState {IDLE, WALK, RUN, PRAY, CELEBRATE, POWER_UP}
var current_state: AnimationState = AnimationState.IDLE

# ── Exposed properties (set BEFORE add_child) ────────────────────────────────
var tribe_key: String = "reuben"
var role:      String = "avatar"
var age:       int    = 17
var skin_tone: String = "medium"
var hair_col:  String = "black"
var eye_col:   String = "brown"
var build:     String = "lean"

# ── Procedural mesh nodes (created in _ready) ────────────────────────────────
var _body_root:    Node3D
var _head_mesh:    MeshInstance3D
var _body_mesh:    MeshInstance3D
var _arm_l:        MeshInstance3D
var _arm_r:        MeshInstance3D
var _leg_l:        MeshInstance3D
var _leg_r:        MeshInstance3D
var _glow_light:   OmniLight3D
var _shadow_light: OmniLight3D

# ── Active tweens (stored so they can be killed on state change) ──────────────
var _idle_tween:   Tween
var _walk_tween:   Tween
var _action_tween: Tween
var _glow_tween:   Tween

# ── Materials ────────────────────────────────────────────────────────────────
var _tribe_color: Color = Color.WHITE
var _robe_mat:    StandardMaterial3D
var _skin_mat:    StandardMaterial3D

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_resolve_colors()
	_build_visual()
	_setup_lights()
	_start_idle_anim()

# ─────────────────────────────────────────────────────────────────────────────
# COLOR HELPERS
# ─────────────────────────────────────────────────────────────────────────────
func _resolve_colors() -> void:
	var tribe_data: Dictionary = TRIBES.get(tribe_key, {}) as Dictionary
	var hex: String = tribe_data.get("color", "#8B6F47") as String
	_tribe_color = Color(hex)

	_robe_mat           = StandardMaterial3D.new()
	_robe_mat.albedo_color = _tribe_color
	_robe_mat.roughness    = 0.80

	_skin_mat = StandardMaterial3D.new()
	_skin_mat.roughness = 0.70
	match skin_tone:
		"light": _skin_mat.albedo_color = Color(0.96, 0.82, 0.69)
		"dark":  _skin_mat.albedo_color = Color(0.36, 0.22, 0.13)
		_:       _skin_mat.albedo_color = Color(0.71, 0.52, 0.36)

# ─────────────────────────────────────────────────────────────────────────────
# MESH BUILDERS
# "The LORD God formed a man from the dust of the ground" - Genesis 2:7
# ─────────────────────────────────────────────────────────────────────────────
func _build_visual() -> void:
	_body_root      = Node3D.new()
	_body_root.name = "BodyRoot"
	add_child(_body_root)

	var role_data: Dictionary = ROLES.get(role, ROLES["avatar"]) as Dictionary
	var role_scale: float     = role_data.get("scale", 1.0) as float
	# Younger characters are slightly smaller
	if age < 16:
		role_scale *= 0.88
	_body_root.scale = Vector3.ONE * role_scale

	# -- Head (big cartoon sphere) -------------------------------------------
	_head_mesh               = MeshInstance3D.new()
	var head_s               := SphereMesh.new()
	head_s.radius            = 0.30
	head_s.height            = 0.62
	head_s.radial_segments   = 16
	head_s.rings             = 8
	_head_mesh.mesh          = head_s
	_head_mesh.material_override = _skin_mat
	_head_mesh.position      = Vector3(0, 1.52, 0)
	_body_root.add_child(_head_mesh)

	# Eyes
	_add_eye(Vector3( 0.11, 1.58, 0.26))
	_add_eye(Vector3(-0.11, 1.58, 0.26))

	# -- Body (cylinder robe) ------------------------------------------------
	_body_mesh               = MeshInstance3D.new()
	var body_c               := CylinderMesh.new()
	body_c.top_radius        = 0.22
	body_c.bottom_radius     = 0.27
	body_c.height            = 0.78
	_body_mesh.mesh          = body_c
	_body_mesh.material_override = _robe_mat
	_body_mesh.position      = Vector3(0, 1.00, 0)
	_body_root.add_child(_body_mesh)

	# -- Arms (capsules) -----------------------------------------------------
	_arm_l = _make_limb(Vector3(-0.35, 0.92, 0), Vector3(0, 0, 20))
	_arm_r = _make_limb(Vector3( 0.35, 0.92, 0), Vector3(0, 0,-20))
	_body_root.add_child(_arm_l)
	_body_root.add_child(_arm_r)

	# -- Legs (capsules) -----------------------------------------------------
	_leg_l = _make_limb(Vector3(-0.13, 0.55, 0), Vector3.ZERO)
	_leg_r = _make_limb(Vector3( 0.13, 0.55, 0), Vector3.ZERO)
	_body_root.add_child(_leg_l)
	_body_root.add_child(_leg_r)

func _add_eye(world_pos: Vector3) -> void:
	var eye_node := MeshInstance3D.new()
	var eye_s    := SphereMesh.new()
	eye_s.radius            = 0.055
	eye_s.height            = 0.11
	eye_s.radial_segments   = 8
	eye_s.rings             = 4
	eye_node.mesh           = eye_s
	var mat                 := StandardMaterial3D.new()
	mat.albedo_color        = Color(0.08, 0.06, 0.06)
	eye_node.material_override = mat
	eye_node.position       = world_pos
	_body_root.add_child(eye_node)

func _make_limb(pos: Vector3, rot_deg: Vector3) -> MeshInstance3D:
	var node   := MeshInstance3D.new()
	var cap    := CapsuleMesh.new()
	cap.radius = 0.09
	cap.height = 0.42
	node.mesh  = cap
	node.material_override = _robe_mat
	node.position          = pos
	node.rotation_degrees  = rot_deg
	return node

# ─────────────────────────────────────────────────────────────────────────────
# LIGHTING
# ─────────────────────────────────────────────────────────────────────────────
func _setup_lights() -> void:
	# Tribe-colour glow aura
	_glow_light              = OmniLight3D.new()
	_glow_light.light_color  = _tribe_color
	_glow_light.omni_range   = 1.80
	_glow_light.light_energy = 0.20
	_glow_light.position     = Vector3(0, 0.8, 0)
	add_child(_glow_light)

	# Soft downward shadow accent
	_shadow_light              = OmniLight3D.new()
	_shadow_light.light_color  = Color(0.08, 0.08, 0.12)
	_shadow_light.omni_range   = 1.20
	_shadow_light.light_energy = 0.10
	_shadow_light.position     = Vector3(0, -0.2, 0)
	add_child(_shadow_light)

# ─────────────────────────────────────────────────────────────────────────────
# ANIMATION STATE MACHINE
# ─────────────────────────────────────────────────────────────────────────────
func set_state(new_state: AnimationState) -> void:
	if new_state == current_state:
		return
	current_state = new_state
	_stop_all_tweens()
	match new_state:
		AnimationState.IDLE:      _start_idle_anim()
		AnimationState.WALK:      _start_walk_anim()
		AnimationState.RUN:       _start_run_anim()
		AnimationState.PRAY:      _start_pray_anim()
		AnimationState.CELEBRATE: _start_celebrate_anim()
		AnimationState.POWER_UP:  _start_power_up_anim()

func _stop_all_tweens() -> void:
	if _idle_tween   and _idle_tween.is_valid():   _idle_tween.kill()
	if _walk_tween   and _walk_tween.is_valid():   _walk_tween.kill()
	if _action_tween and _action_tween.is_valid(): _action_tween.kill()
	if _glow_tween   and _glow_tween.is_valid():   _glow_tween.kill()
	if _body_root:
		_body_root.rotation       = Vector3.ZERO
		_body_root.position       = Vector3.ZERO
		_body_root.rotation_degrees.x = 0.0
	if _arm_l: _arm_l.rotation = Vector3.ZERO
	if _arm_r: _arm_r.rotation = Vector3.ZERO

# -- IDLE: gentle breathing bob ----------------------------------------------
# "He gives breath to all living things" - Isaiah 42:5
func _start_idle_anim() -> void:
	if not _body_root:
		return
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(_body_root, "position:y",
		0.06, 1.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_idle_tween.tween_property(_body_root, "position:y",
		0.00, 1.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	# Soft glow pulse
	_glow_tween = create_tween().set_loops()
	_glow_tween.tween_property(_glow_light, "light_energy", 0.35, 1.4)
	_glow_tween.tween_property(_glow_light, "light_energy", 0.15, 1.4)

# -- WALK: body sway + arm swing ---------------------------------------------
# "He will guide you along the paths" - Isaiah 48:17
func _start_walk_anim() -> void:
	if not _body_root:
		return
	_walk_tween = create_tween().set_loops()
	_walk_tween.tween_property(_body_root, "rotation:z",
		 0.12, 0.22).set_trans(Tween.TRANS_SINE)
	_walk_tween.tween_property(_body_root, "rotation:z",
		-0.12, 0.22).set_trans(Tween.TRANS_SINE)
	# Arms swing in opposition
	if _arm_l:
		var at := create_tween().set_loops()
		at.tween_property(_arm_l, "rotation:x",  0.45, 0.22)
		at.tween_property(_arm_l, "rotation:x", -0.45, 0.22)
	if _arm_r:
		var at2 := create_tween().set_loops()
		at2.tween_property(_arm_r, "rotation:x", -0.45, 0.22)
		at2.tween_property(_arm_r, "rotation:x",  0.45, 0.22)

# -- RUN: faster sway + forward lean -----------------------------------------
func _start_run_anim() -> void:
	if not _body_root:
		return
	_body_root.rotation_degrees.x = -14.0
	_walk_tween = create_tween().set_loops()
	_walk_tween.tween_property(_body_root, "rotation:z",
		 0.22, 0.13).set_trans(Tween.TRANS_SINE)
	_walk_tween.tween_property(_body_root, "rotation:z",
		-0.22, 0.13).set_trans(Tween.TRANS_SINE)
	if _arm_l:
		var at := create_tween().set_loops()
		at.tween_property(_arm_l, "rotation:x",  0.70, 0.13)
		at.tween_property(_arm_l, "rotation:x", -0.70, 0.13)
	if _arm_r:
		var at2 := create_tween().set_loops()
		at2.tween_property(_arm_r, "rotation:x", -0.70, 0.13)
		at2.tween_property(_arm_r, "rotation:x",  0.70, 0.13)

# -- PRAY: arms raise + body bow ---------------------------------------------
# "Bow down and pray to the LORD our Maker" - Psalm 95:6
func _start_pray_anim() -> void:
	if not _body_root:
		return
	_action_tween = create_tween()
	_action_tween.tween_property(_body_root, "rotation:x",
		0.35, 0.6).set_ease(Tween.EASE_OUT)
	if _arm_l:
		_action_tween.parallel().tween_property(_arm_l, "rotation:z",
			-1.20, 0.5).set_ease(Tween.EASE_OUT)
	if _arm_r:
		_action_tween.parallel().tween_property(_arm_r, "rotation:z",
			 1.20, 0.5).set_ease(Tween.EASE_OUT)
	if _glow_light:
		_glow_light.light_energy = 0.60

# -- CELEBRATE: bounce + full spin + glow burst ------------------------------
# "Shout for joy to the LORD" - Psalm 100:1
func _start_celebrate_anim() -> void:
	if not _body_root:
		return
	_action_tween = create_tween()
	_action_tween.tween_property(_body_root, "position:y",
		0.60, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_action_tween.tween_property(_body_root, "position:y",
		0.00, 0.28).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_action_tween.parallel().tween_property(_body_root, "rotation:y",
		TAU, 0.55).set_trans(Tween.TRANS_SINE)
	_action_tween.parallel().tween_property(self, "scale",
		Vector3.ONE * 1.28, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_action_tween.tween_property(self, "scale",
		Vector3.ONE, 0.22).set_trans(Tween.TRANS_SINE)
	# Glow burst
	_glow_tween = create_tween()
	_glow_tween.tween_property(_glow_light, "light_energy", 2.2, 0.18)
	_glow_tween.tween_property(_glow_light, "light_energy", 0.20, 0.70)
	# Return to idle after celebration
	_action_tween.tween_callback(func() -> void:
		current_state = AnimationState.IDLE
		_stop_all_tweens()
		_start_idle_anim()
	)

# -- POWER_UP: sustained expanding glow --------------------------------------
func _start_power_up_anim() -> void:
	if not _glow_light:
		return
	_action_tween = create_tween().set_loops()
	_action_tween.tween_property(_glow_light, "omni_range",  3.5, 0.6)
	_action_tween.tween_property(_glow_light, "omni_range",  1.8, 0.6)
	_action_tween.parallel().tween_property(_glow_light, "light_energy", 1.4, 0.6)
	_action_tween.parallel().tween_property(_glow_light, "light_energy", 0.4, 0.6)

# ─────────────────────────────────────────────────────────────────────────────
# PUBLIC API
# ─────────────────────────────────────────────────────────────────────────────
func set_animation(anim_name: String) -> void:
	match anim_name:
		"idle":      set_state(AnimationState.IDLE)
		"walk":      set_state(AnimationState.WALK)
		"run":       set_state(AnimationState.RUN)
		"pray":      set_state(AnimationState.PRAY)
		"celebrate": set_state(AnimationState.CELEBRATE)
		"power_up":  set_state(AnimationState.POWER_UP)

func set_tribe(new_tribe: String) -> void:
	if not TRIBES.has(new_tribe):
		return
	tribe_key = new_tribe
	_resolve_colors()
	if _body_mesh:
		_body_mesh.material_override = _robe_mat
	if _arm_l:
		_arm_l.material_override = _robe_mat
	if _arm_r:
		_arm_r.material_override = _robe_mat
	if _leg_l:
		_leg_l.material_override = _robe_mat
	if _leg_r:
		_leg_r.material_override = _robe_mat
	if _glow_light:
		_glow_light.light_color = _tribe_color

func set_role(new_role: String) -> void:
	if not ROLES.has(new_role):
		return
	role = new_role
	if _body_root:
		var rd: Dictionary = ROLES.get(new_role, ROLES["avatar"]) as Dictionary
		_body_root.scale = Vector3.ONE * (rd.get("scale", 1.0) as float)

func set_age(new_age: int) -> void:
	age = clamp(new_age, 12, 29)
	if _body_root:
		var s: float = 1.0
		if age < 16:
			s = 0.88
		var rd: Dictionary = ROLES.get(role, ROLES["avatar"]) as Dictionary
		_body_root.scale = Vector3.ONE * ((rd.get("scale", 1.0) as float) * s)

# ─────────────────────────────────────────────────────────────────────────────
# SERIALISATION
# ─────────────────────────────────────────────────────────────────────────────
func to_dict() -> Dictionary:
	return {
		"tribe_key": tribe_key, "role": role, "age": age,
		"skin_tone": skin_tone, "hair_col": hair_col,
		"eye_col":   eye_col,   "build":    build,
		"position":  [position.x, position.y, position.z],
	}

func from_dict(data: Dictionary) -> void:
	tribe_key = data.get("tribe_key", "reuben") as String
	role      = data.get("role",      "avatar")  as String
	age       = (data.get("age",      17))       as int
	skin_tone = data.get("skin_tone", "medium")  as String
	hair_col  = data.get("hair_col",  "black")   as String
	eye_col   = data.get("eye_col",   "brown")   as String
	build     = data.get("build",     "lean")    as String
	var p: Array = data.get("position", [0.0, 0.0, 0.0]) as Array
	if p.size() >= 3:
		position = Vector3(p[0], p[1], p[2])
	if _body_root:
		set_tribe(tribe_key)

# ─────────────────────────────────────────────────────────────────────────────
# STATIC FACTORY
# "Each one should use whatever gift he has received" - 1 Peter 4:10
# ─────────────────────────────────────────────────────────────────────────────
static func create(p_tribe: String, p_avatar_key: String, p_role: String) -> Node3D:
	var char: Node3D = load("res://scripts/Character.gd").new() as Node3D
	char.set("tribe_key", p_tribe)
	char.set("role",      p_role)
	if Global.has_method("get_avatar_data"):
		var av: Dictionary = Global.get_avatar_data(p_tribe, p_avatar_key)
		if not av.is_empty():
			char.set("age",       av.get("age",   17)       as int)
			char.set("skin_tone", av.get("skin",  "medium") as String)
			char.set("hair_col",  av.get("hair",  "black")  as String)
			char.set("eye_col",   av.get("eyes",  "brown")  as String)
			char.set("build",     av.get("build", "lean")   as String)
	return char
