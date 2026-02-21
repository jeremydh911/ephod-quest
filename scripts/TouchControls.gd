extends Control
# ─────────────────────────────────────────────────────────────────────────────
# TouchControls.gd
# Enhanced virtual on-screen joystick for mobile play.
# Features: smooth movement, visual feedback, haptic simulation, auto-hide.
# Attach to a CanvasLayer node anchored bottom-left.
# ─────────────────────────────────────────────────────────────────────────────

const OUTER_RADIUS:  float = 80.0   # Larger for easier touch
const INNER_RADIUS:  float = 30.0   # More visible nub
const DEAD_ZONE:     float = 10.0   # Smaller dead zone
const FADE_TIME:     float = 2.0    # Auto-hide after inactivity

var _touch_id:   int   = -1
var _origin:     Vector2 = Vector2.ZERO
var _direction:  Vector2 = Vector2.ZERO
var _active:     bool    = false
var _last_active_time: float = 0.0

@onready var _outer: ColorRect = $Outer
@onready var _inner: ColorRect = $Inner

func _ready() -> void:
	# Anchor to bottom-left with proper sizing
	set_anchors_preset(PRESET_BOTTOM_LEFT)
	custom_minimum_size = Vector2(OUTER_RADIUS * 2 + 30, OUTER_RADIUS * 2 + 30)
	_build_visuals()
	_last_active_time = Time.get_time_since_startup()

func _build_visuals() -> void:
	if not _outer:
		_outer = ColorRect.new()
		_outer.name = "Outer"
		add_child(_outer)
	
	# Enhanced styling with rounded corners and better colors
	_outer.size = Vector2(OUTER_RADIUS * 2, OUTER_RADIUS * 2)
	_outer.position = Vector2(15, 15)
	_outer.color = Color(0.9, 0.9, 0.9, 0.2)  # Softer white
	_outer.material = _create_rounded_material()
	
	if not _inner:
		_inner = ColorRect.new()
		_inner.name = "Inner"
		add_child(_inner)
	
	_inner.size = Vector2(INNER_RADIUS * 2, INNER_RADIUS * 2)
	_inner.position = _outer.position + Vector2(OUTER_RADIUS - INNER_RADIUS, OUTER_RADIUS - INNER_RADIUS)
	_inner.color = Color(1.0, 1.0, 1.0, 0.8)  # More opaque
	_inner.material = _create_rounded_material()

func _create_rounded_material() -> CanvasItemMaterial:
	var mat := CanvasItemMaterial.new()
	# Note: In Godot 4.3, we could use a custom shader for rounded corners
	# For now, we'll use the default material
	return mat

func _process(delta: float) -> void:
	# Auto-fade when inactive
	var current_time = Time.get_time_since_startup()
	if not _active and current_time - _last_active_time > FADE_TIME:
		var alpha = max(0.1, 1.0 - (current_time - _last_active_time - FADE_TIME) * 0.5)
		_outer.modulate.a = alpha
		_inner.modulate.a = alpha
	else:
		_outer.modulate.a = 1.0
		_inner.modulate.a = 1.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if _touch_id == -1 and _is_in_zone(touch.position):
				_touch_id = touch.index
				_origin   = touch.position
				_active   = true
				_last_active_time = Time.get_time_since_startup()
				_simulate_haptic_feedback()  # Gentle feedback on touch start
		else:
			if touch.index == _touch_id:
				_reset()

	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _touch_id and _active:
			_last_active_time = Time.get_time_since_startup()
			var delta := drag.position - _origin
			if delta.length() < DEAD_ZONE:
				_direction = Vector2.ZERO
			else:
				_direction = delta.normalized() * minf(delta.length() / OUTER_RADIUS, 1.0)
			
			# Smooth inner nub movement with clamping
			var clamped := delta.normalized() * minf(delta.length(), OUTER_RADIUS - INNER_RADIUS)
			_inner.position = _outer.position + Vector2(OUTER_RADIUS - INNER_RADIUS, OUTER_RADIUS - INNER_RADIUS) + clamped
			
			# Visual feedback: scale inner nub based on pressure
			var pressure = minf(delta.length() / OUTER_RADIUS, 1.0)
			_inner.scale = Vector2(1.0 + pressure * 0.2, 1.0 + pressure * 0.2)
			
			_push_to_player()

func _is_in_zone(pos: Vector2) -> bool:
	var centre := _outer.global_position + Vector2(OUTER_RADIUS, OUTER_RADIUS)
	return pos.distance_to(centre) <= OUTER_RADIUS * 1.8   # More generous touch target

func _push_to_player() -> void:
	# Broadcast to all nodes in "player" group
	get_tree().call_group("player", "set_touch_direction", _direction)

func _reset() -> void:
	_touch_id  = -1
	_direction = Vector2.ZERO
	_active    = false
	_last_active_time = Time.get_time_since_startup()
	_inner.position = _outer.position + Vector2(OUTER_RADIUS - INNER_RADIUS, OUTER_RADIUS - INNER_RADIUS)
	_inner.scale = Vector2.ONE  # Reset scale
	_push_to_player()

func _simulate_haptic_feedback() -> void:
	# Simulate haptic feedback through visual pulse
	var tw := create_tween()
	tw.tween_property(_inner, "scale", Vector2(1.3, 1.3), 0.1)
	tw.tween_property(_inner, "scale", Vector2.ONE, 0.1)
	
	# Also pulse the outer ring
	var tw2 := create_tween()
	tw2.tween_property(_outer, "modulate:a", 0.4, 0.1)
	tw2.tween_property(_outer, "modulate:a", 0.2, 0.1)
