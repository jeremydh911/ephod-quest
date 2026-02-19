extends "res://scripts/QuestBase.gd"

var _phase: String = ""

func _ready() -> void:
    tribe_key  = "joseph"
    quest_id   = "joseph_main"
    next_scene = "res://scenes/Quest12.tscn"
    music_path = "res://assets/audio/music/quest_theme.ogg"
    super._ready()

func on_quest_ready() -> void:
    show_dialogue([
        {"name": "Eran", "text": "My child, shalom…"},
        {"name": "Eran", "text": "I am Eran, elder of Joseph. We are blessed with fruitfulness and leadership among our brothers."},
        {"name": "Eran", "text": "Joseph's story teaches us about forgiveness, leadership, and God's provision even in difficult times."},
        {"name": "Eran", "text": "To learn our ways, you must nurture growth and choose the path of forgiveness."},
        {"name": "You",    "text": "Please, elder Eran… I am ready to learn."},
        {"name": "Eran", "text": "Very well. First, tend to the garden and help it grow abundantly. Then, face the choice of forgiveness.",
         "callback": Callable(self, "_start_growth")}
    ])

func _start_growth() -> void:
    _phase = "growth"
    build_growth_minigame(
        $MiniGameContainer,
        "Nurture the garden! Water the plants, remove weeds, and help them grow.",
        35.0  # 35 seconds
    )

func _on_growth_complete(result: Dictionary) -> void:
    if result.get("success", false):
        show_dialogue([
            {"name": "Eran", "text": "Beautiful! The garden flourishes under your care, just as Joseph brought fruitfulness to Egypt."},
            {"name": "Eran", "text": "Now, face the greater challenge. Joseph forgave his brothers who sold him into slavery."},
            {"name": "Eran", "text": "Will you choose the path of bitterness or the path of forgiveness?"},
            {"name": "You",    "text": "I will choose forgiveness, elder."},
            {"name": "Eran", "text": "Remember: 'Be kind and compassionate to one another, forgiving each other, just as in Christ God forgave you.' - Ephesians 4:32",
             "callback": Callable(self, "_start_forgiveness")}
        ])
    else:
        show_dialogue([
            {"name": "Eran", "text": "Growth takes patience, but the seeds of potential are there."},
            {"name": "You",    "text": "Please, elder… I will tend the garden once more."},
            {"name": "Eran", "text": "Take heart, my child. Even in dry seasons, God provides.",
             "callback": Callable(self, "_start_growth")}
        ])

func _start_forgiveness() -> void:
    _phase = "forgiveness"
    build_forgiveness_minigame(
        $MiniGameContainer,
        "Choose wisely: Hold onto anger or extend forgiveness?",
        20.0  # 20 seconds
    )

func on_minigame_complete(result: Dictionary) -> void:
    if _phase == "growth":
        _on_growth_complete(result)
    elif _phase == "forgiveness":
        _on_forgiveness_complete(result)

func _on_forgiveness_complete(result: Dictionary) -> void:
    if result.get("success", false):
        show_dialogue([
            {"name": "Eran", "text": "Yes! You have chosen the path of Joseph - forgiveness and reconciliation."},
            {"name": "Eran", "text": "This is the gift of Joseph - to be a blessing to others, even when wronged, and to lead with wisdom and compassion."},
            {"name": "Eran", "text": "Well done, my child. God sees your heart."},
            {"name": "You",    "text": "Thank you, elder Eran. Shalom."},
            {"name": "Eran", "text": "Shalom, shalom. May you be fruitful in every good work.",
             "callback": Callable(self, "_complete_quest")}
        ])
    else:
        show_dialogue([
            {"name": "Eran", "text": "Forgiveness is difficult, but it frees the heart from bitterness."},
            {"name": "Eran", "text": "Let's reflect on Joseph's choice again. He said to his brothers: 'You intended to harm me, but God intended it for good.'",
             "callback": Callable(self, "_start_forgiveness")}
        ])

func _complete_quest() -> void:
    show_verse_scroll("Ephesians 4:32", "Be kind and compassionate to one another, forgiving each other, just as in Christ God forgave you.")
    await get_tree().create_timer(3.0).timeout
    _collect_stone()