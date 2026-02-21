# Elias Thorne — Full Game Overhaul Prompt

## "Better Than Zelda" Vision Execution

Paste this into GitHub Copilot (or any AI coding assistant) to continue building
the full production version of *Twelve Stones — Ephod Quest* in Godot 4.3+.

---

## Context: What Already Exists (DO NOT rebuild, only enhance)

```
Project: /ephod-quest  (Godot 4.6.1, GDScript 4.x, Node3D WorldBase architecture)
Autoloads: Global.gd, MultiplayerLobby.gd, AudioManager.gd, VerseVault.gd
Core engine files (already production-quality, do NOT rewrite):
  - scripts/WorldBase.gd   (1275 lines — 3D world engine: terrain, NPCs, chests,
                             camera, HUD, dialogue, verse scroll, nature panel,
                             touch controls, GPUParticles3D celebrations,
                             MeshInstance3D tile/wall/NPC/chest builders,
                             VisualEnvironment integration, full minigame system)
  - scripts/VisualEnvironment.gd  (370 lines — biome gradient shaders, animated sky,
                                   tribe portraits, tribe initial badges,
                                   atmospheric particles, vignette, terrain art)
  - scripts/QuestBase.gd   (2019 lines — legacy 2D quest engine for Quest1-4)
  - scripts/Quest1-12.gd   (each extends WorldBase, tribe-specific mini-games)
  - scripts/AudioManager.gd (single SFX player, cross-fade music, voice mumbles)
  - scripts/Global.gd      (all 12 tribes, 48 avatars, save/load, stones, verses)
  - 12 complete quest .tscn scenes (Node3D root + PlayerBody + Camera3D)
  - Full audio library: music per tribe, 30+ SFX files
  - VisualEnvironment BIOMES: per-tribe sky shaders, gradient colors, particles
```

---

## The Full Vision: What To Build Next

You are **Elias Thorne**, a senior Godot 4.3 engineer. Build this game to the full
Zelda: Breath of the Wild quality standard but for a calm, biblical, educational
mobile-first game. Every feature below must be production-ready, commented with
biblical references, and zero-error in Godot 4.6.1.

---

### 1. PLAYER CHARACTER — Full 3D Animated Avatar

**File:** `scripts/PlayerBody.gd` (already referenced in all Quest scenes)

```gdscript
# Current: CharacterBody3D with basic WASD + touch movement
# UPGRADE TO:
```

- Replace the capsule mesh with a procedural cartoon character mesh using
  `ImmediateMesh` or `MeshInstance3D` with `ArrayMesh` — round head (sphere),
  rounded body (cylinder), stumpy limbs. Colored by `Global.selected_tribe` color.
- Add state machine: `IDLE`, `WALK`, `RUN`, `INTERACT`, `CELEBRATE`
- Walking: bob the body node up/down using `create_tween().set_loops()`
  `tween_property(mesh_node, "position:y", 0.08, 0.3)`
- Celebrate: spin + scale-up pulse when stone collected
- Add footstep SFX trigger: every 0.4s while walking, `AudioManager.play_sfx("footstep.wav")`
- Shadow: `OmniLight3D` directly below player, intensity tied to height above ground
- The player should cast a soft glow matching tribe color (OmniLight3D, range=2.0,
  energy=0.3, color = tribe color)

---

### 2. CAMERA SYSTEM — Zelda-style Follow Camera

**File:** `scripts/WorldBase.gd` → `_setup_camera()` method (currently basic Camera3D)

```gdscript
# Upgrade _setup_camera() in WorldBase._ready() to:
```

- Smooth lerp follow: `camera.global_position = camera.global_position.lerp(target, delta * 5.0)`
- Target = `_player.global_position + Vector3(0, 8, 6)` (isometric overhead angle)
- `camera.look_at(_player.global_position + Vector3(0, 1, 0), Vector3.UP)`
- Field of view animate on sprint: tween FOV 60→70 when velocity > 4.0
- Slight camera shake on stone collection: `_camera_shake(0.3, 0.15)` method that
  tweens camera offset noise pattern
- On dialogue: camera lerps to `_player.global_position + Vector3(0, 3, 3)` (closer)
- On quest complete: dramatic pull-back to overhead view before scene transition

---

### 3. WORLD TERRAIN — Rich Zelda-Style 3D Environments

**File:** `scripts/WorldBase.gd` — upgrade `_tr()` (terrain tile builder)

Current `_tr` builds flat `BoxMesh` tiles. Upgrade to:

```gdscript
func _tr(pos: Vector3, size: Vector3, texture: String) -> void:
    # Keep existing signature — ADD:
    # 1. Random Y variation: pos.y += randf_range(-0.05, 0.05)
    # 2. Rim highlight mesh (thin PlaneMesh, slightly larger, tribe color, 40% alpha)
    # 3. Grass: if texture == "grass", add ~6 thin vertical quads as grass blades
    #    using ImmediateMesh, swaying via tween set_loops()
    # 4. Stone: roughen edges using SurfaceTool.add_vertex with noise offset
```

Add new terrain feature methods to `WorldBase.gd`:

- `_add_tree(pos: Vector3, trunk_col: Color, leaf_col: Color)` — cylinder + sphere mesh
- `_add_rock(pos: Vector3, scale: float)` — deformed sphere using `SurfaceTool`
- `_add_water(pos: Vector3, size: Vector2)` — PlaneMesh with animated shader
  (use `ShaderMaterial`, time-based UV scroll: `uv.x += TIME * 0.1`)
- `_add_campfire(pos: Vector3)` — small cylinder + `GPUParticles3D` orange/red sparks
  - OmniLight3D flicker tween
- `_add_flower(pos: Vector3, color: Color)` — flat cross quad with color material

Per-tribe terrain calls to add in each Quest's `_build_terrain()`:

- Quest1 (Reuben): cliffs, grass patches, small stream with `_add_water()`, 3 pine trees
- Quest2 (Judah): golden hills, lion den rock formation, 2 campfires, olive trees
- Quest3 (Levi): stone courtyard floor (grey tiles), gold pillar accents, lampstand
- Quest4 (Dan): plateau edges, eagle nest rock, desert sand, scattered boulders
- Quest5 (Naphtali): forest floor, deer tracks (small footprint quads), brook
- Quest6 (Simeon): dry plains, scattered tents (box + pitched roof mesh), dusty sand
- Quest7 (Gad): mountain pass rock walls, battle victory cairn (stacked rocks)
- Quest8 (Asher): coastal tiles, blue water plane, olive press stone, harvest baskets
- Quest9 (Issachar): farm field rows (furrow lines), wheat stalks, donkey pen fence
- Quest10 (Zebulun): harbor dock boards, ship mast pole, sea water, fishing nets
- Quest11 (Joseph): fertile valley, seven grain stalks, stone well, dream cloud effect
- Quest12 (Benjamin): city gate arch, wolf territory forest, protective stone wall

---

### 4. NPC CHARACTERS — Expressive Elder Meshes

**File:** `scripts/WorldBase.gd` → `_build_npc()` method

Current: `Area3D` with a flat `Label3D` emoji. Upgrade to:

```gdscript
func _build_npc(key: String, pos: Vector3, texture: String) -> void:
    # Keep existing signature logic — ADD full mesh elder character:
```

- Head: `SphereMesh` r=0.35, skin tone from tribe data, mounted on `Node3D`
- Body: `CylinderMesh` r=0.25 h=0.8, draped robe color = tribe color darkened 30%
- Beard: `SphereMesh` r=0.22 elongated, grey/white
- Eyes: two tiny white `SphereMesh` with dark pupils (a 2nd tiny sphere each)
- Staff: thin `CylinderMesh` h=1.8, `MeshInstance3D` at side
- Elder bob animation: `create_tween().set_loops()` on body Y ±0.04 every 2s
- On proximity (player within 3 units): elder rotates to face player
  `elder_root.look_at(_player.global_position, Vector3.UP)` in `_physics_process`
- Floating name label: `Label3D` above head, always faces camera (billboard mode)
- Glow aura: `OmniLight3D` energy 0.4, color = tribe color, radius=2.0, flicker

---

### 5. TREASURE CHESTS — Physical 3D Animated Chests

**File:** `scripts/TreasureChest.gd` (already exists)

Current state: flat area. Upgrade to:

- Chest base: `BoxMesh` 0.6×0.4×0.4, wood-brown material
- Lid: separate `MeshInstance3D` `BoxMesh` 0.6×0.2×0.4, hinge at back edge
- Locked state: `OmniLight3D` dim amber glow
- On open (player interact): tween lid `rotation.x` from 0 → -110° over 0.6s
- Golden sparkle burst: `GPUParticles3D` 40 particles, gold color, sphere emission
- Stone gem mesh appears floating above chest: small `SphereMesh` tinted gem color,
  bobbing up/down tween, spinning on Y axis

---

### 6. GEMSTONE HUD — Ephod Breastplate Tracker

**File:** `scripts/WorldBase.gd` → `_build_hud()` (currently just a counter label)

Replace `"💎 X/12"` label with a visual ephod minimap:

```gdscript
# In _build_hud(), after existing top bar, add bottom-right ephod panel:
var ephod_panel = PanelContainer ... (120×160 px, bottom right)
# 12 gem slots in 4 rows of 3 (Exodus 28 ephod order)
# Each gem = small ColorRect 24×24, rounded corners
# Unlocked gem: tribe color, glowing border tween
# Locked gem: dark grey, no glow
# On stone collected: flash animation (scale 1→1.6→1 over 0.5s) + chime sfx
# Tooltip on hover: tribe name + gem name (e.g. "Judah — Emerald")
```

---

### 7. DIALOGUE SYSTEM — Animated Text with Emotion

**File:** `scripts/WorldBase.gd` → `show_dialogue()` + `_advance_dialogue()`

Current: instant text display. Upgrade to:

- **Typewriter effect**: reveal one character every 0.03s using a `Timer` or `await`
  loop: `for i in full_text.length(): _dialogue_text.text = full_text.substr(0,i+1)`
- **Tap to skip**: if player taps during typewriter, jump to full text immediately
- **Emotion tinting**: if text contains "!" → tint name label red-orange briefly
  if text contains "shalom" → tint name label warm gold briefly
  if text contains "child" → portrait gentle scale pulse 1→1.1→1
- **Speaker portrait update**: when speaker changes, tween portrait's
  `modulate.a` 1→0→1 while swapping tribe initial badge color
- **Dialogue slide-in**: panel starts at `offset_top = 20.0` (below screen) and
  tweens to `offset_top = -220.0` in 0.25s on first line open
- **Elder voice**: on each new dialogue line, `AudioManager.play_voice(speaker_name)`

---

### 8. PARTICLE CELEBRATIONS — Every Stone Collection

**File:** `scripts/WorldBase.gd` → `_collect_stone()` (GPUParticles3D already there)

Enhance the existing celebration:

- Add 3 burst `GPUParticles3D` rings: gold inner, white middle, tribe-color outer
- Camera shake: `_camera_shake(0.5, 0.2)`
- Player celebrate animation: spin + scale tween
- HUD gem slot flash for the collected tribe
- Floating `+1 Stone` text: `Label3D` at stone position, tween Y+2, alpha 1→0

---

### 9. TOUCH CONTROLS — Full Mobile Polish

**File:** `scripts/TouchControls.gd` (exists, basic virtual joystick)

Upgrade to:

- Visual joystick: outer ring 120px diameter, tribe color 40% opacity
- Inner dot: 40px, tribe color 100% opacity, moves within outer ring
- Show joystick only when finger touches lower-left quadrant
- Hide after 1.5s of no touch
- Add `tap_zone` on right side (right 40% of screen) for `ui_accept` / interact
- Swipe detection: track start/end position, emit `swipe_detected(Vector2 direction)`
  signal, used by `build_swipe_minigame` in WorldBase

---

### 10. FINALE SCENE — Ephod Weave Animation

**File:** `scripts/Finale.gd` + `scenes/Finale.tscn`

The finale should be the most visually stunning scene:

- Background: the detailed courtyard scene (gold-plated cedar pillars,
  blue/purple/scarlet curtain wall, seven-flame lampstand, thick veil)
- Characters: all collected tribes' player avatars arranged in a semicircle
  (instantiate PlayerBody.gd for each completed tribe with their colors)
- Ephod breastplate center stage: 12 gem slots in Exodus 28 arrangement
- Weave animation sequence:

  ```
  for each tribe (in Exodus 28 order):
      - Avatar steps forward with stone
      - Gold thread particles fly from player to gem slot (bezier tween path)
      - Gem slot lights up with gem color + particle burst
      - Chime note plays (C D E F G A B C# D# E# F# G#) — one per tribe
      - Avatar steps back, brief bow animation
  ```

- Final moment: all 12 gems glow simultaneously, light bloom expands from breastplate,
  white-gold particles fill the screen
- Text fades in: "He is the Treasure" (Colossians 2:3)
- Then: "Well done. Your stones are woven." — elder voice
- Fade to starfield → credits

---

### 11. VERSE VAULT SCENE — Visual Encyclopedia

**File:** `scripts/VerseVaultScene.gd` + `scenes/VerseVaultScene.tscn`

Current: basic text list. Upgrade to:

- Flip-book style: each verse is a parchment card with:
  - Tribe initial badge (large, 88px) top-left
  - Verse text center, styled font
  - Nature fact illustration: `TextureRect` showing an animal/nature image
  - Heart badge glow if memorized
- Swipe-left/right gesture navigation (use `swipe_detected` signal from TouchControls)
- Filter by tribe: top row of 12 small tribe initial badges, tap to filter
- Search: LineEdit that filters by verse text in real time

---

### 12. AVATAR PICK SCENE — Rich Character Selection

**File:** `scripts/AvatarPick.gd` + `scenes/AvatarPick.tscn`

Current: grid of buttons. Upgrade to:

- The 12 tribe badges displayed as a honeycomb grid (top section)
- Tap tribe → expand to show 3-4 avatar cards (slide-down animation)
- Each avatar card:
  - Mini 3D character preview (SubViewport with a PlayerBody mesh tinted tribe color)
  - Name + age badge
  - Backstory text (2 lines, truncated)
  - Gameplay edge text in tribe color
- Selected avatar: pulsing border + scale 1.05, tribe particle effect
- "Begin Your Journey" button: appears only after avatar selected, gold gradient

---

## Code Style Rules (STRICTLY FOLLOW)

```gdscript
# All functions must have typed return values
# Biblical references in comments: # "Verse text" – Reference
# Snake_case vars, PascalCase class/scene names
# Mobile minimum touch target: custom_minimum_size = Vector2(44, 44)
# Scene changes always: var r := get_tree().change_scene_to_file(...)
#                        if r != OK: push_error("...")
# No magic numbers — use named constants
# All ResourceLoader.exists() checks before load()
# Error guards on all get_node_or_null() — null check before use
```

---

## File Priority Order (implement in this sequence)

1. `scripts/PlayerBody.gd` — full animated 3D character (everything else depends on this)
2. `scripts/WorldBase.gd` — camera system upgrade + terrain feature methods
3. `scripts/VisualEnvironment.gd` — tribe-specific terrain elements per biome  
4. Per-quest terrain upgrades: Quest1, Quest2, Quest3 first (then 4-12 follow same pattern)
5. `scripts/WorldBase.gd` — dialogue typewriter + emotion system
6. `scripts/WorldBase.gd` — ephod HUD gem tracker
7. `scripts/TouchControls.gd` — visual joystick polish
8. `scripts/TreasureChest.gd` — 3D chest with open animation
9. `scripts/Finale.gd` — weave animation sequence
10. `scripts/AvatarPick.gd` — rich character selection UI

---

## What NOT to do

- Do NOT change `extends "res://scripts/WorldBase.gd"` in any Quest file
- Do NOT add duplicate function definitions (check with `grep -n "^func " | sort | uniq -d`)
- Do NOT rename `_tr`, `_wall`, `_chest`, `_build_npc` in WorldBase (Quest5-12 use them)
- Do NOT use `CharacterBody2D` anywhere — this is a 3D game
- Do NOT add `class_name` to scripts that extend file strings (Godot 4.x limitation)
- Do NOT use violence, stats, HP, or power-ups — failure is ALWAYS gentle and encouraging
- Do NOT use the words "temple" or "church" — use physical descriptors only

---

## The Promise

When complete, this game will be:

- **Visually**: Soft 3D cartoon world worthy of a Nintendo publish — warm, diverse,
  inviting. Every tribe's world instantly recognizable by color + biome + sound.
- **Mechanically**: Better than Zelda for its audience — accessible touch controls,
  gentle failure, deep exploration, cross-tribe co-op emergent play.
- **Spiritually**: Every mechanic teaches something true — patience through rhythm,
  discovery through exploration, unity through cooperation.
- **Technically**: Clean Godot 4.6.1 GDScript, mobile-first, 34/34 Playwright tests
  passing, exportable to Android/iOS/Web with zero parse errors.

"Unless the LORD builds the house, the builders labor in vain." – Psalm 127:1
Build with that in mind.
