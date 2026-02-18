extends Node2D
func _ready():
	$Ephod.visible = true
	var tween = create_tween()
	tween.tween_property($Ephod, "modulate:a", 1.0, 2.0)
	await tween.finished
	$Light.visible = true
	var light_tween = create_tween()
	light_tween.tween_property($Light, "color:a", 0.5, 3.0)
	await light_tween.finished
	# End
	get_tree().quit()
