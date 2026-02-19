extends Control
var player_list = []

func _ready():
	$VBoxContainer/Host.pressed.connect(func():
		var error = MultiplayerLobby.host()
		if error != OK:
			push_error("Failed to host game: " + str(error))
	)
	$VBoxContainer/Join.pressed.connect(func():
		var error = MultiplayerLobby.join($VBoxContainer/CodeEntry.text)
		if error != OK:
			push_error("Failed to join game: " + str(error))
	)
	$VBoxContainer/Back.pressed.connect(func(): 
		var error = get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
		if error != OK:
			push_error("Failed to load MainMenu scene: " + str(error))
	)
	multiplayer.peer_connected.connect(_on_peer)
	multiplayer.peer_disconnected.connect(_on_dis)

func _on_peer(id):
	player_list.append(id)
	update_list()

func _on_dis(id):
	player_list.erase(id)
	update_list()

func update_list():
	$VBoxContainer/PlayerList.clear()
	for p in player_list:
		$VBoxContainer/PlayerList.add_item("Player " + str(p))
