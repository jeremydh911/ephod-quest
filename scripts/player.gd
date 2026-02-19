extends CharacterBody2D
# ─────────────────────────────────────────────────────────────────────────────
# player.gd  –  Twelve Stones / Ephod Quest
# Mobile-first 2D character controller.
# Touch swipe → directional movement via Global's _input handler.
# "He guides me along the right paths" – Psalm 23:3
# ─────────────────────────────────────────────────────────────────────────────

const SPEED: float = 300.0

@export var tribe_color: Color = Color.WHITE   # tinted from GlobalData

# Virtual joystick delta injected by on-screen controls (set from TouchControls node)
var touch_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Tint the sprite to the player's tribe colour
	if Global.selected_tribe != "":
		var tribe_data := Global.get_tribe_data(Global.selected_tribe)
		if tribe_data.has("color"):
			tribe_color = Color(tribe_data["color"])
			if has_node("Sprite2D"):
				$Sprite2D.modulate = tribe_color

func _physics_process(_delta: float) -> void:
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
		velocity.y = dir.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
