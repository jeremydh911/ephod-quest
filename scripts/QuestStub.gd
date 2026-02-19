extends "res://scripts/QuestBase.gd"
# ─────────────────────────────────────────────────────────────────────────────
# QuestStub.gd  –  Placeholder for quests not yet implemented.
# Shows tribe elder greeting + "Coming soon" message + return button.
# Set tribe_key and next_scene as @export in the .tscn file.
# ─────────────────────────────────────────────────────────────────────────────

func on_quest_ready() -> void:
	var elder: String = _tribe_data.get("elder", "Elder")
	var tribe_display: String = _tribe_data.get("display", tribe_key.capitalize())
	show_dialogue([
		{
			"name": elder,
			"text": "Shalom, shalom! Welcome to the land of %s. Our quest is being prepared — the elders are still writing the story." % tribe_display
		},
		{
			"name": elder,
			"text": "God sees your heart for coming. Return soon, my child. Until then, the Verse Vault holds what has already been given.",
			"callback": Callable(self, "_show_return_button")
		}
	])

func _show_return_button() -> void:
	var btn := Button.new()
	btn.text = "← Return to Tribe Selection"
	btn.custom_minimum_size = Vector2(0, 56)
	btn.add_theme_font_size_override("font_size", 18)
	$MiniGameContainer.visible = true
	$MiniGameContainer.add_child(btn)
	btn.pressed.connect(func():
		var res := get_tree().change_scene_to_file("res://scenes/AvatarPick.tscn")
		if res != OK:
			push_error("QuestStub: failed to return to AvatarPick")
	)
