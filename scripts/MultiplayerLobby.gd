extends Node

var peer = ENetMultiplayerPeer.new()

func host():
	var error = peer.create_server(1234)
	if error != OK:
		push_error("Failed to create server: " + str(error))
		return error
	multiplayer.multiplayer_peer = peer
	AudioManager.play_sfx("res://assets/audio/sfx/join_success.wav")
	return OK

func join(code):
	var error = peer.create_client(code, 1234)
	if error != OK:
		push_error("Failed to connect to server: " + str(error))
		return error
	multiplayer.multiplayer_peer = peer
	AudioManager.play_sfx("res://assets/audio/sfx/join_success.wav")
	return OK
