extends Control
# ─────────────────────────────────────────────────────────────────────────────
# MainMenu.gd  –  Twelve Stones / Ephod Quest
# Entry point: Start (→ AvatarPick), Multiplayer (→ Lobby), Quit.
# "I am the way and the truth and the life" – John 14:6
# ─────────────────────────────────────────────────────────────────────────────

const VisualEnvironment := preload("res://scripts/VisualEnvironment.gd")

# Gem accent colours matching the 12 ephod stones (Exodus 28:17-20)
const STONE_COLORS: Array[Color] = [
	Color(0.77, 0.12, 0.23, 1), # Reuben  – carnelian
	Color(0.08, 0.41, 0.78, 1), # Simeon  – lapis lazuli
	Color(0.09, 0.60, 0.41, 1), # Levi    – emerald
	Color(0.90, 0.76, 0.10, 1), # Judah   – turquoise (gold substitute)
	Color(0.18, 0.55, 0.84, 1), # Dan     – sapphire
	Color(0.56, 0.00, 0.70, 1), # Naphtali– amethyst
	Color(0.22, 0.69, 0.28, 1), # Gad     – jacinth (green here)
	Color(0.08, 0.38, 0.74, 1), # Asher   – agate (blue)
	Color(0.48, 0.47, 0.95, 1), # Issachar– amethyst (purple)
	Color(0.95, 0.61, 0.07, 1), # Zebulun – chrysolite (amber)
	Color(0.20, 0.80, 0.20, 1), # Joseph  – onyx (green)
	Color(0.78, 0.18, 0.10, 1), # Benjamin– jasper (red)
]

var _fade_rect: ColorRect

func _ready() -> void:
	# "Gathering at the Gates" — entering the presence  (Isaiah 26:2)
	const MAIN_MUSIC := "res://assets/audio/music/gathering_at_the_gates.wav"
	AudioManager.play_music(MAIN_MUSIC if ResourceLoader.exists(MAIN_MUSIC) else "res://assets/audio/music/main_menu.ogg")

	# Create fade rectangle for transitions
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.z_index = 100
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade_rect)

	# Check for existing save
	Global.load_game()
	$Buttons/Continue.visible = Global.stones.size() > 0

	# Connect buttons
	$Buttons/Continue.pressed.connect(_on_continue)
	$Buttons/Start.pressed.connect(_on_start)
	$Buttons/VerseVault.pressed.connect(_on_verse_vault)
	$Buttons/Multiplayer.pressed.connect(_on_multiplayer)
	$Buttons/Support.pressed.connect(_on_support)
	$Buttons/Quit.pressed.connect(_on_quit)

	# Rich visual atmosphere – "The whole earth is full of his glory" – Isaiah 6:3
	_build_main_menu_visuals()

func _build_main_menu_visuals() -> void:
	# ── Real background artwork layer (img_13) – behind everything ─────────
	# "Beautiful in its time" – Ecclesiastes 3:11
	VisualEnvironment.add_scene_background(self, "main_menu")

	# ── Warm desert-to-gold sky gradient (semi-transparent, blends with bg) ─
	# "He set the earth on its foundations" – Psalm 104:5
	var sky := ColorRect.new()
	sky.name = "_MM_Sky"
	sky.z_index = -9
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sky.set_anchors_preset(Control.PRESET_FULL_RECT)
	var sky_mat := ShaderMaterial.new()
	var sky_shd := Shader.new()
	sky_shd.code = "
shader_type canvas_item;
uniform vec4 top_col : source_color = vec4(0.07,0.04,0.01,1.0);
uniform vec4 bot_col : source_color = vec4(0.91,0.80,0.56,1.0);
void fragment() {
	vec4 c = mix(top_col, bot_col, pow(UV.y, 0.55));
	COLOR  = vec4(c.rgb, 0.62);
}"
	sky_mat.shader = sky_shd
	sky_mat.set_shader_parameter("top_col", Color(0.07, 0.04, 0.01, 1))
	sky_mat.set_shader_parameter("bot_col", Color(0.91, 0.80, 0.56, 1))
	sky.material = sky_mat
	add_child(sky)
	move_child(sky, 0)

	# Breathe the sky subtly
	var sky_tw := create_tween()
	sky_tw.set_loops()
	sky_tw.tween_method(func(v: float):
		sky_mat.set_shader_parameter("bot_col", Color(0.91, 0.80 + v * 0.04, 0.56 + v * 0.06, 1))
	, 0.0, 1.0, 12.0).set_ease(Tween.EASE_IN_OUT)
	sky_tw.tween_method(func(v: float):
		sky_mat.set_shader_parameter("bot_col", Color(0.91, 0.84 - v * 0.04, 0.62 - v * 0.06, 1))
	, 0.0, 1.0, 12.0).set_ease(Tween.EASE_IN_OUT)

	# ── Golden mote particles ─────────────────────────────────────────────────
	var parts := CPUParticles2D.new()
	parts.name = "_MM_Sparks"
	parts.z_index = 2
	parts.emitting             = true
	parts.amount               = 40
	parts.lifetime             = 9.0
	parts.preprocess           = 4.0
	parts.gravity              = Vector2(4.0, -18.0)
	parts.initial_velocity_min = 10.0
	parts.initial_velocity_max = 38.0
	parts.scale_amount_min     = 2.0
	parts.scale_amount_max     = 6.0
	parts.spread               = 180.0
	parts.emission_shape       = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	parts.emission_rect_extents = Vector2(380, 10)
	parts.position             = Vector2(360, 640)
	parts.color                = Color(1.0, 0.88, 0.22, 0.60)
	add_child(parts)

	# ── Animate Stone1–Stone12 in the EphodIllustration ──────────────────────
	# "You shall place the twelve stones…" – Exodus 28:21
	var ephod: Node = get_node_or_null("EphodIllustration")
	if ephod != null:
		for i: int in range(1, 13):
			var stone: Node = ephod.get_node_or_null("Stone%d" % i)
			if stone == null:
				continue
			var rect: ColorRect = stone as ColorRect
			if rect == null:
				continue
			var stone_col: Color = STONE_COLORS[i - 1]
			rect.color = stone_col
			# Stagger: each gem pulses with a slight delay
			var delay_tw := create_tween()
			delay_tw.tween_interval(float(i - 1) * 0.18)
			delay_tw.tween_callback(func():
				var loop_tw := create_tween()
				loop_tw.set_loops()
				loop_tw.tween_property(rect, "modulate:a", 1.0, 0.7).set_ease(Tween.EASE_IN_OUT)
				loop_tw.tween_property(rect, "modulate:a", 0.55, 0.7).set_ease(Tween.EASE_IN_OUT)
			)

	# ── Vignette ─────────────────────────────────────────────────────────────
	VisualEnvironment.add_vignette(self)

func _on_continue() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	await _fade_out()
	var result := get_tree().change_scene_to_file("res://scenes/AvatarPick.tscn")
	if result != OK:
		push_error("[MainMenu] Failed to load AvatarPick.tscn — error %d" % result)

func _on_start() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	# Clear any existing save for new journey
	Global.selected_tribe = ""
	Global.selected_avatar = ""
	Global.stones.clear()
	Global.memorized_verses.clear()
	Global.completed_quests.clear()
	Global.journal_entries.clear()
	Global.heart_badges.clear()
	await _fade_out()
	var result := get_tree().change_scene_to_file("res://scenes/AvatarPick.tscn")
	if result != OK:
		push_error("[MainMenu] Failed to load AvatarPick.tscn — error %d" % result)

func _on_verse_vault() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	await _fade_out()
	var result := get_tree().change_scene_to_file("res://scenes/VerseVaultScene.tscn")
	if result != OK:
		push_error("[MainMenu] Failed to load VerseVaultScene.tscn — error %d" % result)

func _on_multiplayer() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	await _fade_out()
	var result := get_tree().change_scene_to_file("res://scenes/Lobby.tscn")
	if result != OK:
		push_error("[MainMenu] Failed to load Lobby.tscn — error %d" % result)

func _on_support() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	var dialog := AcceptDialog.new()
	dialog.title = "Support Twelve Stones"
	dialog.dialog_text = "Enjoying the game? Your voluntary donations help us continue developing educational adventures!\n\nKo-fi: ko-fi.com/ephodquest\nPayPal: paypal.me/ephodquest\n\nThank you for your generosity!"
	add_child(dialog)
	dialog.popup_centered()

func _on_quit() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	await _fade_out()
	get_tree().quit()

func _fade_out() -> void:
	var tw := create_tween()
	tw.tween_property(_fade_rect, "color:a", 1.0, 0.5)
	await tw.finished
