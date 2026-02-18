extends Control
func _ready():
	$VBoxContainer/Start.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/AvatarPick.tscn"))
	$VBoxContainer/Multiplayer.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Lobby.tscn"))
	$VBoxContainer/Quit.pressed.connect(get_tree().quit)
