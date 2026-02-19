# Copilot Instructions for Twelve Stones — Ephod Quest

## Project Overview
"Twelve Stones" (Ephod Quest) is a mobile-first 2D biblical co-operative adventure built
with Godot Engine 4.3. Players choose one of 48 avatars across 12 tribes of Israel,
complete tribal quests, collect gemstones matching the high-priest's ephod
(Exodus 28), and memorise scripture. The finale is a courtyard scene where all
tribes weave their stones into the breastplate together.

**Core promise:** No violence, no stats, no power-ups, no loot. Only heart, unity,
and the joy of discovery.

---

## Technology Stack
- **Engine**: Godot 4.3  (use only Godot 4.x APIs)
- **Language**: GDScript  (typed where possible)
- **Architecture**: Scene-based + autoload singletons
- **Networking**: ENet peer-to-peer, port 7777, max 12 players
- **Target platforms**: Android (min SDK 24), iOS, PC, Web

---

## Project Structure
```
ephod-quest/
├── scenes/          # .tscn scene files
├── scripts/         # .gd GDScript files
│   ├── Global.gd          # ALL game state + TRIBES/AVATARS data
│   ├── MultiplayerLobby.gd
│   ├── AudioManager.gd
│   ├── VerseVault.gd      # Collectible verse catalogue
│   ├── QuestBase.gd       # Base class for all Quest scripts
│   ├── TouchControls.gd   # Virtual joystick
│   └── Quest1-12.gd, Finale.gd, ...
├── DOCS/            # Design documents
└── export_presets.cfg
```

---

## Autoload Singletons

| Autoload           | Purpose                                          |
|--------------------|--------------------------------------------------|
| `Global`           | Selected tribe/avatar, stones, verses, save/load |
| `MultiplayerLobby` | ENet host/join, player registry, co-op detection |
| `AudioManager`     | Cross-fade music, one-shot SFX                   |
| `VerseVault`       | Verse catalogue, unlock/memorise API             |

Always route shared state through `Global`. Never store game state in individual
scene scripts.

---

## Biblical Fidelity Rules

1. **Never use the words "temple" or "church"** when describing visual settings.
   Use physical descriptors only:
   - ✅ "gold-plated cedar pillars", "blue and purple and scarlet curtains",
         "a thick veil with embroidered cherubim", "the seven-flame lampstand"
   - ❌ "the temple", "the church building", "the sanctuary" (word)

2. **All scripture must be accurate** — copy from NIV or KJV exactly. Never
   paraphrase or invent a verse. Always include the reference (e.g. "John 3:16").

3. **Nature-science facts must be real** — firefly bioluminescence, eagle eyesight,
   lion roar range, butterfly migration. Source from established biology.

4. **Elder dialogue tone**:
   - Elders always say: "My child…", "God sees your heart", "Shalom, shalom",
     "Well done", "That is the gift of [tribe]"
   - Children/players say: "Please, Elder [name]…", "Thank you", "Shalom"
   - Never condescending. Never preachy. Warm, narrative, inviting.

5. **Tribe order** (Exodus 28 ephod row order):
   reuben → simeon → levi → judah → dan → naphtali →
   gad → asher → issachar → zebulun → joseph → benjamin

---

## Gameplay Rules (NEVER violate)

- **No magic** — All mechanics are physical: tapping, rhythm, holding, pattern recognition
- **No damage / HP** — Failure is gentle: "Let's try again. God is patient."
- **No stats or power-ups** — Avatar bonuses are narrative (e.g. "Ezra hears rhythms more clearly")
- **No loot** — Only collectibles: 1 gemstone + 1 verse per quest
- **Co-op is cross-tribe** — Multiplayer bonuses only activate when DIFFERENT tribes
  work together (never same-tribe stacking)

---

## GDScript Style

```gdscript
# ✅ Correct
extends Control

@export var tribe_key: String = ""

func _ready() -> void:
    $Button.pressed.connect(func(): _do_something())

func _do_something() -> void:
    pass
```

- **snake_case** for vars and functions
- **PascalCase** for class names and scene file names
- Always annotate return types on public functions
- Always check scene change results:

```gdscript
var res := get_tree().change_scene_to_file("res://scenes/Lobby.tscn")
if res != OK:
    push_error("Failed to change scene")
```

---

## Mobile / Touch First

- All Control nodes use `anchors_preset = 15` (full-rect) where appropriate
- Minimum touch target size: **44 × 44 px** (`custom_minimum_size`)
- Virtual joystick is `TouchControls.gd` — attach to CanvasLayer, bottom-left
- `Global._input()` translates `InputEventScreenDrag` to action presses
- Stretch mode: `canvas_items` / `expand` aspect — already set in `project.godot`

---

## Quest Architecture

All quest scripts extend `QuestBase.gd`:

```gdscript
extends "res://scripts/QuestBase.gd"

func _ready() -> void:
    tribe_key  = "reuben"
    quest_id   = "reuben_main"
    next_scene = "res://scenes/Quest2.tscn"
    music_path = "res://assets/audio/music/quest_theme.ogg"
    super._ready()

func on_quest_ready() -> void:
    show_dialogue([
        {"name": "Hanoch", "text": "My child, shalom…"},
        {"name": "You",    "text": "Please, elder…",
         "callback": Callable(self, "_start_mini")}
    ])
```

**QuestBase hooks to override:**
- `on_quest_ready()` — called after UI is built and music starts
- `on_minigame_complete(result: Dictionary)` — called by base mini-game builders
- `on_minigame_timeout(result: Dictionary)` — called on time-out

**QuestBase helpers available:**
- `show_dialogue(lines)` — queued dialogue panel
- `show_verse_scroll(ref, text)` — memorisation scroll popup
- `show_nature_fact()` — auto-reads from tribe data
- `build_tap_minigame(parent, goal, prompt, time_limit)` → result dict
- `build_rhythm_minigame(parent, beat_dur, beats, goal, prompt)` → result dict
- `_collect_stone()` → glow animation → `_fade_out_and_change(next_scene)`

---

## Multiplayer

- `MultiplayerLobby.host()` — host a game (emits `host_ready(ip_code)`)
- `MultiplayerLobby.join(code)` — join a game (emits `join_failed(reason)` on error)
- `players: Dictionary` — `peer_id → {name, tribe, avatar, stones}`
- Co-op actions in `Global.COOP_ACTIONS`:
  - Keys are `"tribe1_tribe2"` (alphabetical), value has `gift` and `bonus` strings
- RPC decorators: `@rpc("any_peer", "call_remote", "reliable")`

---

## Visual Style

**Earth & Gold palette**:

| Token            | Hex       | Use                        |
|------------------|-----------|----------------------------|
| Desert Sand      | `#E9D5B3` | Background warmth          |
| Clay Brown       | `#8B6F47` | Ground, earth tones        |
| Olive Green      | `#6B7A4F` | Vegetation                 |
| Pure Gold        | `#FFD700` | Ephod, gems, highlights    |
| Antique Gold     | `#C5A572` | UI borders, pillar accents |

Soft pastel cartoon aesthetic. Calming, diverse, welcoming.
Avoid harsh contrasts or dark ominous tones.

---

## Diversity & Representation

- All 48 avatars have **varied skin, hair, eyes, builds, ages (12–29)**
- No stereotype casting — any tribe can have any skill
- Avatar gameplay edges are **narrative bonuses**, not stat modifiers
- Ages deliberately include 12–18 so younger players see themselves

---

## Common Tasks

### Add a new Quest (tribe N)

1. Create `scenes/QuestN.tscn` — landscape matching tribe geography
2. Create `scripts/QuestN.gd` — `extends "res://scripts/QuestBase.gd"`
3. Set `tribe_key`, `quest_id`, `next_scene`, `music_path` in `_ready()`
4. Implement `on_quest_ready()` with elder dialogue + mini-game sequence
5. Add route in `AvatarPick.gd` → `_quest_scenes` dict

### Add a verse to VerseVault

Edit `scripts/VerseVault.gd` → `VAULT` array. Each entry:
```gdscript
{"tribe": "judah", "type": "quest",   "ref": "Psalm 100:1",  "text": "…"},
{"tribe": "judah", "type": "nature",  "ref": "Revelation 5:5","text": "…", "fact": "…"},
```

### Add an avatar

Edit `Global.gd` → `AVATARS` dict. Each avatar entry:
```gdscript
"key_name": {
    "key": "key_name", "tribe": "tribe_key", "name": "Name",
    "age": 17, "skin": "medium", "hair": "black curly", "eyes": "brown",
    "build": "lean", "backstory": "…", "gameplay_edge": "…"
}
```


## Project Structure
```
ephod-quest/
├── scenes/          # Game scenes (.tscn files)
├── scripts/         # GDScript files (.gd files)
├── DOCS/           # Comprehensive game documentation
└── project.godot   # Godot project configuration
```

## Key Conventions

### Scene Management
- Main scene: `res://scenes/MainMenu.tscn`
- Use `get_tree().change_scene_to_file()` for scene transitions with full `res://` paths
- Always check for errors when changing scenes:
  ```gdscript
  var result = get_tree().change_scene_to_file("res://scenes/NextScene.tscn")
  if result != OK:
      push_error("Failed to change scene")
  ```

### Autoload Singletons
- **Global**: Game state management (tribes, avatars, stones, verses)
  - Access via `Global.selected_tribe`, `Global.stones`, etc.
- **MultiplayerLobby**: Network management
  - Use `MultiplayerLobby.host()` and `MultiplayerLobby.join(code)` for networking

### GDScript Style
- Use `extends Node` or appropriate base class
- Connect signals in `_ready()` using lambda functions:
  ```gdscript
  $Button.pressed.connect(func(): do_something())
  ```
- Use snake_case for variables and functions
- Use PascalCase for class names and scene names

### Node Structure (Godot 4.x)
- Control nodes require `layout_mode` property when using `anchors_preset`
- Scene files are in `.tscn` format, scripts in `.gd` format

### Input Handling
- Use predefined input actions: `move_left`, `move_right`, `move_up`, `move_down`
- WASD and Arrow keys are mapped for movement
- Check inputs with `Input.is_action_pressed("action_name")`

### Error Handling
- All scene transitions should include error checking
- Network operations return OK/error codes - always check them
- Use `push_error()` for logging failures

### Networking
- Multiplayer uses ENet protocol
- RPC calls should be decorated with `@rpc("any_peer")` or appropriate authority
- Sync game state through `Global` autoload
- Handle both peer_connected and peer_disconnected signals

## Best Practices

### When Adding Features
1. Check existing patterns in similar scenes/scripts first
2. Use the autoload singletons for shared state
3. Follow the existing scene navigation patterns
4. Test both single-player and multiplayer scenarios if relevant

### When Modifying Code
1. Maintain consistency with existing code style
2. Don't break scene transitions or autoload dependencies
3. Preserve error handling patterns
4. Keep multiplayer synchronization working

### Visual Style
- Game uses "Earth & Gold" aesthetic with warm earth tones
- Primary colors: Desert Sand (#E9D5B3), Clay Brown (#8B6F47), Olive Green (#6B7A4F)
- Gold accents: Pure Gold (#FFD700), Antique Gold (#C5A572)
- Evokes ancient Middle Eastern biblical setting

### Testing
- Test scene transitions work correctly
- Verify multiplayer functionality if networking code is modified
- Check that Global state persists across scenes
- Ensure input actions work as expected

## Biblical Context
The game is built around the 12 tribes of Israel, with each tribe having unique quests and mini-games. Content should be biblically accurate and appropriate for the theme. Refer to DOCS/ directory for detailed game design documents.

## Documentation
Comprehensive documentation is available in the DOCS/ directory:
- GDD.md: Game Design Document
- QUEST_CONCEPTS.md: Tribal mini-games and mechanics
- STYLE_GUIDE.md: Visual and audio guidelines
- TECHNICAL_SPECS.md: Technical implementation details

## Common Tasks

### Adding a New Scene
1. Create `.tscn` file in `scenes/` directory
2. Create corresponding `.gd` script in `scripts/` directory
3. Use `extends Control` or appropriate base class
4. Implement navigation to/from existing scenes

### Adding Global State
1. Add variables to `scripts/Global.gd`
2. Implement getter/setter functions if needed
3. Sync in multiplayer using RPC if necessary

### Adding Input Actions
1. Define in `project.godot` under `[input]` section
2. Map to appropriate keys/buttons
3. Use in scripts with `Input.is_action_pressed()`

### Connecting to Multiplayer
1. Use `MultiplayerLobby.host()` to create a game
2. Use `MultiplayerLobby.join(code)` to join a game
3. Handle peer_connected/peer_disconnected signals
4. Sync state through Global autoload

## Important Notes
- This is a Godot 4.3 project - use Godot 4.x APIs and patterns
- GDScript syntax and features are from Godot 4.x
- The project uses scene-based architecture, not a single main loop
- Multiplayer is peer-to-peer using ENet
- All game state should flow through the Global autoload for proper synchronization
