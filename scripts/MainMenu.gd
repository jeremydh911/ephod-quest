extends Control
func _ready():
	if has_node("VBoxContainer/Start"):
		$VBoxContainer/Start.pressed.connect(func(): 
			var error = get_tree().change_scene_to_file("res://scenes/AvatarPick.tscn")
			if error != OK:
				push_error("Failed to load AvatarPick scene")
		)
	else:
		push_error("Missing node: VBoxContainer/Start")

	if has_node("VBoxContainer/Multiplayer"):
		$VBoxContainer/Multiplayer.pressed.connect(func(): 
			var error = get_tree().change_scene_to_file("res://scenes/Lobby.tscn")
			if error != OK:
				push_error("Failed to load Lobby scene")
		)
	else:
		push_error("Missing node: VBoxContainer/Multiplayer")

	if has_node("VBoxContainer/Quit"):
		$VBoxContainer/Quit.pressed.connect(get_tree().quit)
	else:
		push_error("Missing node: VBoxContainer/Quit")
