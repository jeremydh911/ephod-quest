extends Node
# ─────────────────────────────────────────────────────────────────────────────
# MultiplayerLobby.gd  –  Twelve Stones / Ephod Quest
# ENet peer-to-peer lobby manager.
# "Two are better than one" – Ecclesiastes 4:9
# ─────────────────────────────────────────────────────────────────────────────

signal player_joined(peer_id: int, tribe: String, avatar: String, player_name: String)
signal player_left(peer_id: int)
signal game_started
signal host_ready(code: String)
signal join_failed(reason: String)

const PORT := 7777
const MAX_PLAYERS := 12   # One per tribe

# ── Connected players registry ────────────────────────────────────────────────
# peer_id → { "name": String, "tribe": String, "avatar": String, "stones": Array }
var players: Dictionary = {}

var _peer := ENetMultiplayerPeer.new()

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# ─────────────────────────────────────────────────────────────────────────────
# HOST
# ─────────────────────────────────────────────────────────────────────────────
func host() -> void:
	# "He who tends a fig tree will eat its fruit" – a host tends the lobby
	_peer = ENetMultiplayerPeer.new()
	var err := _peer.create_server(PORT, MAX_PLAYERS)
	if err != OK:
		push_error("[Lobby] Failed to create server — error %d" % err)
		join_failed.emit("Could not open lobby. Please check your network.")
		return
	multiplayer.multiplayer_peer = _peer
	# Register ourselves
	_register_local_player()
	var code := _get_local_ip()
	host_ready.emit(code)
	AudioManager.play_sfx("res://assets/audio/sfx/join_success.wav")
	return OK

# ─────────────────────────────────────────────────────────────────────────────
# JOIN
# ─────────────────────────────────────────────────────────────────────────────
func join(code: String) -> void:
	var ip := code.strip_edges()
	if ip.is_empty():
		join_failed.emit("Please enter the host's code or IP address.")
		return
	_peer = ENetMultiplayerPeer.new()
	var err := _peer.create_client(ip, PORT)
	if err != OK:
		push_error("[Lobby] Failed to create client — error %d" % err)
		join_failed.emit("Could not connect to \"%s\". Check the code and try again." % ip)
		return
	multiplayer.multiplayer_peer = _peer
	AudioManager.play_sfx("res://assets/audio/sfx/join_success.wav")

# ─────────────────────────────────────────────────────────────────────────────
# DISCONNECT
# ─────────────────────────────────────────────────────────────────────────────
func leave() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	players.clear()

# ─────────────────────────────────────────────────────────────────────────────
# START GAME  (host only)
# ─────────────────────────────────────────────────────────────────────────────
func start_game() -> void:
	if not multiplayer.is_server():
		push_warning("[Lobby] Only the host can start the game.")
		return
	_rpc_start_game.rpc()

@rpc("authority", "call_local", "reliable")
func _rpc_start_game() -> void:
	game_started.emit()
	get_tree().change_scene_to_file("res://scenes/AvatarPick.tscn")

# ─────────────────────────────────────────────────────────────────────────────
# PLAYER REGISTRATION  –  called when a peer connects
# ─────────────────────────────────────────────────────────────────────────────
func _register_local_player() -> void:
	var my_id := multiplayer.get_unique_id()
	players[my_id] = {
		"name":   Global.player_name,
		"tribe":  Global.selected_tribe,
		"avatar": Global.selected_avatar,
		"stones": Global.stones.duplicate()
	}
	if multiplayer.get_peer_count() > 0 or multiplayer.is_server():
		_rpc_register_player.rpc(
			Global.player_name,
			Global.selected_tribe,
			Global.selected_avatar,
			Global.stones.duplicate()
		)

@rpc("any_peer", "call_local", "reliable")
func _rpc_register_player(p_name: String, tribe: String,
						   avatar: String, p_stones: Array) -> void:
	var sender := multiplayer.get_remote_sender_id()
	if sender == 0:
		sender = multiplayer.get_unique_id()
	players[sender] = {
		"name":   p_name,
		"tribe":  tribe,
		"avatar": avatar,
		"stones": p_stones
	}
	player_joined.emit(sender, tribe, avatar, p_name)

# ─────────────────────────────────────────────────────────────────────────────
# CROSS-TRIBE CO-OP CHECK  –  "Ecclesiastes 4:12 — three is not quickly broken"
# Returns a co-op action label if two matching tribes are both online
# ─────────────────────────────────────────────────────────────────────────────
func get_active_coop_action() -> Dictionary:
	var tribes_online: Array[String] = []
	for pid in players:
		var t: String = players[pid].get("tribe", "")
		if t != "" and t not in tribes_online:
			tribes_online.append(t)
	for key in Global.COOP_ACTIONS:
		var parts := key.split("+")
		if parts.size() == 2:
			if parts[0] in tribes_online and parts[1] in tribes_online:
				return Global.COOP_ACTIONS[key]
		elif parts.size() == 1 and parts[0] == "asher":
			if "asher" in tribes_online:
				return Global.COOP_ACTIONS[key]
	return {}

# ─────────────────────────────────────────────────────────────────────────────
# SIGNAL HANDLERS
# ─────────────────────────────────────────────────────────────────────────────
func _on_peer_connected(id: int) -> void:
	print("[Lobby] Peer connected: %d" % id)
	# Send our own data to the newcomer
	rpc_id(id, "_rpc_register_player",
		Global.player_name,
		Global.selected_tribe,
		Global.selected_avatar,
		Global.stones.duplicate()
	)

func _on_peer_disconnected(id: int) -> void:
	print("[Lobby] Peer disconnected: %d" % id)
	players.erase(id)
	player_left.emit(id)

func _on_connected_to_server() -> void:
	print("[Lobby] Connected to server successfully.")
	_register_local_player()

func _on_connection_failed() -> void:
	push_warning("[Lobby] Connection to server failed.")
	join_failed.emit("Connection failed. The host may be unavailable.")
	multiplayer.multiplayer_peer = null

func _on_server_disconnected() -> void:
	push_warning("[Lobby] Server disconnected.")
	players.clear()
	join_failed.emit("The host ended the session.")
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────
func _get_local_ip() -> String:
	# Prefer the first non-loopback IPv4
	for addr in IP.get_local_addresses():
		if addr.begins_with("192.") or addr.begins_with("10.") or addr.begins_with("172."):
			return addr
	return "127.0.0.1"

func get_player_count() -> int:
	return players.size()

func get_tribes_online() -> Array[String]:
	var result: Array[String] = []
	for pid in players:
		var t: String = players[pid].get("tribe", "")
		if t != "" and t not in result:
			result.append(t)
	return result
