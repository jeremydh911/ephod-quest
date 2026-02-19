extends Control
func _ready():
	AudioManager.play_music("res://assets/audio/music/main_menu.ogg")
	$VBoxContainer/Start.pressed.connect(func(): 
		AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
		get_tree().change_scene_to_file("res://scenes/AvatarPick.tscn"))
	$VBoxContainer/Multiplayer.pressed.connect(func(): 
		AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
		get_tree().change_scene_to_file("res://scenes/Lobby.tscn"))
	$VBoxContainer/Quit.pressed.connect(func():
		AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
		get_tree().quit())
