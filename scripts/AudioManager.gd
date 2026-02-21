extends Node
# ─────────────────────────────────────────────────────────────────────────────
# AudioManager.gd  –  Twelve Stones / Ephod Quest
# Handles background music (with soft cross-fade), one-shot SFX, looping
# ambience, and dialogue voice mumbles. All audio paths are resolved through
# AssetRegistry for centralised asset management.
#
# Key API:
#   AudioManager.play_tribe_music("judah")      → starts Judah's theme
#   AudioManager.sfx("stone_collect")           → plays SFX by semantic key
#   AudioManager.play_ambient("campfire")       → looping background ambience
#   AudioManager.stop_ambient()                 → fade out ambience
#   AudioManager.play_music(path)               → direct path override
#
# "Sing to him a new song; play skillfully, and shout for joy." – Psalm 33:3
# ─────────────────────────────────────────────────────────────────────────────

# AssetRegistry is available globally as an autoload singleton – no preload needed

var _music_player_a := AudioStreamPlayer.new()
var _music_player_b := AudioStreamPlayer.new()
var _active_music_path := ""
var _use_a := true   # which bus is currently foreground

# Single persistent SFX player — stopping it before each new sound ensures
# no UI click / tap / chime sounds pile up or loop over each other.
# "There is a time for every activity under the heavens" – Ecclesiastes 3:1
var _sfx_player   := AudioStreamPlayer.new()
var _voice_player := AudioStreamPlayer.new()   # kept separate so dialogue mumbles
	                                             # don't cut off UI feedback sounds
var _ambient_player := AudioStreamPlayer.new() # looping background ambience
	                                             # (campfire, ocean, crickets, wind)

func _ready() -> void:
	# Ensure required buses exist; create them if project hasn't defined them.
	# Without this, the web export throws "invalid bus index -1" in JS.
	_ensure_bus("Music")
	_ensure_bus("SFX")
	_ensure_bus("Ambient")
	for p in [_music_player_a, _music_player_b]:
		add_child(p)
		p.bus = "Music"
		p.volume_db = -6.0
	_sfx_player.bus = "SFX"
	_sfx_player.volume_db = 0.0
	add_child(_sfx_player)
	_voice_player.bus = "SFX"
	_voice_player.volume_db = -3.0
	add_child(_voice_player)
	_ambient_player.bus = "Ambient"
	_ambient_player.volume_db = -14.0   # subtle background layer
	add_child(_ambient_player)

func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		var idx := AudioServer.bus_count
		AudioServer.add_bus()
		AudioServer.set_bus_name(idx, bus_name)

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
		return
	var stream = load(path)
	if stream == null:
		return
	# Stop whatever was playing so sounds never stack or loop over each other.
	# Music is untouched — only the SFX channel is interrupted.
	_sfx_player.stop()
	_sfx_player.stream = stream
	_sfx_player.bus = "SFX" if AudioServer.get_bus_index("SFX") != -1 else "Master"
	_sfx_player.play()

# ─────────────────────────────────────────────────────────────────────────────
# VOICE MUMBLES  –  "A gentle answer turns away wrath" – Proverbs 15:1
# Plays a short lofi-style murmur clip when a dialogue line appears.
# Speaker categories: "elder" → warm low murmur, "you/player" → bright murmur.
# Files: res://assets/audio/sfx/voice/elder_murmur_1..3.wav
#        res://assets/audio/sfx/voice/child_murmur_1..2.wav
#        res://assets/audio/sfx/voice/neutral_murmur_1..2.wav
# If a file is missing the call falls through play_sfx's silent guard.
# ─────────────────────────────────────────────────────────────────────────────
func play_voice(speaker_name: String) -> void:
	var s := speaker_name.to_lower().strip_edges()
	var prefix: String
	var count: int
	if s == "you" or s == "player":
		prefix = "child"
		count  = 2
	elif s.contains("elder") or s.contains("elder "):
		prefix = "elder"
		count  = 3
	else:
		prefix = "neutral"
		count  = 2
	var idx := randi_range(1, count)
	var path := "res://assets/audio/sfx/voice/%s_murmur_%d.wav" % [prefix, idx]
	if not ResourceLoader.exists(path):
		return
	var stream = load(path)
	if stream == null:
		return
	# Voice mumbles use a dedicated player so they don't cut off UI click sounds.
	_voice_player.stop()
	_voice_player.stream = stream
	_voice_player.play()

func stop_music(fade_duration: float = 1.0) -> void:
	for p in [_music_player_a, _music_player_b]:
		if p.playing:
			var tw := create_tween()
			tw.tween_property(p, "volume_db", -80.0, fade_duration)
			await tw.finished
			p.stop()
	_active_music_path = ""

# ─────────────────────────────────────────────────────────────────────────────
# TRIBE MUSIC  –  auto-selects the correct theme for any tribe
# "Each made music in their own way, but together it was one song" (narrative)
# ─────────────────────────────────────────────────────────────────────────────
func play_tribe_music(tribe_key: String) -> void:
	var path: String = AssetRegistry.MUSIC.get(tribe_key, "") as String
	if path == "":
		path = AssetRegistry.music("verse_vault")   # graceful fallback
	play_music(path)

# ─────────────────────────────────────────────────────────────────────────────
# SFX BY KEY  –  "AudioManager.sfx('stone_collect')"
# Uses AssetRegistry.SFX dictionary so callers don't need hard-coded paths.
# ─────────────────────────────────────────────────────────────────────────────
func sfx(key: String) -> void:
	var path: String = AssetRegistry.SFX.get(key, "") as String
	if path != "":
		play_sfx(path)

# ─────────────────────────────────────────────────────────────────────────────
# AMBIENT LOOP  –  low-volume looping atmosphere (campfire, ocean, wind)
# "He sends his word and melts them; he stirs up his breezes" – Psalm 147:18
# ─────────────────────────────────────────────────────────────────────────────
func play_ambient(key: String, vol_db: float = -14.0) -> void:
	var path: String = AssetRegistry.SFX.get(key, "") as String
	if path == "" or not ResourceLoader.exists(path):
		return
	_ambient_player.stop()
	var stream = load(path)
	if stream == null:
		return
	# Make looping work for both AudioStreamWAV and AudioStreamOggVorbis
	if stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	_ambient_player.stream  = stream
	_ambient_player.volume_db = vol_db
	_ambient_player.play()

## Fade out and stop ambient layer.
func stop_ambient(fade_duration: float = 2.0) -> void:
	if not _ambient_player.playing:
		return
	var tw := create_tween()
	tw.tween_property(_ambient_player, "volume_db", -80.0, fade_duration)
	await tw.finished
	_ambient_player.stop()

# ─────────────────────────────────────────────────────────────────────────────
# TRIBE AMBIENT  –  auto-selects the best nature ambience for a tribe biome
# ─────────────────────────────────────────────────────────────────────────────
const _TRIBE_AMBIENT: Dictionary = {
	"reuben":   "campfire",   # shepherd's cliff camp
	"simeon":   "deer",       # desert wildlife
	"levi":     "bells",      # sacred hall, soft bells
	"judah":    "roar",       # lion country (brief, gentle)
	"dan":      "sail_wind",  # coastal breeze
	"naphtali": "deer",       # forest deer
	"gad":      "campfire",   # warrior camp
	"asher":    "olive_press",# olive groves
	"issachar": "stars_shimmer", # starfield night
	"zebulun":  "sail_wind",  # harbour
	"joseph":   "butterfly",  # fertile valley
	"benjamin": "campfire",   # wolf territory camp
}

func play_tribe_ambient(tribe_key: String) -> void:
	var key: String = _TRIBE_AMBIENT.get(tribe_key, "campfire") as String
	play_ambient(key, -18.0)   # quieter than music so it feels natural
