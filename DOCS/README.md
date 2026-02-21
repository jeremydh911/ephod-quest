# Documentation Overview

This directory contains comprehensive documentation for the **Twelve Stones** biblical game project.

## Documentation Files

### 1. [GDD.md](GDD.md) - Game Design Document

**Purpose:** Complete game design roadmap and vision

**Contents:**

- ✅ Detailed project roadmap with development phases
- ✅ Core gameplay loop: Explore → Meet Elder → Challenge → Memorize → Collect → Build
- ✅ Victory conditions and achievement system
- ✅ Narrative arc across three acts (12 tribes)
- ✅ Game progression system and difficulty scaling
- ✅ Key game systems (navigation, dialogue, mini-games, scripture memory, memorial building)
- ✅ Multiplayer features (cooperative and competitive modes)
- ✅ Technical architecture and scene structure
- ✅ Success metrics and future expansion plans

### 2. [BIBLICAL_PROMPTS.md](BIBLICAL_PROMPTS.md) - Biblical Verification Guidelines

**Purpose:** Ensure biblical accuracy and theological soundness

**Contents:**

- ✅ General verification prompt for AI/human experts
- ✅ Tribe-specific verification prompts for all 12 tribes
- ✅ Criteria for tribal history accuracy
- ✅ Theological soundness evaluation framework
- ✅ Character respect and representation guidelines
- ✅ Scripture citation verification process
- ✅ Cultural sensitivity review procedures
- ✅ Final approval checklist
- ✅ Recommended biblical resources and translations

### 3. [DEPLOYMENT.md](DEPLOYMENT.md) - Platform Deployment Guide

**Purpose:** Technical deployment specifications for all platforms

**Contents:**

- ✅ iOS export settings and App Store submission
- ✅ Android export settings and Google Play submission
- ✅ macOS deployment and notarization process
- ✅ Windows desktop export and distribution
- ✅ Ubuntu/Linux deployment options
- ✅ Godot 4.3 specific technical requirements
- ✅ Cross-platform testing checklist
- ✅ Release checklist for all platforms
- ✅ Performance requirements and optimization

### 4. [QUEST_CONCEPTS.md](QUEST_CONCEPTS.md) - 12 Tribes Mini-Games

**Purpose:** Detailed design for all tribal quest mini-games

**Contents:**

- ✅ **Reuben:** Ladder/Trust (Tap/Reflex game)
- ✅ **Simeon:** Justice/Scales (Sorting game)
- ✅ **Levi:** Praise/Rhythm (Rhythm game)
- ✅ **Judah:** Leadership/Roar (Rhythm challenge)
- ✅ **Dan:** Discernment (Hidden object game)
- ✅ **Naphtali:** Swiftness (Platformer/runner)
- ✅ **Gad:** Fortitude (Tower defense)
- ✅ **Asher:** Blessing (Harvesting game)
- ✅ **Issachar:** Observation (Astronomy puzzle)
- ✅ **Zebulun:** Haven (Sailing simulation)
- ✅ **Joseph:** Fruitfulness (Growth game)
- ✅ **Benjamin:** Protection (Precision game)

Each tribe includes:

- Biblical theme and characteristics
- Specific game mechanics
- Controls and objectives
- Difficulty progression (Bronze/Silver/Gold)
- Educational elements
- Key scripture verses

### 5. [CONTENT_GUIDELINES.md](CONTENT_GUIDELINES.md) - Content Standards

**Purpose:** Age-appropriate content boundaries and biblical accuracy

**Contents:**

- ✅ Age rating target (ESRB E / PEGI 3 / Apple 4+)
- ✅ All Ages content framework (allowed and prohibited)
- ✅ Guidelines for handling difficult biblical topics
- ✅ Biblical accuracy checklist
- ✅ Language and tone guidelines
- ✅ Visual content standards
- ✅ Audio content standards
- ✅ Multiplayer safety standards
- ✅ Educational content standards
- ✅ Cultural sensitivity requirements
- ✅ 18+ expansion considerations (future)

### 6. [TECHNICAL_SPECS.md](TECHNICAL_SPECS.md) - Technical Requirements

**Purpose:** Asset specifications and code standards

**Contents:**

- ✅ 3D graphics requirements (PNG/SVG/GLB formats)
- ✅ 3D assets specifications (GLB format for memorial stones)
- ✅ Audio requirements (OGG/WAV formats)
- ✅ Sound specifications for music, SFX, and voice
- ✅ Font support for Hebrew characters
- ✅ GDScript code standards and style guide
- ✅ Mini-game code templates with examples
- ✅ Scene organization structure
- ✅ Data formats (JSON for tribes and scriptures)
- ✅ Performance requirements
- ✅ Version control guidelines

### 7. [STYLE_GUIDE.md](STYLE_GUIDE.md) - Visual & Audio Style

**Purpose:** Unified artistic vision and implementation

**Contents:**

- ✅ "Earth & Gold" color palette with hex codes
- ✅ Art direction and visual style guidelines
- ✅ Character design (player and tribal elders)
- ✅ Environment design for each tribal territory
- ✅ UI/UX design with scroll/parchment aesthetic
- ✅ Typography guidelines (UI, Scripture, Hebrew)
- ✅ Animation guidelines
- ✅ Audio style (Middle Eastern instrumentation)
- ✅ World-building guidelines
- ✅ Character creation standards
- ✅ Icon and symbol design for all 12 tribes
- ✅ Consistency checklist

## Quick Start for Developers

### New to the Project?

1. Start with **GDD.md** to understand the overall vision
2. Read **CONTENT_GUIDELINES.md** to understand boundaries
3. Check **TECHNICAL_SPECS.md** for implementation standards
4. Review **STYLE_GUIDE.md** for visual consistency

### Implementing a Tribal Quest?

1. Reference **QUEST_CONCEPTS.md** for your specific tribe
2. Use code templates from **TECHNICAL_SPECS.md**
3. Follow visual guidelines in **STYLE_GUIDE.md**
4. Verify content with **BIBLICAL_PROMPTS.md**

### Preparing for Release?

1. Follow **DEPLOYMENT.md** for platform-specific builds
2. Complete checklist in **CONTENT_GUIDELINES.md**
3. Verify biblical accuracy with **BIBLICAL_PROMPTS.md**
4. Test against requirements in **TECHNICAL_SPECS.md**

## Document Status

| Document | Status | Last Updated | Version |
|----------|--------|--------------|---------|
| GDD.md | ✅ Complete | 2026-02-18 | 1.0 |
| BIBLICAL_PROMPTS.md | ✅ Complete | 2026-02-18 | 1.0 |
| DEPLOYMENT.md | ✅ Complete | 2026-02-18 | 1.0 |
| QUEST_CONCEPTS.md | ✅ Complete | 2026-02-18 | 1.0 |
| CONTENT_GUIDELINES.md | ✅ Complete | 2026-02-18 | 1.0 |
| TECHNICAL_SPECS.md | ✅ Complete | 2026-02-18 | 1.0 |
| STYLE_GUIDE.md | ✅ Complete | 2026-02-18 | 1.0 |

## Project Implementation Status

| Component | Status | Progress | Notes |
|-----------|--------|----------|-------|
| **Core Infrastructure** | ✅ Complete | 100% | Autoloads, project setup, export presets |
| **Quest1 (Reuben)** | ✅ Complete | 100% | Cave + ladder tap + butterfly rhythm |
| **Quest2 (Judah)** | ✅ Complete | 100% | Hillside + praise roar + bubble hold |
| **Quest3 (Levi)** | ✅ Complete | 100% | Sacred hall + lamp ordering + scroll sequence |
| **Quest4 (Dan)** | ✅ Complete | 100% | Hilltop + eagle soar + pattern lock |
| **Quest5-12** | 🔲 Stub | 0% | Scene files created, scripts need implementation |
| **MainMenu** | 🔲 Partial | 80% | Basic navigation, needs Verse Vault button |
| **Finale** | ✅ Complete | 100% | Courtyard ephod-weave cinematic |
| **VerseVault** | ✅ Complete | 100% | Collectible journal with verses + facts |
| **Multiplayer** | ✅ Complete | 100% | ENet lobby, cross-tribe sync |
| **Touch Controls** | ✅ Complete | 100% | Virtual joystick, swipe input |
| **Audio System** | ✅ Complete | 100% | Placeholders added, graceful handling |
| **Global State** | ✅ Complete | 100% | 48 avatars, save/load, tribal data |
| **Sprites/Assets** | 🔲 Pending | 0% | Basic placeholders needed |
| **Android Export** | 🔲 Pending | 0% | Export presets ready, needs testing |
| **Playtesting** | 🔲 Pending | 0% | End-to-end navigation testing |

**Overall Progress:** ~35% (4/12 quests complete, infrastructure done)

## Contributing to Documentation

When updating documentation:

1. Maintain consistent formatting
2. Update version numbers and dates
3. Keep cross-references accurate
4. Add examples where helpful
5. Consider accessibility and clarity

## Key Themes

The documentation reflects these core principles:

- **Biblical Accuracy:** All content must be scripturally sound
- **Age Appropriateness:** Suitable for all ages (primarily children)
- **Educational Value:** Players should learn while having fun
- **Cultural Respect:** Honor Jewish heritage and Christian faith
- **Technical Excellence:** Professional quality standards
- **Cross-Platform:** Accessible on iOS, Android, macOS, Windows, Ubuntu

## Project Vision

> "Just as the Israelites set up stones to remember God's faithfulness,
> players will build their own memorial of faith through this interactive journey."

---

**For Questions or Clarification:**

- Review the specific documentation file
- Check cross-references to related documents
- Consult with project lead or biblical scholars
- Use the verification prompts in BIBLICAL_PROMPTS.md

**Total Documentation:** 4,037+ lines across 7 comprehensive documents

*Documentation created: 2026-02-18*  
*Project: Twelve Stones (Ephod Quest)*  
*Engine: Godot 4.3*
