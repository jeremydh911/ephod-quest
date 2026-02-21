extends CharacterBody3D
# ─────────────────────────────────────────────────────────────────────────────
# player.gd  –  Twelve Stones / Ephod Quest
# Mobile-first 3D character controller.
# Touch swipe → directional movement via Global's _input handler.
# "He guides me along the right paths" – Psalm 23:3
# ─────────────────────────────────────────────────────────────────────────────

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var tribe_color: Color = Color.WHITE   # tinted from GlobalData

# Virtual joystick delta injected by on-screen controls (set from TouchControls node)
var touch_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Tint the mesh to the player's tribe colour
	if Global.selected_tribe != "":
		var tribe_data := Global.get_tribe_data(Global.selected_tribe)
		if tribe_data.has("color"):
			tribe_color = Color(tribe_data["color"])
			if has_node("MeshInstance3D"):
				var material := StandardMaterial3D.new()
				material.albedo_color = tribe_color
				# Load a texture if available
				var texture_path := "res://assets/textures/" + Global.selected_tribe + "_avatar.jpg"
				if ResourceLoader.exists(texture_path):
					material.albedo_texture = load(texture_path)
				$MeshInstance3D.material_override = material

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Combine keyboard/gamepad input with touch direction
	var dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up",   "move_down")
	)
	if dir.length_squared() < 0.01:
		dir = touch_direction    # fall back to virtual joystick

	if dir.length_squared() > 0.01:
		dir = dir.normalized()
		velocity.x = dir.x * SPEED
		velocity.z = dir.y * SPEED  # z for forward/back
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
