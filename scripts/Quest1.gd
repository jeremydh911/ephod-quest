extends Node2D
func _ready():
	$ElderLabel.text = "My child, climb the ladder—steady like Reuben learns."
	$Timer.start()
	$Timer.timeout.connect(reuben_mini)
func reuben_mini():
	$ElderLabel.text = "Trust in the Lord... Prov 3:5-6"
	$VerseLabel.visible = true
	$VerseLabel.text = "Repeat: 'Trust in the Lord'?"
	await get_tree().create_timer(3.0).timeout  # Simulate memorization
	Global.add_stone("Reuben")
	Global.add_verse("Reuben", "Prov 3:5-6")
	$VerseLabel.text += "\nButterfly: tastes with feet! New creation - 2 Cor 5:17"
	var error = get_tree().change_scene_to_file("res://scenes/Finale.tscn")
	if error != OK:
		push_error("Failed to load Finale scene: " + str(error))
