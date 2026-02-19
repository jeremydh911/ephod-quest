extends "res://scripts/QuestBase.gd"

var _phase: String = ""

func _ready() -> void:
    tribe_key  = "zebulun"
    quest_id   = "zebulun_main"
    next_scene = "res://scenes/Quest11.tscn"
    music_path = "res://assets/audio/music/quest_theme.ogg"
    super._ready()

func on_quest_ready() -> void:
    show_dialogue([
        {"name": "Ahira", "text": "My child, shalom…"},
        {"name": "Ahira", "text": "I am Ahira, elder of Zebulun. We dwell by the seashore, a haven for ships from afar."},
        {"name": "Ahira", "text": "Our blessing speaks of dwelling by the sea, and being a haven for ships. We welcome strangers and provide safe harbor."},
        {"name": "Ahira", "text": "To learn our ways, you must navigate treacherous waters and show hospitality to those in need."},
        {"name": "You",    "text": "Please, elder Ahira… I am ready to learn."},
        {"name": "Ahira", "text": "Very well. First, guide our ship through the storm-tossed waves. Then, welcome the weary travelers with open arms.",
         "callback": Callable(self, "_start_sailing")}
    ])

func _start_sailing() -> void:
    _phase = "sailing"
    build_sailing_minigame(
        $MiniGameContainer,
        "Guide the ship through the waves! Tap to steer, hold to maintain course.",
        30.0  # 30 seconds
    )

func _on_sailing_complete(result: Dictionary) -> void:
    if result.get("success", false):
        show_dialogue([
            {"name": "Ahira", "text": "Well done! You navigated the waters skillfully, just as Zebulun does."},
            {"name": "Ahira", "text": "Now, show hospitality. Welcome the travelers and provide for their needs."},
            {"name": "You",    "text": "I will do my best, elder."},
            {"name": "Ahira", "text": "Remember: 'Do not forget to show hospitality to strangers, for by so doing some people have shown hospitality to angels without knowing it.' - Hebrews 13:2",
             "callback": Callable(self, "_start_hospitality")}
        ])
    else:
        show_dialogue([
            {"name": "Ahira", "text": "The waves were challenging, but let's try again. God is patient."},
            {"name": "You",    "text": "Please, elder… I will try once more."},
            {"name": "Ahira", "text": "Take heart, my child. The sea teaches us perseverance.",
             "callback": Callable(self, "_start_sailing")}
        ])

func _start_hospitality() -> void:
    _phase = "hospitality"
    build_hospitality_minigame(
        $MiniGameContainer,
        "Welcome the travelers! Match their needs with the gifts available.",
        25.0  # 25 seconds
    )

func on_minigame_complete(result: Dictionary) -> void:
    if _phase == "sailing":
        _on_sailing_complete(result)
    elif _phase == "hospitality":
        _on_hospitality_complete(result)

func _on_hospitality_complete(result: Dictionary) -> void:
    if result.get("success", false):
        show_dialogue([
            {"name": "Ahira", "text": "Beautiful! You have shown true hospitality, welcoming strangers as we do."},
            {"name": "Ahira", "text": "This is the gift of Zebulun - to be a haven for ships and a blessing to all who come to our shores."},
            {"name": "Ahira", "text": "Well done, my child. God sees your heart."},
            {"name": "You",    "text": "Thank you, elder Ahira. Shalom."},
            {"name": "Ahira", "text": "Shalom, shalom. May you always find safe harbor in God's love.",
             "callback": Callable(self, "_complete_quest")}
        ])
    else:
        show_dialogue([
            {"name": "Ahira", "text": "Hospitality takes practice, but your heart is in the right place."},
            {"name": "Ahira", "text": "Let's try welcoming the travelers again. Remember, small acts of kindness matter.",
             "callback": Callable(self, "_start_hospitality")}
        ])

func _complete_quest() -> void:
    show_verse_scroll("Hebrews 13:2", "Do not forget to show hospitality to strangers, for by so doing some people have shown hospitality to angels without knowing it.")
    await get_tree().create_timer(3.0).timeout
    _collect_stone()