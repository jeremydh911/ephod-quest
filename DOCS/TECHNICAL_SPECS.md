# Technical Specifications for Twelve Stones

## Overview

This document provides comprehensive technical specifications for asset creation, code standards, and implementation requirements for *Twelve Stones* in Godot 4.3.

---

## Asset Requirements

### 2D Graphics

#### File Formats
- **Primary:** PNG (with transparency)
- **Vector:** SVG (for scalable UI elements)
- **Atlases:** PNG sprite sheets with metadata

#### Resolution Standards
```
UI Elements:
  - Icons: 128x128, 256x256, 512x512 (multiple sizes)
  - Buttons: 256x64 (standard), scalable
  - Backgrounds: 1920x1080 (base), 4K supported
  - Character Portraits: 512x512

Game Sprites:
  - Player Character: 64x64 (base), up to 128x128
  - NPCs/Elders: 128x128 or 256x256
  - Environmental Objects: Variable (32x32 to 256x256)
  - Effects/Particles: 32x32 to 128x128

Mobile Optimization:
  - All assets should have 0.5x versions for low-end devices
  - Use texture compression (BPTC, ETC2)
```

#### Color Specifications
- **Bit Depth:** 32-bit RGBA
- **Color Space:** sRGB
- **Alpha:** Use for transparency, not pre-multiplied
- **Compression:** PNG with optimal compression

#### Naming Conventions
```
sprites/
  ├── characters/
  │   ├── player_idle_01.png
  │   ├── player_walk_01.png
  │   └── elder_reuben_portrait.png
  ├── ui/
  │   ├── btn_primary_normal.png
  │   ├── btn_primary_pressed.png
  │   └── icon_stone_reuben.png
  └── environment/
      ├── tile_grass_01.png
      └── prop_tent_large.png
```

### 3D Assets (Future/Optional)

#### File Formats
- **Primary:** GLB (binary glTF)
- **Alternative:** GLTF (text format for version control)
- **Not Supported:** FBX, OBJ (convert to GLB)

#### Specifications
```
Memorial Stones (3D):
  - Polygon Count: 500-2000 tris per stone
  - Texture Size: 1024x1024 (diffuse, normal, roughness)
  - Material: PBR workflow
  - Scale: Real-world proportions

Environment Props:
  - Low Poly Style: Maintain aesthetic
  - LOD Levels: 3 (High, Medium, Low)
  - Collision Meshes: Simplified, separate
```

#### Naming Conventions
```
models/
  ├── stones/
  │   ├── stone_reuben.glb
  │   └── stone_reuben_lod1.glb
  └── environment/
      └── tent_large.glb
```

---

## Audio Requirements

### Sound Formats

#### Music
- **Format:** OGG Vorbis (primary)
- **Alternative:** MP3 (if size critical, but OGG preferred)
- **Sample Rate:** 44.1 kHz
- **Bit Rate:** 128-192 kbps VBR
- **Channels:** Stereo
- **Loop Points:** Seamless loops with metadata

#### Sound Effects
- **Format:** WAV (uncompressed) or OGG
- **Sample Rate:** 44.1 kHz (22.05 kHz for small effects)
- **Bit Depth:** 16-bit
- **Channels:** Mono (for positional audio) or Stereo
- **Length:** Keep under 5 seconds for most SFX

#### Voice Acting (Optional)
- **Format:** OGG Vorbis
- **Sample Rate:** 44.1 kHz
- **Bit Rate:** 96-128 kbps
- **Channels:** Mono
- **Processing:** Normalized, noise-reduced, EQ'd

### Audio Guidelines

```
Music Tracks:
  - Menu Theme: 2-3 minute loop
  - World Map Theme: 3-4 minute loop  
  - Tribal Themes: 2-3 minutes each (12 tracks)
  - Victory/Completion: 1-2 minute stinger
  
Sound Effects Categories:
  - UI Sounds: Button clicks, transitions, notifications
  - Gameplay: Mini-game specific sounds
  - Ambient: Environmental loops (wind, water, marketplace)
  - Celebration: Achievement unlocks, stone collection
  
Volume Guidelines:
  - Music: -6 dB to -3 dB peak
  - SFX: -12 dB to -6 dB peak
  - Voice: -3 dB to 0 dB peak (prioritized)
```

### Naming Conventions
```
audio/
  ├── music/
  │   ├── theme_menu.ogg
  │   ├── theme_tribe_reuben.ogg
  │   └── victory_complete.ogg
  ├── sfx/
  │   ├── ui_button_click.wav
  │   ├── game_stone_collect.wav
  │   └── ambient_wind_loop.ogg
  └── voice/ (if implemented)
      ├── elder_reuben_intro_01.ogg
      └── narrator_verse_gen49_3.ogg
```

---

## Font Requirements

### Primary Fonts

#### UI Font
```
Requirements:
  - TrueType (TTF) or OpenType (OTF)
  - Full Latin character set
  - Hinting optimized for screen rendering
  - License: Commercial use allowed
  - Sizes: 12, 16, 20, 24, 32, 48 (pre-rendered)
```

#### Hebrew Font
```
Requirements:
  - Hebrew Unicode block (U+0590 to U+05FF)
  - Right-to-left (RTL) support
  - Nikud (vowel points) support
  - Clean, readable design
  - License: Commercial use allowed
```

#### Scripture Font
```
Requirements:
  - Serif or traditional style
  - Highly readable
  - Multiple weights (Regular, Bold)
  - Good kerning
```

### Recommended Fonts

```
UI:
  - Noto Sans (Google Fonts - Open Source)
  - Roboto (Google Fonts - Open Source)
  - Open Sans (Google Fonts - Open Source)

Hebrew:
  - Noto Sans Hebrew (Google Fonts - Open Source)
  - Alef (Google Fonts - Open Source)
  - Frank Ruhl Libre (Google Fonts - Open Source)

Scripture:
  - Noto Serif (Google Fonts - Open Source)
  - Crimson Text (Google Fonts - Open Source)
  - EB Garamond (Google Fonts - Open Source)
```

### Implementation in Godot

```gdscript
# Load font
var font = load("res://assets/fonts/NotoSans-Regular.ttf")

# Create dynamic font
var dynamic_font = FontFile.new()
dynamic_font.font_data = font

# Use in Label
$Label.add_theme_font_override("font", dynamic_font)
$Label.add_theme_font_size_override("font_size", 24)
```

---

## Code Standards

### GDScript Style Guide

#### File Structure
```gdscript
# File header comment
# filename: TribeName.gd
# Purpose: Brief description
# Author: (optional)
# Date: (optional)

extends Node2D  # or appropriate base class

# === CONSTANTS ===
const TRIBE_NAME = "Reuben"
const MAX_SCORE = 1000

# === EXPORTS (Inspector editable) ===
@export var difficulty: String = "Bronze"
@export var time_limit: float = 60.0

# === SIGNALS ===
signal game_completed(score: int)
signal game_failed()

# === ONREADY VARIABLES ===
@onready var score_label = $UI/ScoreLabel
@onready var timer = $GameTimer

# === PRIVATE VARIABLES ===
var _current_score: int = 0
var _is_game_active: bool = false

# === LIFECYCLE METHODS ===
func _ready():
    initialize_game()
    connect_signals()

func _process(delta):
    if _is_game_active:
        update_game_logic(delta)

func _input(event):
    handle_input(event)

# === PUBLIC METHODS ===
func start_game():
    _is_game_active = true
    timer.start()

func end_game():
    _is_game_active = false
    emit_signal("game_completed", _current_score)

# === PRIVATE METHODS ===
func initialize_game():
    _current_score = 0
    update_ui()

func update_game_logic(delta):
    # Game-specific logic here
    pass

func connect_signals():
    timer.timeout.connect(_on_timer_timeout)

# === SIGNAL CALLBACKS ===
func _on_timer_timeout():
    end_game()
```

#### Naming Conventions
```gdscript
# Variables
var player_health: int = 100  # snake_case
var _private_value: float = 0.0  # prefix with _

# Constants
const MAX_PLAYERS = 4  # SCREAMING_SNAKE_CASE
const DEFAULT_SPEED = 200.0

# Functions
func calculate_score() -> int:  # snake_case, return type
    return _current_score

func _private_function() -> void:  # prefix with _
    pass

# Signals
signal player_damaged(amount: int)  # snake_case, typed parameters
signal game_state_changed

# Classes
class PlayerData:  # PascalCase
    var name: String
    var score: int
```

#### Type Hinting
```gdscript
# Always use type hints for clarity and performance
var health: int = 100
var speed: float = 250.0
var player_name: String = "Player"
var is_active: bool = false

# Function parameters and return types
func deal_damage(target: Node, amount: int) -> bool:
    if target.has_method("take_damage"):
        target.take_damage(amount)
        return true
    return false

# Arrays and dictionaries
var player_scores: Array[int] = [0, 0, 0, 0]
var tribe_data: Dictionary = {}
```

#### Comments
```gdscript
# Single-line comments for brief explanations
# Use above the code, not at the end of lines

## Documentation comments for functions
## Describe what the function does, parameters, and return value
func calculate_final_score(base: int, multiplier: float) -> int:
    ## Calculates the final score based on base score and multiplier
    ## Parameters:
    ##   base: The base score before multiplier
    ##   multiplier: The score multiplier (1.0 = normal, 2.0 = double)
    ## Returns:
    ##   The final calculated score as an integer
    return int(base * multiplier)
```

---

## Mini-Game Code Templates

### Basic Mini-Game Template

```gdscript
# minigame_template.gd
extends Node2D

# === CONFIGURATION ===
const TRIBE_NAME: String = "TribeName"
const KEY_SCRIPTURE: String = "Book Chapter:Verse"
const SCRIPTURE_TEXT: String = "Full scripture quote here"

# === DIFFICULTY SETTINGS ===
const DIFFICULTY_SETTINGS = {
    "Bronze": {
        "time_limit": 120.0,
        "target_score": 500,
        "speed_multiplier": 1.0
    },
    "Silver": {
        "time_limit": 90.0,
        "target_score": 750,
        "speed_multiplier": 1.5
    },
    "Gold": {
        "time_limit": 60.0,
        "target_score": 1000,
        "speed_multiplier": 2.0
    }
}

# === EXPORTS ===
@export var difficulty: String = "Bronze"

# === GAME STATE ===
var _score: int = 0
var _time_remaining: float = 0.0
var _is_game_active: bool = false
var _completion_rank: String = ""

# === NODES ===
@onready var ui = $UI
@onready var game_area = $GameArea
@onready var timer = $GameTimer

# === LIFECYCLE ===
func _ready():
    initialize_game()
    show_introduction()

func _process(delta):
    if _is_game_active:
        update_timer(delta)
        update_game_logic(delta)
        check_win_condition()

# === GAME FLOW ===
func initialize_game():
    var settings = DIFFICULTY_SETTINGS[difficulty]
    _time_remaining = settings.time_limit
    _score = 0
    update_ui()

func show_introduction():
    # Show elder introduction, tribal history, and scripture
    # Wait for player to press continue
    await get_tree().create_timer(2.0).timeout
    start_game()

func start_game():
    _is_game_active = true
    timer.start()

func end_game(success: bool):
    _is_game_active = false
    timer.stop()
    
    if success:
        determine_completion_rank()
        Global.add_stone(TRIBE_NAME)
        show_victory_screen()
    else:
        show_retry_screen()

func determine_completion_rank():
    var settings = DIFFICULTY_SETTINGS[difficulty]
    if _score >= settings.target_score * 1.5:
        _completion_rank = "Gold"
    elif _score >= settings.target_score:
        _completion_rank = "Silver"
    else:
        _completion_rank = "Bronze"

# === GAME LOGIC (Override in specific mini-games) ===
func update_game_logic(delta):
    # Implement game-specific logic here
    pass

func check_win_condition():
    var settings = DIFFICULTY_SETTINGS[difficulty]
    if _score >= settings.target_score:
        end_game(true)

# === UI ===
func update_ui():
    ui.get_node("ScoreLabel").text = "Score: %d" % _score
    ui.get_node("TimeLabel").text = "Time: %.1f" % _time_remaining

func update_timer(delta):
    _time_remaining -= delta
    if _time_remaining <= 0:
        _time_remaining = 0
        end_game(false)
    update_ui()

func show_victory_screen():
    # Display completion screen with rank, score, and next steps
    print("Victory! Rank: %s, Score: %d" % [_completion_rank, _score])
    transition_to_scripture_memory()

func show_retry_screen():
    # Display retry option
    print("Game Over. Score: %d" % _score)

# === TRANSITIONS ===
func transition_to_scripture_memory():
    # Load scripture memorization scene
    get_tree().change_scene_to_file("res://scenes/ScriptureMemory.tscn")

# === INPUT (Override as needed) ===
func _input(event):
    if not _is_game_active:
        return
    
    # Handle game-specific input
    handle_game_input(event)

func handle_game_input(event):
    # Implement in specific mini-games
    pass
```

### Reflex/Tap Game Template (Reuben)

```gdscript
# reuben_ladder.gd
extends "res://scripts/minigames/minigame_template.gd"

# === GAME SPECIFIC ===
var _ladder_rungs: Array[Node2D] = []
var _current_rung_index: int = 0
var _player_position: Vector2

func update_game_logic(delta):
    spawn_rungs(delta)
    scroll_ladder(delta)
    check_player_balance()

func handle_game_input(event):
    if event is InputEventMouseButton and event.pressed:
        if event.position.x < get_viewport_rect().size.x / 2:
            step_left()
        else:
            step_right()

func step_left():
    # Implement left step logic
    pass

func step_right():
    # Implement right step logic
    pass

func spawn_rungs(delta):
    # Spawn new ladder rungs at intervals
    pass

func scroll_ladder(delta):
    # Scroll ladder downward
    pass

func check_player_balance():
    # Check if player is balanced on rung
    pass
```

### Rhythm Game Template (Levi)

```gdscript
# levi_rhythm.gd
extends "res://scripts/minigames/minigame_template.gd"

# === RHYTHM GAME ===
var _notes: Array[Dictionary] = []
var _combo: int = 0
var _music_position: float = 0.0

@onready var music_player = $MusicPlayer
@onready var note_lanes = $NoteLanes

func start_game():
    super.start_game()
    music_player.play()
    load_note_chart()

func update_game_logic(delta):
    _music_position += delta
    spawn_notes()
    update_note_positions(delta)

func handle_game_input(event):
    if event is InputEventMouseButton and event.pressed:
        var lane = get_lane_from_position(event.position)
        check_note_hit(lane)

func check_note_hit(lane: int):
    # Check if note was hit with good timing
    var timing_window = 0.1  # 100ms window
    # Implement hit detection
    pass

func load_note_chart():
    # Load pre-designed note patterns
    pass

func spawn_notes():
    # Spawn notes based on music position
    pass
```

---

## Scene Organization

### Directory Structure
```
res://
├── scenes/
│   ├── MainMenu.tscn
│   ├── AvatarPick.tscn
│   ├── WorldMap.tscn
│   ├── Lobby.tscn
│   ├── Finale.tscn
│   ├── minigames/
│   │   ├── Reuben_Ladder.tscn
│   │   ├── Simeon_Justice.tscn
│   │   └── ... (all 12 tribes)
│   ├── ui/
│   │   ├── MainUI.tscn
│   │   ├── PauseMenu.tscn
│   │   └── ScriptureDisplay.tscn
│   └── components/
│       ├── Elder.tscn
│       └── Stone.tscn
├── scripts/
│   ├── Global.gd
│   ├── MultiplayerLobby.gd
│   ├── MainMenu.gd
│   ├── minigames/
│   │   ├── minigame_template.gd
│   │   └── ... (tribe-specific)
│   └── utils/
│       ├── SaveSystem.gd
│       └── ScriptureManager.gd
├── assets/
│   ├── sprites/
│   ├── models/
│   ├── audio/
│   ├── fonts/
│   └── data/
│       ├── tribes.json
│       ├── scriptures.json
│       └── verses.json
└── DOCS/
    └── (documentation files)
```

---

## Data Formats

### Tribe Data (JSON)

```json
{
  "tribes": [
    {
      "name": "Reuben",
      "order": 1,
      "blessing": "Genesis 49:3-4",
      "blessing_text": "Reuben, you are my firstborn...",
      "key_characteristic": "Unstable as water",
      "spiritual_lesson": "Trust and redemption",
      "territory": "East of Jordan",
      "minigame_scene": "res://scenes/minigames/Reuben_Ladder.tscn",
      "color": "#8B4513",
      "stone_color": "#D2691E",
      "icon": "res://assets/sprites/icons/tribe_reuben.png"
    }
  ]
}
```

### Scripture Database (JSON)

```json
{
  "verses": [
    {
      "reference": "Genesis 49:3-4",
      "translation": "ESV",
      "text": "Reuben, you are my firstborn, my might and the beginning of my strength...",
      "context": "Jacob's blessing of his sons",
      "tribe": "Reuben",
      "memorization_difficulty": "Medium",
      "word_count": 28
    }
  ]
}
```

---

## Performance Requirements

### Target Performance
```
Frame Rate:
  - Desktop: 60 FPS minimum
  - Mobile: 30 FPS minimum (60 FPS target)
  - Low-end devices: 30 FPS minimum

Load Times:
  - Scene transitions: < 1 second
  - Game startup: < 3 seconds
  - Asset loading: Background/async when possible

Memory:
  - Desktop: < 1GB RAM
  - Mobile: < 512MB RAM
  - Texture streaming for large assets
```

### Optimization Techniques
```gdscript
# Use object pooling for frequently spawned objects
var note_pool: Array[Node] = []

func get_pooled_note() -> Node:
    if note_pool.size() > 0:
        return note_pool.pop_back()
    else:
        return create_new_note()

func return_to_pool(note: Node):
    note.hide()
    note_pool.append(note)

# Disable processing when not needed
func _ready():
    set_process(false)  # Enable only when game starts

# Use visibility notifier for off-screen optimization
func _on_visible_on_screen_notifier_2d_screen_exited():
    set_process(false)
```

---

## Testing Requirements

### Unit Tests (Optional but Recommended)
```gdscript
# test_score_calculation.gd
extends GutTest

func test_score_calculation():
    var game = load("res://scripts/minigames/Reuben_Ladder.gd").new()
    game.difficulty = "Bronze"
    game.initialize_game()
    
    # Test score calculation
    assert_eq(game.calculate_score(100, 1.0), 100)
    assert_eq(game.calculate_score(100, 2.0), 200)
```

### Integration Tests
- Scene loading
- Data persistence
- Multiplayer synchronization
- Scripture display
- Audio playback

---

## Version Control

### .gitignore
```
# Godot-specific
.import/
*.import
*.translation
*.stex
*.etc

# Build exports
export/
builds/

# Temp files
*.tmp
*.log
*~

# OS-specific
.DS_Store
Thumbs.db
```

### Commit Message Format
```
feat: Add Reuben ladder mini-game
fix: Correct scripture citation for Judah
docs: Update technical specifications
refactor: Improve mini-game template structure
test: Add unit tests for score calculation
```

---

*Document Version: 1.0*  
*Last Updated: 2026-02-18*  
*Godot Version: 4.3*  
*Next Review: After first mini-game implementation*
