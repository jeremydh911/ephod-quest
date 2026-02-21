extends Control
# ─────────────────────────────────────────────────────────────────────────────
# Lobby.gd  –  Twelve Stones / Ephod Quest
# Multiplayer lobby: host / join, player list, co-op hint, start game.
# "Two are better than one" – Ecclesiastes 4:9
# ─────────────────────────────────────────────────────────────────────────────

# ── Node refs ────────────────────────────────────────────────────────────────
@onready var _host_btn:      Button         = $Margin/VBoxContainer/ContentRow/ControlPanel/Host
@onready var _code_display:  PanelContainer = $Margin/VBoxContainer/ContentRow/ControlPanel/CodeDisplay
@onready var _code_label:    Label          = $Margin/VBoxContainer/ContentRow/ControlPanel/CodeDisplay/CodeLabel
@onready var _code_entry:    LineEdit       = $Margin/VBoxContainer/ContentRow/ControlPanel/CodeEntry
@onready var _join_btn:      Button         = $Margin/VBoxContainer/ContentRow/ControlPanel/Join
@onready var _status_label:  Label          = $Margin/VBoxContainer/ContentRow/ControlPanel/StatusLabel
@onready var _player_list:   VBoxContainer  = $Margin/VBoxContainer/ContentRow/PlayersPanel/PlayerScroll/PlayerList
@onready var _coop_hint:     PanelContainer = $Margin/VBoxContainer/ContentRow/PlayersPanel/CoopHint
@onready var _coop_label:    Label          = $Margin/VBoxContainer/ContentRow/PlayersPanel/CoopHint/CoopLabel
@onready var _back_btn:      Button         = $Margin/VBoxContainer/BottomBar/Back
@onready var _start_btn:     Button         = $Margin/VBoxContainer/BottomBar/StartBtn

const VisualEnvironment := preload("res://scripts/VisualEnvironment.gd")

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	# "Two are better than one" – Ecclesiastes 4:9
	VisualEnvironment.add_scene_background(self, "lobby")

	# "Gather the Tribes" — all twelve drawn together  (Isaiah 43:5-6)
	const LOBBY_MUSIC := "res://assets/audio/music/gather_the_tribes.wav"
	AudioManager.play_music(LOBBY_MUSIC if ResourceLoader.exists(LOBBY_MUSIC) else "res://assets/audio/music/lobby.ogg")

	_host_btn.pressed.connect(_on_host)
	_join_btn.pressed.connect(_on_join)
	_back_btn.pressed.connect(_on_back)
	_start_btn.pressed.connect(_on_start_game)

	# MultiplayerLobby signals
	MultiplayerLobby.player_joined.connect(_on_player_joined)
	MultiplayerLobby.player_left.connect(_on_player_left)
	MultiplayerLobby.host_ready.connect(_on_host_ready)
	MultiplayerLobby.join_failed.connect(_on_join_failed)
	MultiplayerLobby.game_started.connect(_on_game_started)

	# If we already have a selected tribe (came from AvatarPick), pre-populate
	if Global.selected_tribe != "":
		_add_self_to_list()

# ─────────────────────────────────────────────────────────────────────────────
# BUTTON HANDLERS
# ─────────────────────────────────────────────────────────────────────────────
func _on_host() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	_set_status("Opening doors…")
	MultiplayerLobby.host()

func _on_join() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	var code := _code_entry.text.strip_edges()
	if code.is_empty():
		_set_status("Please enter the host's code or IP address.")
		return
	_set_status("Seeking the gathering place…")
	MultiplayerLobby.join(code)

func _on_back() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	MultiplayerLobby.leave()
	var result := get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	if result != OK:
		push_error("[Lobby] Failed to return to main menu. error=%d" % result)

func _on_start_game() -> void:
	# Host only — validated inside MultiplayerLobby.start_game()
	if MultiplayerLobby.get_player_count() < 1:
		_set_status("Wait for at least one other player to join, please.")
		return
	AudioManager.play_sfx("res://assets/audio/sfx/lobby_ready.wav")
	MultiplayerLobby.start_game()

# ─────────────────────────────────────────────────────────────────────────────
# MULTIPLAYER LOBBY SIGNAL HANDLERS
# ─────────────────────────────────────────────────────────────────────────────
func _on_host_ready(code: String) -> void:
	_code_display.visible = true
	_code_label.text = "Share this code: %s" % code
	_set_status("Lobby open! Share the code above.")
	_start_btn.visible = true
	_add_self_to_list()

func _on_join_failed(reason: String) -> void:
	_set_status(reason)

func _on_player_joined(peer_id: int, tribe: String, avatar: String, p_name: String) -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/lobby_join.wav")
	var tribe_data := Global.get_tribe_data(tribe)
	var col := Color(tribe_data.get("color", "#888888"))
	var display: String = tribe_data.get("display", tribe.capitalize())

	_add_player_row(peer_id, p_name, display, col)
	_set_status("%s of %s has joined. Shalom!" % [p_name if p_name != "" else "A child", display])
	_refresh_coop_hint()

func _on_player_left(peer_id: int) -> void:
	var row := _player_list.find_child(str(peer_id), false, false)
	if row:
		row.queue_free()
	_refresh_coop_hint()

func _on_game_started() -> void:
	# Scene change is handled by MultiplayerLobby._rpc_start_game
	pass

# ─────────────────────────────────────────────────────────────────────────────
# PLAYER LIST UI
# ─────────────────────────────────────────────────────────────────────────────
func _add_self_to_list() -> void:
	var tribe_data := Global.get_tribe_data(Global.selected_tribe)
	var col := Color(tribe_data.get("color", "#888888"))
	var display: String = tribe_data.get("display", "(no tribe)")
	_add_player_row(multiplayer.get_unique_id(), Global.player_name, display, col, true)

func _add_player_row(peer_id: int, p_name: String, tribe_display: String,
				   col: Color, is_self: bool = false) -> void:
	# Avoid duplicates
	if _player_list.find_child(str(peer_id), false, false) != null:
		return

	var row := HBoxContainer.new()
	row.name = str(peer_id)
	row.add_theme_constant_override("separation", 10)
	_player_list.add_child(row)

	# Colour swatch
	var swatch := ColorRect.new()
	swatch.color = col
	swatch.custom_minimum_size = Vector2(18, 18)
	row.add_child(swatch)

	# Name + tribe
	var lbl := Label.new()
	var suffix := " (you)" if is_self else ""
	lbl.text = "%s — Tribe of %s%s" % [p_name, tribe_display, suffix]
	lbl.add_theme_font_size_override("font_size", 15)
	row.add_child(lbl)

func _refresh_coop_hint() -> void:
	var action := MultiplayerLobby.get_active_coop_action()
	if action.is_empty():
		_coop_hint.visible = false
	else:
		_coop_label.text = "✦ Co-op available: %s\n%s" % [
			action.get("label", ""),
			action.get("desc", "")
		]
		_coop_hint.visible = true

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────
func _set_status(msg: String) -> void:
	_status_label.text = msg
