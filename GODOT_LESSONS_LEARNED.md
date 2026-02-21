# Godot 4 — Lessons Learned (Twelve Stones / Ephod Quest)

A living "remember this" file. Every entry is a real bug or surprise we hit
in this project. Update it whenever a new gotcha is discovered.

---

## 0  Private method calls from static functions — linter false positives

**Problem:**
In Character.gd, static `create()` method called `char._build_visual()` on the instance.
GDScript linter flagged "[private-access] Private method '_build_visual' should not be called from outside its class" even though it's the same class.

**Fix:**
Renamed `_build_visual()` to `build_visual()` (public) and updated all calls.
Linter accepted it. May be a linter quirk with static methods.

**Files fixed:** Character.gd — all _build_visual calls updated.

---

## 1  `Array[Dictionary]` vs bare `Array` — the strict-mode wall

**Problem:**
Typed arrays (`Array[Dictionary]`, `Array[String]`, etc.) in Godot 4 strict
mode **refuse** plain `[{...}]` literals assigned from *outside* the class.
You get:

```
Invalid assignment of property 'dialogue_lines' with value of type 'Array' on
a base object of type 'Area3D (NPC.gd)'
```

**Rule:**
Use bare `Array` for any public property or function parameter that will
receive `[{...}]` literals from other scripts.
Use `Array[T]` only for *private* variables that you populate internally.

**Files fixed:** `NPC.gd`, `WorldBase.gd`, `QuestBase.gd` — changed all
`Array[Dictionary]` → `Array` for fields & method signatures that cross
class boundaries.

---

## 2  Never name `@export var hidden` (or `visible`, `name`, etc.)

**Problem:**

```
Parse error: Cannot assign a new value to a constant
```

`CanvasItem.hidden` is a **built-in read-only** property on every Node2D /
Control / Area2D (and similarly for 3D equivalents like Node3D.visible). An `@export var hidden: bool` on top of that creates a
conflict Godot rejects as "cannot assign to constant".

**Rule:**
Never shadow built-in Godot Node properties with your own `@export` vars.
Common dangerous names: `hidden`, `visible`, `name`, `owner`, `position`,
`scale`, `rotation`.

**Fix used:** Renamed to `starts_hidden` in `TreasureChest.gd` and updated
the one reference in `Quest1.gd`.

---

## 3  `Control.PRESET_CENTER_WIDE` does not exist

**Problem:** Compiler error — constant not found.

**Fix:** Correct constant is `Control.PRESET_HCENTER_WIDE` (Horizontally
Centred Wide). Check Godot's LayoutPreset enum whenever using named presets.

Useful presets reference:

| Constant | Meaning |
|---|---|
| `PRESET_FULL_RECT` | anchors all 4 sides to parent edges (= preset 15) |
| `PRESET_HCENTER_WIDE` | left=0, right=1, vcenter halfway |
| `PRESET_VCENTER_WIDE` | top=0, bottom=1, hcenter halfway |
| `PRESET_CENTER` | centred, no stretch |

---

## 4  `VisualEnvironment.build(parent: Control)` fails for Node3D scenes

**Problem:**
`WorldBase` (a Node3D scene) passes `self` to static build helpers in
`VisualEnvironment.gd`. Typing the parameter as `parent: Control` means Godot
rejects the `Node3D` at call time with a type error.

**Fix:** Change all static function signatures to `parent: Node`. Inside the
function cast or check as needed. `Node` is the common ancestor of both
`Control` and `Node3D`.

---

## 5  `AudioManager.play_sfx()` silently skips missing files — use it freely

`AudioManager.play_sfx(path)` guards with `ResourceLoader.exists(path)` before
loading. A missing WAV/OGG does **nothing** — no crash, no log spam.

This means you can call it for placeholder audio paths during development and
replace the files later without touching any code.

Same pattern used in `play_voice()` — all voice murmur files can be added
incrementally without breaking existing code.

---

## 6  Build node tree before tinting / reading nodes

**Symptom:** `_tint_sprite()` called early in `_ready()` crashes because the
sprite node doesn't exist yet.

**Rule:** In `_ready()`, always call `_build_visual()` (or whatever populates
child nodes) **before** anything that reads or modifies those children.

Correct order:

```gdscript
func _ready() -> void:
    _build_visual()    # creates nodes
    _tint_sprite()     # now safe to read them
    super._ready()
```

---

## 7  `CONNECT_ONE_SHOT` for single-fire callbacks on dialogue buttons

When a dialogue line has a `"callback"` key, the dialogue button must:

1. Disconnect `_advance_dialogue`
2. Connect a lambda that re-connects `_advance_dialogue`, calls `_advance_dialogue()`, then calls `cb.call()`
3. Pass `CONNECT_ONE_SHOT` so it auto-disconnects after firing

Without `CONNECT_ONE_SHOT` the lambda connects again every time that dialogue
sequence replays. Use the flag consistently for one-time button events.

---

## 8  `InteractionArea` must not exist in both .tscn AND dynamic creation

If `PlayerBody.gd` creates an `InteractionArea` node dynamically in `_ready()`,
**do not** also add an `Area3D` named `InteractionArea` in the `.tscn` file.
Godot will end up with two overlapping areas; you get double interactions and
confusing signal connections.

---

## 9  `player.set_physics_process(false)` must always be restored

Every place that disables player physics during a UI panel (dialogue, verse,
nature fact, mini-game) **must** re-enable it on every exit path:

- Normal completion
- Timeout
- Skip / dismiss
- Scene change (if physics stays paused, the next scene inherits it)

Pattern in `WorldBase._on_nature_done()` is the reference.

---

## 10  `queue_free()` all procedural mini-game containers

Any `PanelContainer` or other node created via code for a mini-game must
call `queue_free()` when the mini-game finishes **or** times out. Otherwise
dead UI panels pile up across the scene.

```gdscript
func _on_minigame_complete(result: Dictionary) -> void:
    _minigame_root.queue_free()   # always clean up
    on_minigame_complete(result)
```

---

## 11  Lofi voice murmur system

All dialogue interactions now play a short `*.wav` voice murmur via
`AudioManager.play_voice(speaker_name)`.

File locations expected:

```
res://assets/audio/sfx/voice/elder_murmur_1.wav   (warm low)
res://assets/audio/sfx/voice/elder_murmur_2.wav
res://assets/audio/sfx/voice/elder_murmur_3.wav
res://assets/audio/sfx/voice/child_murmur_1.wav   (bright, inquisitive)
res://assets/audio/sfx/voice/child_murmur_2.wav
res://assets/audio/sfx/voice/neutral_murmur_1.wav (generic NPC)
res://assets/audio/sfx/voice/neutral_murmur_2.wav
```

Missing files are silently skipped — add them whenever ready.

Speaker routing:

- `"You"` or `"Player"` → child murmurs
- Anything containing `"Elder"` → elder murmurs
- Everything else → neutral murmurs

---

## 12  Typed `int`/`float` from `.get()` needs explicit cast

`Dictionary.get("key", fallback)` returns `Variant`. Even if you know the
value is an int, Godot strict mode will complain when assigning to a typed var.

Use `as int` / `as float` / `as String`:

```gdscript
var age: int = data.get("age", 15) as int
var name: String = data.get("name", "") as String
```

---

## 13  Multiplayer RPC — peer authority checks

If an RPC is decorated `@rpc("any_peer", "call_remote", "reliable")`, **any
peer can call it**, including hostile ones. For game-state-mutating RPCs that
should only originate from the server/host, add:

```gdscript
if not is_multiplayer_authority():
    return
```

at the top of the function, or use `@rpc("authority", ...)` instead.

---

## 14  ENet disconnect — always emit `player_left` signal before dictionary removal

Removing a peer from `players` dict inside `_on_peer_disconnected()` before
notifying the UI means the UI callback receives an ID that no longer maps to
data. Signal first, remove second.

---

*Last updated: session — e2e testing completed, private method linter fix, documents updated.*

## 15  PlayerBody visual representation — start with ColorRect placeholder

**Problem:** PlayerBody needs visible sprite for testing, but no assets yet.

**Solution:** Add MeshInstance in _build_visual() as placeholder body. Tint with tribe color. Replace with AnimatedSprite3D when assets ready.

**Code:**

```gdscript
var sprite := MeshInstance3D.new()
sprite.name = "PlayerSprite"
var mesh := BoxMesh.new()
mesh.size = Vector3(0.5, 1.0, 0.5)
sprite.mesh = mesh
var material := StandardMaterial3D.new()
material.albedo_color = Color(0.8, 0.6, 0.4, 1)
sprite.material_override = material
add_child(sprite)
```

## 16  Asset folder structure — create README.md in each subfolder

**Problem:** Need to organize 100+ sprite files without confusion.

**Solution:** Create assets/sprites/characters/README.md listing required files, formats, animations. Repeat for backgrounds, action_spots, items, ui, tiles, shaders.

**Benefits:** Artists know exactly what to create; developers know paths.

## 17  Rendering system autoloads — Character, WorldGenerator, Inventory

**Problem:** Need modular character/world/object rendering for quick scene setup.

**Solution:** Create autoloads with static methods:

- `Character.create(tribe, avatar, role)` → Node3D with AnimatedSprite3D
- `WorldGenerator.generate(biome, parent)` → GridMap + ParallaxBackground (adapted for 3D)
- `Inventory.create_pickup(item, position)` → RigidBody3D with physics

**Usage:** Call from _ready() for instant visuals.

## 18  Fix variable name casing — SEGS vs segs

**Problem:** `var SEGS := 18` then `float(SEGS)` — linter complains about uppercase.

**Solution:** Use `var segs := 18` and `float(segs)`. Follow snake_case for locals.

## 19  Remove UNUSED functions — on_quest_ready_UNUSED

**Problem:** Dead code in Quest3.gd and Quest4.gd causing linter errors.

**Solution:** Delete functions not called. Keep code clean for production.

---

## 20  Never use `@onready` in scripts that have NO .tscn parent scene

**Problem:**
`Character.gd` had `@onready var sprite: AnimatedSprite3D = $AnimatedSprite2D` etc.
Since Character is instantiated via `.new()` with no `.tscn`, every `@onready`
resolves to `null` → first-frame access crashes.

**Rule:** Scripts instantiated with `.new()` must build all child nodes
procedurally in `_ready()`. Never use `@onready` without a `.tscn`.

**Fix:** Rewrote Character.gd with procedural `MeshInstance3D / OmniLight3D`
builders. No sprite sheets, no shader files, no scene nodes required.

---

## 21  `static func create() -> Node2D` must match the actual class base

**Problem:** Character extends Node3D but factory returned Node2D — type mismatch
when adding to 3D scenes.

**Fix:** Return type must match class. Use `char.set("prop", value)` dynamic set
instead of `char as ClassName` when class_name is not declared.

---

## 22  Bash heredoc destroys GDScript indentation + UTF-8 em-dash characters

**Problem:** Bash heredoc strips leading tabs and mangles em-dash into garbage bytes.
Resulting .gd file fails to parse.

**Rule:** NEVER write GDScript via bash heredoc.
Use `create_file` tool or Python `open(path,'w').write(...)` instead.

---

## 23  Godot EDITOR shows stale "Could not resolve class" — headless parse is truth

**Problem:** Editor caches failed parse results.  After fixing a dependency error,
quest files still show "Could not resolve WorldBase.gd" in the editor panel.

**Rule:** Run headless parse to confirm real status:
```
Godot --headless --path /project --quit-after 3 2>&1 | grep -iE "script error|parse|failed"
```
Empty output = zero errors.  Editor panel alone is unreliable after cascading errors.

---

## 24  `Dictionary.get()` with `:=` infers Variant — warning treated as error

```gdscript
# BAD  — Variant inference
var hex := TRIBE_HEX.get(tribe_key, "8B6F47")

# GOOD — explicit type
var hex: String = TRIBE_HEX.get(tribe_key, "8B6F47") as String
```

---

## 25  Local method names must not shadow WorldBase virtuals

Quest2.gd had `func _wall(r: Rect2)` while WorldBase has `func _wall(pos, size, texture)`.
GDScript rejects mismatched override signatures at compile time.

**Rule:** Rename local helpers: `_draw_wall`, `_spawn_npc`, `_spawn_chest`, `_draw_tile`.

---

*Last updated: session — Character.gd fully procedural 3D, 34/34 tests green.*
