# Ephod Quest Rendering System

This comprehensive Godot 4.3+ GDScript system provides modular character, world, and object rendering for the Twelve Stones adventure game. Built from vector character drawings, watercolor images, glowing artifacts, and biblical themes in 3D space.

## Core Components

### Character.gd

Vector-based character system with tribal diversity:

- 12 tribes with unique colors and traits
- Roles: avatar, elder, npc with scaling and z-indexing
- Animations: idle, walk, pray, attack, power-up glow
- Companion pets for avatars
- Serialization for save/load

### WorldGenerator.gd

Procedural world creation using image tilesets:

- Biome-specific GridMap layers (village, desert, sea, action spots)
- ParallaxBackground for depth effects (adapted for 3D)
- Interactive Area3D triggers for quests (Jericho walls, crystal skies)
- Expandable world generation from biblical themes

### Inventory.gd

Collectibles and power-up system:

- 12 ephod stones as RigidBody3D pickups
- Artifacts, scrolls, and biblical technology
- Shader-based power-ups (glow, speed boost, invulnerability)
- Physics-based item collection

## Usage Examples

### Creating a Character

```gdscript
var char := Character.new()
char.set_tribe("reuben")
char.set_role("avatar")
char.set_age(17)
add_child(char)
char.set_state(Character.AnimationState.WALK)
```

### Generating a World

```gdscript
var generator := WorldGenerator.new()
generator.generate_world("judah", self)
```

### Managing Inventory

```gdscript
Inventory.add_item("sardius_stone")
Inventory.apply_power_up("bible_glow", player)
```

## File Structure

```
scripts/
├── Character.gd          # Character rendering system
├── WorldGenerator.gd     # Procedural world generation
├── Inventory.gd          # Collectibles and power-ups
└── shaders/
    └── power_glow.gdshader # Power-up glow effect

scenes/
├── CharacterExample.tscn # Example character scene
└── WorldExample.tscn     # Example world scene

assets/
├── sprites/
│   ├── characters/       # Tribe/role sprite sheets
│   ├── backgrounds/      # Parallax layers
│   ├── action_spots/     # Interactive quest triggers
│   └── items/            # Collectible sprites
└── tiles/                # TileSet files for worlds
```

## Features

- **Vector Support**: SVG-compatible for scalability
- **3D Optimized**: Full 3D rendering with MeshInstance, GridMap, and Camera3D support
- **Child-Friendly**: No violence, educational biblical content
- **Expandable**: Procedural generation from image styles
- **Modular**: Easy integration into existing scenes

## Integration

Add to project.godot autoloads:

```
Character="*res://scripts/Character.gd"
WorldGenerator="*res://scripts/WorldGenerator.gd"
Inventory="*res://scripts/Inventory.gd"
```

## Asset Requirements

Place images in corresponding folders:

- Character sprites: `assets/sprites/characters/[tribe]_[role].png`
- World backgrounds: `assets/sprites/backgrounds/[biome].png`
- Action spots: `assets/sprites/action_spots/[spot].png`
- Items: `assets/sprites/items/[item].png`
- Tiles: `assets/tiles/[tileset].tres`

## Future Expansion

- Add more tribes and biomes
- Implement advanced AI for NPCs
- Create particle systems for miracles
- Add multiplayer synchronization
