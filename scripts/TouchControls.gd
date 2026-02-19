extends Control
# ─────────────────────────────────────────────────────────────────────────────
# TouchControls.gd
# Virtual on-screen joystick for mobile play.
# Attach to a CanvasLayer node anchored bottom-left.
# Sets player.touch_direction via group call.
# ─────────────────────────────────────────────────────────────────────────────

const OUTER_RADIUS:  float = 72.0
const INNER_RADIUS:  float = 26.0
const DEAD_ZONE:     float = 8.0

var _touch_id:   int   = -1
var _origin:     Vector2 = Vector2.ZERO
var _direction:  Vector2 = Vector2.ZERO
var _active:     bool    = false

@onready var _outer: ColorRect = $Outer
@onready var _inner: ColorRect = $Inner

func _ready() -> void:
	# Anchor to bottom-left
	set_anchors_preset(PRESET_BOTTOM_LEFT)
	custom_minimum_size = Vector2(OUTER_RADIUS * 2 + 20, OUTER_RADIUS * 2 + 20)
	_build_visuals()

func _build_visuals() -> void:
	if not _outer:
		_outer = ColorRect.new()
		_outer.name = "Outer"
		add_child(_outer)
	_outer.size = Vector2(OUTER_RADIUS * 2, OUTER_RADIUS * 2)
	_outer.position = Vector2(10, 10)
	_outer.color = Color(1, 1, 1, 0.18)

	if not _inner:
		_inner = ColorRect.new()
		_inner.name = "Inner"
		add_child(_inner)
	_inner.size = Vector2(INNER_RADIUS * 2, INNER_RADIUS * 2)
	_inner.position = _outer.position + Vector2(OUTER_RADIUS - INNER_RADIUS, OUTER_RADIUS - INNER_RADIUS)
	_inner.color = Color(1, 1, 1, 0.55)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if _touch_id == -1 and _is_in_zone(touch.position):
				_touch_id = touch.index
				_origin   = touch.position
				_active   = true
		else:
			if touch.index == _touch_id:
				_reset()

	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _touch_id and _active:
			var delta := drag.position - _origin
			if delta.length() < DEAD_ZONE:
				_direction = Vector2.ZERO
			else:
				_direction = delta.normalized() * minf(delta.length() / OUTER_RADIUS, 1.0)
			# Move inner nub
			var clamped := delta.normalized() * minf(delta.length(), OUTER_RADIUS - INNER_RADIUS)
			_inner.position = _outer.position + Vector2(OUTER_RADIUS - INNER_RADIUS, OUTER_RADIUS - INNER_RADIUS) + clamped
			_push_to_player()

func _is_in_zone(pos: Vector2) -> bool:
	var centre := _outer.global_position + Vector2(OUTER_RADIUS, OUTER_RADIUS)
	return pos.distance_to(centre) <= OUTER_RADIUS * 1.6   # generous touch target

func _push_to_player() -> void:
	# Broadcast to all nodes in "player" group
	get_tree().call_group("player", "set_touch_direction", _direction)

func _reset() -> void:
	_touch_id  = -1
	_direction = Vector2.ZERO
	_active    = false
	_inner.position = _outer.position + Vector2(OUTER_RADIUS - INNER_RADIUS, OUTER_RADIUS - INNER_RADIUS)
	_push_to_player()
