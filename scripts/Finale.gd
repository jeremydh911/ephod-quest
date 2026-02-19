extends Control
# Finale.gd  –  Closing courtyard ephod-weave sequence

const TRIBE_ORDER: Array[String] = [
	"reuben","simeon","levi","judah","dan","naphtali",
	"gad","asher","issachar","zebulun","joseph","benjamin"
]

const GEM_COLORS: Array[Color] = [
	Color(0.80, 0.15, 0.15, 1),  Color(0.20, 0.55, 0.85, 1),  Color(0.10, 0.60, 0.20, 1),
	Color(0.70, 0.20, 0.85, 1),  Color(0.10, 0.10, 0.10, 1),  Color(0.85, 0.75, 0.10, 1),
	Color(0.70, 0.45, 0.10, 1),  Color(0.10, 0.70, 0.75, 1),  Color(0.75, 0.25, 0.10, 1),
	Color(0.22, 0.17, 0.52, 1),  Color(0.10, 0.35, 0.80, 1),  Color(0.90, 0.82, 0.55, 1)
]

func _ready() -> void:
	AudioManager.play_music("res://assets/audio/music/finale_theme.ogg")
	_generate_stars()
	var fr := $FadeRect as ColorRect
	fr.modulate = Color(0, 0, 0, 1)
	var tw := create_tween()
	tw.tween_property(fr, "modulate:a", 0.0, 1.8)
	tw.tween_callback(Callable(self, "_spawn_tribe_circle"))

func _generate_stars() -> void:
	var stars_node := $NightSkyBG/StarsContainer as Node2D
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(80):
		var star := ColorRect.new()
		var sz := rng.randf_range(1.0, 3.5)
		star.size = Vector2(sz, sz)
		star.position = Vector2(rng.randf_range(0, 640), rng.randf_range(0, 400))
		star.color = Color(1, 1, rng.randf_range(0.85, 1.0), rng.randf_range(0.5, 1.0))
		stars_node.add_child(star)

func _spawn_tribe_circle() -> void:
	var circle_node := $TribeCircle as Node2D
	var tribe_list: Array = Global.completed_tribes if not Global.completed_tribes.is_empty() else TRIBE_ORDER
	var count := tribe_list.size()
	var radius := 110.0
	for i in range(count):
		var angle := (TAU / count) * i - PI / 2.0
		var pos := Vector2(cos(angle), sin(angle)) * radius
		var dot := ColorRect.new()
		dot.size = Vector2(18, 18)
		dot.position = pos - Vector2(9, 9)
		var tribe_key: String = tribe_list[i] if i < tribe_list.size() else "reuben"
		var tribe_data: Dictionary = Global.get_tribe_data(tribe_key)
		var hex: String = tribe_data.get("color", "#FFFFFF")
		dot.color = Color(hex)
		dot.modulate = Color(1, 1, 1, 0)
		circle_node.add_child(dot)
		var tw := create_tween()
		tw.tween_interval(i * 0.18)
		tw.tween_property(dot, "modulate:a", 1.0, 0.5)
	await get_tree().create_timer(count * 0.18 + 0.8).timeout
	_weave_ephod()

func _weave_ephod() -> void:
	var ephod := $EphodCloth as ColorRect
	var tw := create_tween()
	tw.tween_property(ephod, "color:a", 0.9, 1.4)
	tw.tween_callback(Callable(self, "_reveal_gem_rows"))

func _reveal_gem_rows() -> void:
	var rows := [$GemRow1, $GemRow2, $GemRow3, $GemRow4]
	var gem_idx := 0
	for r in range(rows.size()):
		var row: Node = rows[r]
		row.visible = true
		row.modulate = Color(1, 1, 1, 0)
		for c in range(3):
			var gem := ColorRect.new()
			gem.custom_minimum_size = Vector2(36, 22)
			gem.size_flags_horizontal = SIZE_EXPAND_FILL
			gem.color = GEM_COLORS[gem_idx % GEM_COLORS.size()]
			row.add_child(gem)
			gem_idx += 1
		var tw := create_tween()
		tw.tween_interval(r * 0.5)
		tw.tween_property(row, "modulate:a", 1.0, 0.6)
	await get_tree().create_timer(rows.size() * 0.5 + 0.8).timeout
	_glow_people()

func _glow_people() -> void:
	var glow := $PeopleGlow as ColorRect
	var tw := create_tween()
	tw.set_loops(4)
	tw.tween_property(glow, "color:a", 0.45, 0.7)
	tw.tween_property(glow, "color:a", 0.05, 0.7)
	await get_tree().create_timer(5.8).timeout
	_show_message_sequence()

func _show_message_sequence() -> void:
	var panel := $MessagePanel as PanelContainer
	var label := $MessagePanel/MessageLabel as Label
	var messages := [
		"Twelve tribes.\nTwelve stones.\nOne living garment.",
		"Each tribe brought what only they could bring.\nNo tribe was extra. None was forgotten.",
		"\"He's the treasure.\"\n– Not the quest. Not the stone. Him.",
		"Shalom, shalom.",
	]
	for msg in messages:
		label.text = msg
		var tw_in := create_tween()
		tw_in.tween_property(panel, "modulate:a", 1.0, 0.7)
		await get_tree().create_timer(3.2).timeout
		var tw_out := create_tween()
		tw_out.tween_property(panel, "modulate:a", 0.0, 0.7)
		await get_tree().create_timer(0.9).timeout
	_show_buttons()

func _show_buttons() -> void:
	var btns := $ButtonRow as HBoxContainer
	btns.visible = true
	btns.modulate = Color(1, 1, 1, 0)
	var tw := create_tween()
	tw.tween_property(btns, "modulate:a", 1.0, 0.8)
	($ButtonRow/ReplayBtn as Button).pressed.connect(_on_replay)
	($ButtonRow/MenuBtn   as Button).pressed.connect(_on_menu)

func _on_replay() -> void:
	_fade_and_go("res://scenes/AvatarPick.tscn")

func _on_menu() -> void:
	_fade_and_go("res://scenes/MainMenu.tscn")

func _fade_and_go(path: String) -> void:
	var fr := $FadeRect as ColorRect
	var tw := create_tween()
	tw.tween_property(fr, "modulate:a", 1.0, 1.0)
	tw.tween_callback(func():
		var res := get_tree().change_scene_to_file(path)
		if res != OK:
			push_error("Finale: failed to change scene to %s" % path)
	)
