extends Node2D
func _ready():
	AudioManager.play_music("res://assets/audio/music/finale_theme.ogg")
	$Ephod.visible = true
	AudioManager.play_sfx("res://assets/audio/sfx/ephod_reveal.wav")
	var tween = create_tween()
	tween.tween_property($Ephod, "modulate:a", 1.0, 2.0)
	await tween.finished
	$Light.visible = true
	AudioManager.play_sfx("res://assets/audio/sfx/light_hum.wav")
	var light_tween = create_tween()
	light_tween.tween_property($Light, "modulate:a", 0.5, 3.0)
	await light_tween.finished
	# End
	get_tree().quit()
