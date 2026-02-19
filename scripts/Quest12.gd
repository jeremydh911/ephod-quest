extends "res://scripts/QuestBase.gd"

func _ready() -> void:
    tribe_key  = "benjamin"
    quest_id   = "benjamin_main"
    next_scene = "res://scenes/Finale.tscn"
    music_path = "res://assets/audio/music/quest_theme.ogg"
    super._ready()

func on_quest_ready() -> void:
    show_dialogue([
        {"name": "Shalom", "text": "My child, shalom…"},
        {"name": "Shalom", "text": "I am Shalom, elder of Benjamin. We are the youngest, but our blessing speaks of dwelling safely between God's shoulders."},
        {"name": "Shalom", "text": "Benjamin means 'son of my right hand' - we protect what is precious and strike with precision when needed."},
        {"name": "Shalom", "text": "To learn our ways, you must show precision in your actions and protect those in your care."},
        {"name": "You",    "text": "Please, elder Shalom… I am ready to learn."},
        {"name": "Shalom", "text": "Very well. First, demonstrate precision. Then, show you can protect what matters most.",
         "callback": Callable(self, "_start_precision")}
    ])

func _start_precision() -> void:
    var precision_game := build_precision_minigame(
        $MiniGameContainer,
        "Strike with precision! Hit the targets exactly in the center.",
        30.0  # 30 seconds
    )
    precision_game.connect("minigame_complete", Callable(self, "_on_precision_complete"))

func _on_precision_complete(result: Dictionary) -> void:
    if result.get("success", false):
        show_dialogue([
            {"name": "Shalom", "text": "Excellent precision! You strike like Benjamin - accurate and true."},
            {"name": "Shalom", "text": "Now, the greater test: protection. Guard what is precious from harm."},
            {"name": "You",    "text": "I will protect with all my heart, elder."},
            {"name": "Shalom", "text": "Remember: 'The Lord will keep you from all harm - he will watch over your life.' - Psalm 121:7",
             "callback": Callable(self, "_start_protection")}
        ])
    else:
        show_dialogue([
            {"name": "Shalom", "text": "Precision comes with practice, but your aim improves with each try."},
            {"name": "You",    "text": "Please, elder… I will try for better accuracy."},
            {"name": "Shalom", "text": "Take heart, my child. Even the youngest learns to strike true.",
             "callback": Callable(self, "_start_precision")}
        ])

func _start_protection() -> void:
    var protection_game := build_protection_minigame(
        $MiniGameContainer,
        "Protect the precious ones! Block the threats and keep them safe.",
        25.0  # 25 seconds
    )
    protection_game.connect("minigame_complete", Callable(self, "_on_protection_complete"))

func _on_protection_complete(result: Dictionary) -> void:
    if result.get("success", false):
        show_dialogue([
            {"name": "Shalom", "text": "Well done! You have protected what is precious, just as Benjamin protects his people."},
            {"name": "Shalom", "text": "This is the gift of Benjamin - to dwell safely under God's protection and to be a guardian for others."},
            {"name": "Shalom", "text": "You have completed all twelve quests! The stones are gathered. Now, the greatest journey begins."},
            {"name": "Shalom", "text": "Well done, my child. God sees your heart."},
            {"name": "You",    "text": "Thank you, elder Shalom. Shalom."},
            {"name": "Shalom", "text": "Shalom, shalom. May you always dwell between God's shoulders.",
             "callback": Callable(self, "_complete_quest")}
        ])
    else:
        show_dialogue([
            {"name": "Shalom", "text": "Protection requires vigilance, but your care for others shines through."},
            {"name": "Shalom", "text": "Let's try protecting the precious ones once more. Remember, God watches over us all.",
             "callback": Callable(self, "_start_protection")}
        ])

func _complete_quest() -> void:
    show_verse_scroll("Psalm 121:7", "The Lord will keep you from all harm - he will watch over your life.")
    await get_tree().create_timer(3.0).timeout
    _collect_stone()