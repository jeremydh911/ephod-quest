extends Node

var music_player = AudioStreamPlayer.new()
var sfx_player = AudioStreamPlayer.new()

func _ready():
	add_child(music_player)
	add_child(sfx_player)
	music_player.bus = "Music"
	sfx_player.bus = "SFX"

func play_music(path: String, fade_in: float = 1.0):
	if music_player.stream and music_player.stream.resource_path == path:
		return
	var stream = load(path)
	if stream:
		music_player.stream = stream
		music_player.play()

func play_sfx(path: String):
	var stream = load(path)
	if stream:
		var effect = AudioStreamPlayer.new()
		add_child(effect)
		effect.stream = stream
		effect.bus = "SFX"
		effect.play()
		effect.finished.connect(effect.queue_free)

func stop_music():
	music_player.stop()
