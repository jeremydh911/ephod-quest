extends Node

var selected_tribe: String = ""
var selected_avatar: String = ""
var stones: Array = []
var verses: Dictionary = {}

func add_stone(tribe):
	stones.append(tribe)

func add_verse(tribe, verse):
	verses[tribe] = verse

func _ready():
	multiplayer.peer_connected.connect(sync_data)

func sync_data(id):
	rpc_id(id, "receive_data", selected_tribe, selected_avatar, stones, verses)

@rpc("any_peer")
func receive_data(tribe, avatar, s, v):
	selected_tribe = tribe
	selected_avatar = avatar
	stones = s
	verses = v
