extends Node
# ─────────────────────────────────────────────────────────────────────────────
# AudioManager.gd  –  Twelve Stones / Ephod Quest
# Handles background music (with soft cross-fade) and one-shot SFX.
# "Sing to him a new song; play skillfully" – Psalm 33:3
# ─────────────────────────────────────────────────────────────────────────────

var _music_player_a := AudioStreamPlayer.new()
var _music_player_b := AudioStreamPlayer.new()
var _active_music_path := ""
var _use_a := true   # which bus is currently foreground

func _ready() -> void:
	for p in [_music_player_a, _music_player_b]:
		add_child(p)
		p.bus = "Music"
		p.volume_db = -6.0

func play_music(path: String, fade_duration: float = 1.5) -> void:
	if path == _active_music_path:
		return
	if not ResourceLoader.exists(path):
		push_warning("[Audio] Music file not found: " + path)
		return
	var stream = load(path)
	if stream == null:
		push_warning("[Audio] Could not load music: " + path)
		return
	_active_music_path = path
	var incoming := _music_player_b if _use_a else _music_player_a
	var outgoing := _music_player_a if _use_a else _music_player_b
	incoming.stream = stream
	incoming.volume_db = -80.0
	incoming.play()
	var tw := create_tween()
	tw.tween_property(incoming, "volume_db", -6.0,  fade_duration)
	tw.parallel().tween_property(outgoing, "volume_db", -80.0, fade_duration)
	await tw.finished
	outgoing.stop()
	_use_a = not _use_a

func play_sfx(path: String) -> void:
	if not ResourceLoader.exists(path):
		# Silently skip missing SFX rather than crashing
		return
	var stream = load(path)
	if stream == null:
		return
	var sfx := AudioStreamPlayer.new()
	add_child(sfx)
	sfx.stream = stream
	sfx.bus = "SFX"
	sfx.play()
	sfx.finished.connect(sfx.queue_free)

func stop_music(fade_duration: float = 1.0) -> void:
	for p in [_music_player_a, _music_player_b]:
		if p.playing:
			var tw := create_tween()
			tw.tween_property(p, "volume_db", -80.0, fade_duration)
			await tw.finished
			p.stop()
	_active_music_path = ""
