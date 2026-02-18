# Copilot Instructions for Ephod Quest

## Project Overview
Ephod Quest (also known as "Twelve Stones") is a 2D biblical adventure game built with Godot Engine 4.3. The game features a multiplayer experience where players progress through tribal quests based on the 12 tribes of Israel, collecting stones and learning biblical verses.

## Technology Stack
- **Engine**: Godot 4.3
- **Language**: GDScript
- **Architecture**: Scene-based with autoload singletons
- **Networking**: ENet for multiplayer

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
