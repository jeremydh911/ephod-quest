extends Control
# ─────────────────────────────────────────────────────────────────────────────
# MainMenu.gd  –  Twelve Stones / Ephod Quest
# Entry point: Start (→ AvatarPick), Multiplayer (→ Lobby), Quit.
# "I am the way and the truth and the life" – John 14:6
# ─────────────────────────────────────────────────────────────────────────────

@onready var _fade_rect: ColorRect

func _ready() -> void:
	AudioManager.play_music("res://assets/audio/music/main_menu.ogg")

	# Create fade rectangle for transitions
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.set_anchors_preset(LayoutPreset.FULL_RECT)
	_fade_rect.z_index = 100
	add_child(_fade_rect)

	# Check for existing save
	Global.load_game()
	$VBoxContainer/Continue.visible = Global.stones.size() > 0

	# Connect buttons
	$VBoxContainer/Continue.pressed.connect(_on_continue)
	$VBoxContainer/Start.pressed.connect(_on_start)
	$VBoxContainer/VerseVault.pressed.connect(_on_verse_vault)
	$VBoxContainer/Multiplayer.pressed.connect(_on_multiplayer)
	$VBoxContainer/Support.pressed.connect(_on_support)
	$VBoxContainer/Quit.pressed.connect(_on_quit)

func _on_continue() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	await _fade_out()
	var result := get_tree().change_scene_to_file("res://scenes/AvatarPick.tscn")
	if result != OK:
		push_error("[MainMenu] Failed to load AvatarPick.tscn — error %d" % result)

func _on_start() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	# Clear any existing save for new journey
	Global.selected_tribe = ""
	Global.selected_avatar = ""
	Global.stones.clear()
	Global.memorized_verses.clear()
	Global.completed_quests.clear()
	Global.journal_entries.clear()
	Global.heart_badges.clear()
	await _fade_out()
	var result := get_tree().change_scene_to_file("res://scenes/AvatarPick.tscn")
	if result != OK:
		push_error("[MainMenu] Failed to load AvatarPick.tscn — error %d" % result)

func _on_verse_vault() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	await _fade_out()
	var result := get_tree().change_scene_to_file("res://scenes/VerseVaultScene.tscn")
	if result != OK:
		push_error("[MainMenu] Failed to load VerseVaultScene.tscn — error %d" % result)

func _on_multiplayer() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	await _fade_out()
	var result := get_tree().change_scene_to_file("res://scenes/Lobby.tscn")
	if result != OK:
		push_error("[MainMenu] Failed to load Lobby.tscn — error %d" % result)

func _on_support() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	var dialog := AcceptDialog.new()
	dialog.title = "Support Twelve Stones"
	dialog.dialog_text = "Enjoying the game? Your voluntary donations help us continue developing educational adventures!\n\nKo-fi: ko-fi.com/ephodquest\nPayPal: paypal.me/ephodquest\n\nThank you for your generosity!"
	add_child(dialog)
	dialog.popup_centered()

func _on_quit() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/click.wav")
	await _fade_out()
	get_tree().quit()

func _fade_out() -> void:
	var tw := create_tween()
	tw.tween_property(_fade_rect, "color:a", 1.0, 0.5)
	await tw.finished
