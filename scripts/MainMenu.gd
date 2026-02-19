extends Control
func _ready():
	$VBoxContainer/Start.pressed.connect(func(): 
		var error = get_tree().change_scene_to_file("res://scenes/AvatarPick.tscn")
		if error != OK:
			push_error("Failed to load AvatarPick scene: " + str(error))
	)
	$VBoxContainer/Multiplayer.pressed.connect(func(): 
		var error = get_tree().change_scene_to_file("res://scenes/Lobby.tscn")
		if error != OK:
			push_error("Failed to load Lobby scene: " + str(error))
	)
	$VBoxContainer/Quit.pressed.connect(get_tree().quit)
