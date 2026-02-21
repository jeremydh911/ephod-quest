# Contributor Guide - Twelve Stones: Ephod Quest

Welcome to the Twelve Stones development team! This guide will help you get started with contributing to this Godot-based biblical adventure game.

## 🚀 **Quick Start**

### Prerequisites

- **Godot Engine 4.3+**: Download from [godotengine.org](https://godotengine.org/download)
- **Git**: Version control system
- **Basic Knowledge**: GDScript, Godot editor, biblical familiarity

### Setup

```bash
git clone https://github.com/jeremydh911/ephod-quest.git
cd ephod-quest
# Open project.godot in Godot Editor
```

## 📁 **Project Structure**

```
ephod-quest/
├── scenes/          # Godot scene files (.tscn)
├── scripts/         # GDScript files (.gd)
│   ├── WorldBase.gd     # 3D world engine
│   ├── Quest1-12.gd     # Individual quest logic
│   ├── Global.gd        # Game state management
│   └── TouchControls.gd # Mobile input system
├── assets/          # Game assets
│   ├── textures/        # Character/environment images
│   ├── audio/          # Music and sound effects
│   └── fonts/          # UI typography
├── tests/           # Playwright E2E tests
├── DOCS/            # Documentation
└── export_presets.cfg  # Platform export settings
```

## 🎯 **Development Workflow**

### 1. Choose a Task

- Check [WHAT_IS_LEFT_TO_DO.md](WHAT_IS_LEFT_TO_DO.md) for current priorities
- Look at GitHub Issues for specific bugs/features
- Review [GDD.md](DOCS/GDD.md) for design guidelines

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b bugfix/issue-description
```

### 3. Make Changes

- Follow the [STYLE_GUIDE.md](DOCS/STYLE_GUIDE.md)
- Test frequently in Godot Editor (F5 to run)
- Commit often with clear messages

### 4. Test Your Changes

```bash
# Run Playwright tests (requires exported web build)
cd tests
npm test

# Or run specific test suites
npm run test:quests
npm run test:avatar
```

### 5. Submit a Pull Request

- Push your branch to GitHub
- Create a PR with detailed description
- Reference any related issues
- Wait for code review

## 🎨 **Content Creation Guidelines**

### Biblical Accuracy

- **Scripture**: Use NIV or KJV exactly, include full references
- **History**: Stick to biblical accounts, avoid speculation
- **Culture**: Respectful representation, no stereotypes
- **Language**: No "temple" or "church" - use physical descriptions

### Visual Style

- **Palette**: Earth & Gold (Desert Sand #E9D5B3, Clay Brown #8B6F47, etc.)
- **Art Style**: Soft cartoon, rounded features, expressive eyes
- **Diversity**: Varied skin tones, hair types, ages (12-29 only)
- **Resolution**: 512x512 for characters, appropriate for environment

### Audio Guidelines

- **Music**: Sacred, contemplative, tribal-appropriate
- **SFX**: Clear, non-violent, celebratory
- **Format**: WAV for short sounds, OGG for music
- **Volume**: Balanced, accessible levels

## 🛠 **Technical Standards**

### Code Style

```gdscript
# ✅ Good
extends Node3D

@export var tribe_key: String = ""
@onready var _player: CharacterBody3D = $PlayerBody

func _ready() -> void:
    _setup_world()

func _setup_world() -> void:
    # Implementation here
    pass
```

### Naming Conventions

- **Variables**: `snake_case` (e.g., `player_position`)
- **Functions**: `snake_case` (e.g., `collect_stone()`)
- **Classes**: `PascalCase` (e.g., `WorldBase`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `MAX_PLAYERS`)
- **Files**: `PascalCase.tscn/.gd` (e.g., `QuestFive.gd`)

### Scene Organization

- **Node3D Root**: For 3D worlds
- **CanvasLayer**: For UI elements (HUD, dialogue)
- **CharacterBody3D**: For player character
- **Area3D**: For interactive objects
- **StaticBody3D**: For terrain/collisions

## 🧪 **Testing Requirements**

### Unit Testing

- Test individual functions in GDScript
- Verify edge cases and error conditions
- Check mathematical calculations

### Integration Testing

- Test scene transitions
- Verify save/load functionality
- Check multiplayer connections

### E2E Testing

- Use Playwright for full game flows
- Test on multiple browsers/devices
- Verify mobile touch controls

## 📝 **Documentation Standards**

### Code Comments

```gdscript
# Genesis 50:20 – "God intended it for good"
func _handle_forgiveness_choice(choice: String) -> void:
    # Implementation with biblical context
    pass
```

### Commit Messages

```
feat: add butterfly side quest to Quest5
fix: resolve touch input conflicts on Android
docs: update deployment guide for iOS
refactor: simplify terrain generation in WorldBase
```

### Pull Request Template

- **Title**: Clear, descriptive summary
- **Description**: What, why, how
- **Testing**: How you tested the changes
- **Screenshots**: For visual changes
- **Related Issues**: Link to GitHub issues

## 🎮 **Adding New Content**

### New Quest

1. Create `scenes/QuestN.tscn` (copy from Quest1)
2. Create `scripts/QuestN.gd` (extend WorldBase)
3. Add to Global.gd quest routes
4. Implement `_build_terrain()`, `_place_npcs()`, `_place_chests()`
5. Add mini-game logic and verse integration

### New Avatar

1. Add to `Global.gd` AVATARS dictionary
2. Create texture file with UUID naming
3. Test in AvatarPick scene
4. Update tribal distribution if needed

### New Mini-Game

1. Add builder function to WorldBase.gd
2. Implement touch/rhythm/tap logic
3. Add visual feedback and timing
4. Test on mobile devices

## 🚨 **Common Issues & Solutions**

### Godot Editor Problems

- **Shaders not compiling**: Check Godot version (4.3+ required)
- **Scenes not loading**: Verify file paths and dependencies
- **Audio not playing**: Check import settings and file formats

### Mobile Issues

- **Touch not responding**: Verify input actions in project.godot
- **Performance lag**: Check particle counts and texture sizes
- **Export failures**: Ensure Android SDK is properly configured

### Multiplayer Problems

- **Connection failures**: Check ENet port (7777) availability
- **Sync issues**: Verify Global.gd state management
- **Peer disconnections**: Add proper error handling

## 📞 **Getting Help**

### Communication

- **GitHub Issues**: For bugs and feature requests
- **Pull Request Comments**: For code review feedback
- **Discord/Forum**: For general Godot questions

### Resources

- [Godot Documentation](https://docs.godotengine.org/en/stable/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/classes/index.html)
- [Twelve Stones GDD](DOCS/GDD.md)
- [Biblical References](DOCS/BIBLICAL_PROMPTS.md)

## 🎉 **Recognition**

Contributors will be recognized in:

- **CHANGELOG.md**: For significant features
- **README.md Credits**: For major contributions
- **In-Game Credits**: For substantial work
- **GitHub Contributors**: Automatic recognition

## 📋 **Code of Conduct**

### Respectful Development

- **Inclusive**: Welcome all contributors regardless of background
- **Professional**: Keep discussions technical and constructive
- **Patient**: Help newcomers learn and grow
- **Ethical**: Maintain biblical accuracy and wholesome content

### Content Standards

- **No Violence**: Keep all content peaceful and educational
- **Biblical Fidelity**: Maintain accuracy to scripture
- **Cultural Respect**: Represent diverse backgrounds appropriately
- **Age Appropriate**: Family-friendly content suitable for all ages

---

Thank you for contributing to Twelve Stones: Ephod Quest! Your work helps create meaningful, educational experiences that bring people closer to biblical stories and creation science.

*For questions, see the [TECHNICAL_SPECS.md](DOCS/TECHNICAL_SPECS.md) or create a GitHub Issue.*</content>
<parameter name="filePath">/media/jeremiah/8t Backup/projects/ephod-quest/CONTRIBUTING.md
