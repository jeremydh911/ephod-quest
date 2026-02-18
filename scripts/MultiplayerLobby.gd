extends Node

var peer = ENetMultiplayerPeer.new()

func host():
	peer.create_server(1234)
	multiplayer.multiplayer_peer = peer
	AudioManager.play_sfx("res://assets/audio/sfx/join_success.wav")

func join(code):
	peer.create_client(code, 1234)
	multiplayer.multiplayer_peer = peer
	AudioManager.play_sfx("res://assets/audio/sfx/join_success.wav")
