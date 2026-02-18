extends Control
var player_list = []

func _ready():
	if has_node("VBoxContainer/Host"):
		$VBoxContainer/Host.pressed.connect(MultiplayerLobby.host)
	if has_node("VBoxContainer/Join") and has_node("VBoxContainer/CodeEntry"):
		$VBoxContainer/Join.pressed.connect(func(): MultiplayerLobby.join($VBoxContainer/CodeEntry.text))
	if has_node("VBoxContainer/Back"):
		$VBoxContainer/Back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))
	multiplayer.peer_connected.connect(_on_peer)
	multiplayer.peer_disconnected.connect(_on_dis)

func _on_peer(id):
	player_list.append(id)
	update_list()

func _on_dis(id):
	player_list.erase(id)
	update_list()

func update_list():
	if not has_node("VBoxContainer/PlayerList"):
		return
	$VBoxContainer/PlayerList.clear()
	for p in player_list:
		$VBoxContainer/PlayerList.add_item("Player " + str(p))
