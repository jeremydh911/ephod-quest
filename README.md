# Ephod Quest

A 2D adventure game built with Godot Engine 4.2+.

## Getting Started

### Prerequisites

- [Godot Engine 4.2+](https://godotengine.org/download) (Standard or .NET version)

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/jeremydh911/ephod-quest.git
   cd ephod-quest
   ```

2. Open the project in Godot:
   - Launch Godot Engine
   - Click "Import"
   - Browse to the project folder
   - Select the `project.godot` file
   - Click "Import & Edit"

### Running the Game

1. Press F5 or click the "Play" button in Godot Editor
2. Use WASD or Arrow Keys to move the player character

## Project Structure

```
ephod-quest/
├── scenes/          # Game scenes (.tscn files)
│   ├── main.tscn   # Main game scene
│   └── player.tscn # Player character scene
├── scripts/         # GDScript files (.gd files)
│   └── player.gd   # Player movement script
├── assets/          # Game assets (sprites, sounds, etc.)
├── icon.svg         # Project icon
└── project.godot    # Godot project configuration
```

## Controls

- **Movement**: WASD or Arrow Keys
  - W/↑: Move Up
  - A/←: Move Left
  - S/↓: Move Down
  - D/→: Move Right

## Development

This is a basic Godot game template with:
- A player character with top-down movement
- A main scene with a simple background
- Input mapping for keyboard controls
- Camera following the player

Feel free to extend this project by adding:
- Enemy characters
- Items and collectibles
- Level design
- Sound effects and music
- UI elements (menus, HUD, etc.)

## License

This project is open source and available under the MIT License.