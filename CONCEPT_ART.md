# Concept Art & Animation Direction — Twelve Stones: Ephod Quest
## High-Fidelity 3D Edition — Production Bible

> *"He has filled them with skill to do all kinds of work as engravers, designers,
> embroiderers… and weavers — all of them skilled workers and designers."*
> — Exodus 35:35

---

## Team Assignment

| Role | Owner | Scope |
|------|-------|-------|
| **Art Director** | Elias (Lead) | Visual language, style consistency, final approvals |
| **Character Lead** | Character Team A | Avatars (48 variants), Elders (12), NPCs |
| **Environment Lead** | Environment Team B | 12 tribe biomes, Finale courtyard, UI backdrops |
| **Tech Art Lead** | Tech Art Team C | PBR shaders, SSS skin, cloth sim, LOD pipeline |
| **VFX Lead** | VFX Team D | Particles, god rays, stone glow, ephod weave, bloom |
| **Animation Lead** | Animation Team E | Mocap cleanup, idle/walk/praise/blessing cycles |
| **UI/UX Lead** | UI Team F | HUD, scroll unroll, loading screens, gem popups |
| **Audio Lead** | Audio Team G | Spatial SFX, tribal themes, voice murmurs, reverb |
| **QA Lead** | QA Team H | Visual bug hunting, platform parity, LOD QA |
| **Accessibility Lead** | QA Team H | Colour-blind filters, subtitle timing, motor-assist |

---

## 1. Overall Style Direction

### Art Language
Photorealistic 3D with cinematic warmth — the emotional softness of *Pixar's Soul*
layered onto the environmental grandeur of *God of War Ragnarök*. High-poly, PBR,
biblically faithful, but never cold or intimidating. Every frame should feel like
a hand-painted oil canvas come to life.

**Key directive:** Realism serves *wonder*, not *grit*. No dark palettes,
no horror lighting, no realistic wounds. This is the world as God intended it —
radiant, alive, and full of gentle people doing courageous things.

### Renderer (Godot 4 / Vulkan)
- **Rendering path**: Forward+ (Vulkan) for PC/console; Mobile Vulkan with baked GI fallback
- **Global illumination**: SDFGI (Signed Distance Field GI) for real-time soft light
- **Reflections**: Screen-space + ray-traced on water, stone, gold surfaces (`RenderingServer`)
- **Ambient Occlusion**: SSAO medium; HBAO on PC ultra preset
- **Post-process stack**: Bloom (halo only — no lens flare excess), SSIL, vignette (subtle),
  colour grading via `Environment.adjustment_*`; no chromatic aberration (headache risk for children)

### Resolution Targets

| Platform | Resolution | FPS | Upscaling |
|----------|-----------|-----|-----------|
| PC (ultra) | Native 4K | 60–120 | FSR 2 Quality |
| PC (medium) | 1080p | 60 | FSR 2 Performance |
| Android flagship | 1440p→1080p TAA | 60 | FSR Mobile |
| Android mid-range | 720p | 30 stable | Off |
| iOS | Native retina | 60 | MetalFX |
| Web | 1080p | 60 | — |

### Palette

| Token | Hex | Use |
|-------|-----|-----|
| Sunset Gold | `#F4C430` | Ephod highlights, elder robes, sunrise scenes |
| Terracotta Clay | `#C1440E` | Reuben cliffs, earthen walls, tribal borders |
| Olive Sage | `#5D7555` | Vegetation, Asher valley, Gad mountain meadows |
| Azure Sky | `#4A90E2` | Dan coastal mist, Naphtali night sky, water |
| Parchment Cream | `#F5F0E1` | Scroll UI, dialogue panels, elder robes |
| Ephod Radiance | `#FFD700 + Bloom` | Stones collecting, breastplate weave, Finale |
| Skin Warm | `#D4956A` | Warm tan baseline — varies per character |
| Shadow Purple | `#3D2B5E` | Cave interiors, night scenes, deep water |

*Subtle desaturation in ambient areas, vivid saturation pops on holy/spiritual moments
(stone collection, verse reveal, co-op syncs).*

---

## 2. Character Design

**Owner: Character Team A**

### Avatars (48 total — 4 per tribe)

- **Polycount**: 45k–60k triangles per character (Hero LOD 0)
- **LOD chain**: 60k → 20k → 8k → 2k at distances 0–5m, 5–20m, 20–80m, 80m+
- **Textures**: 8K albedo + normal + roughness/metallic/AO (combined ORM packed)
  - Face: 4K dedicated diffuse with SSS mask layer
  - Robe: 4K tileable fabric (PBR weave normal map per tribe)
- **Hair**: Strand-based (Godot 4 `MeshInstance3D` with custom hair shader, ~8k strands
  for hero close-up, groom baked to card mesh for LOD1+)
- **Cloth physics**: `SoftBody3D` on robe hem and tzitzit (tassels); fallback to baked
  animation on mobile
- **Morph targets** (shape keys): Smile, wide-eyes-wonder, brow-raise, praise-mouth,
  sad-brow, stern-focus — 6 target minimum per avatar

**Skin diversity**: Middle Eastern, East African, Mediterranean, Levantine — all informed
by Genesis 49 / ancestral geography. No stereotype casting. Reference: SPRITE_CATALOG.md character rows.

**Example — Ezra (Reuben):** Lean build, curly black hair (10k strand sim), hazel eyes with iris
reflection capture, warm freckled skin via SSS. Idle: gentle breathing, occasional olive leaf
in hair sways slowly.

### Elder NPCs (12)

- Polycount: 55k–70k (more facial geometry for wrinkle detail)
- 8K face texture with micro-detail layer (laugh lines, sun freckles, beard pore depth)
- Beard: Individual strand simulation for close-up, baked card mesh for gameplay distance
- Staffs: PBR wood grain + glowing tribal rune (emissive `EMISSION_ENERGY` animated via tween)
- Animation set: 200+ poses — blessing hands, scroll unroll, head nod, kneel, point-to-horizon
- Robe embroidery: Procedural shader using `ShaderMaterial` with UV-animated thread pattern

**Accessibility note (QA Team H):** All avatars must pass deuteranopia/protanopia
contrast checks on tribe-ring colour. Provide shape-based fallback icon per tribe.

---

## 3. Environment Design

**Owner: Environment Team B + Tech Art Team C**

### World Scale & Structure
- 12 tribe worlds, each ~1800×1400 world units scaled to 1km² effective play area
- Seamless LOD via Godot `VisibilityNotifier3D` + occlusion culling enabled
- Draw distance: 10km scenic LOD, 500m high-detail, 50m hero-detail
- Day/night cycle: `Environment.sky` animated via `Sun` `DirectionalLight3D` tween
- Weather system: Optional sandstorm (Simeon/Reuben), rain (Zebulun/Dan), leaf shower (Naphtali)
  — each uses `GPUParticles3D` with mobile count reduction (WorldBase.gd ✅)

### Per-Tribe Environment Briefs

| Tribe | Biome Theme | Hero Detail | Signature Moment |
|-------|-------------|-------------|------------------|
| Reuben | Sandstone canyon, dawn mist | Bioluminescent butterflies (ray-traced refraction) | Ladder climb with god-ray sunrise |
| Simeon | Ochre dunes, oasis palms | Heat shimmer shader (`TIME`-based UV distortion) | Sheep-call echo across dunes |
| Levi | Cedar beams, gold lampstand | 7-flame real-time fire particles, veil cloth sim | Scroll-match in lampstand glow |
| Judah | Terraced vineyard, savanna | Lion roar wind ripple (grass shader) | Praise-roar shockwave animation |
| Dan | Coastal fog, granite cliffs | Eagle soar `Path3D` spline | Eagle vision zoom (cinematic FOV shift) |
| Naphtali | Dense pine, firefly meadow | Firefly swarm (GPU particle emission billboards) | Good-news run through light-dappled trees |
| Gad | Alpine pass, olive grove | Snow-cap geometry + vertex paint blend | Endurance climb with co-op rope IK |
| Asher | Orchard, beehive, village | Bee waggle dance (procedural animation) | Bread-share table scene |
| Issachar | Star circle, harvest fields | Constellation overlay (canvas layer shader) | Season-read puzzle under Milky Way |
| Zebulun | Dock, market, sea cliff | Ocean shader (tessellation waves, foam) | Hospitality welcome at harbour gate |
| Joseph | Vine rows, well, granary | Pearl formation shader (iridescent mat) | Forgiveness reunion scene |
| Benjamin | Pine clearing, wolf dens | Moonbeam shaft (volumetric spotlight) | Wolf pack IK howl sync |

### Finale Courtyard
The centrepiece — a hyper-detailed gathering space:
- **Gold pillars**: PBR metallic (roughness 0.05, metallic 1.0) with leaf-carved geometry
- **Curtains**: `SoftBody3D` blue/purple/scarlet cloth with wind sway
- **7-flame lampstand**: Real-time `OmniLight3D` per flame, fire particles, dynamic shadows
- **Curtain veil**: Embroidered cherubim faces (normal map + emissive trim) — never referred to
  in dialogue as "temple" — physical descriptors only per biblical fidelity rules
- **Crowd**: 12+ player characters visible simultaneously via GPU-instanced meshes
- **Stone slots**: 12 breastplate recesses in polished brass frame (dim → tribe-glow on fill)
- **Gold threads**: Spline-animated `ImmediateMesh` cables weaving between stone slots

---

## 4. VFX Direction

**Owner: VFX Team D**

| Effect | Trigger | System | Mobile Fallback |
|--------|---------|--------|----------------|
| Stone collect burst | `_collect_stone()` | GPUParticles3D gold 50p | 12p (WorldBase ✅) |
| Verse reveal shimmer | Scroll popup | Shader `TIME` UV scroll on parchment | Tween alpha |
| Praise shockwave | Judah roar peak | Screen-space ripple `ShaderMaterial` | Tween scale ring |
| Firefly swarm | Levi/Naphtali/Joseph | GPUParticles3D emission spheres | Halved (WorldBase ✅) |
| God ray | Sunrise, stone collect | `SpotLight3D` + volumetric fog plane | Baked sprite billboard |
| Heart bloom | Co-op sync | Emissive `MeshInstance3D` pulse tween | Same (light-weight) |
| Ephod weave threads | Finale | `ImmediateMesh` spline cables + emission | Simplified tween lines |
| Urim/Thummim ignite | Finale climax | Deferred light burst + AudioManager sting | Bloom tween |
| Eagle soar trail | Dan quest | GPUParticles3D feather debris | 8p sprite particles |
| Water ripple | Zebulun / Reuben | `wave` function shader on water plane | Static normal map |

### Particle Budget (per scene, PC Ultra)
- Ambient: 80–120 (WorldBase `_add_ambient_particles()` ✅)
- NPC glow rings: 1 `OmniLight3D` per NPC ✅
- Max 3 active foreground particle systems simultaneously
- Stone burst: 50p one-shot, `one_shot = true`, auto `queue_free()` after 3s

---

## 5. Animation Direction

**Owner: Animation Team E**

### Avatar Animation Set (minimum per character)

| State | Frames | Notes |
|-------|--------|-------|
| Idle | 120 | Gentle breathing (~0.3s cycle), micro hair sway |
| Walk | 60 | Smooth foot-plant, tzitzit sway at 0.5× walk phase |
| Run | 40 | Leaning forward, hair trail |
| Interact (reach) | 30 | One-hand reach, eye IK toward object |
| Talk (nod) | 45 | Head bob, lip sync shape keys active |
| Praise (arms up) | 60 | Wide arms, head back, joyful mouth morph |
| Pray (bow) | 80 | Slow bow, hands folded, settle |
| Celebrate (jump) | 50 | Small hop, landing, smile morph |
| Receive stone | 90 | Reach forward, close hand, look-at-stone |

### Elder Animation Set (minimum)

| State | Notes |
|-------|-------|
| Wise nod | 2-beat head nod + closed-eye blink |
| Hand on shoulder | IK hand on avatar `BoneAttachment3D` shoulder |
| Scroll unroll | `AnimationPlayer` on prop + particle dust |
| Point to horizon | Arm extend, head turn, gaze IK toward target |
| Kneel for blessing | Slow kneel, deliberate, warm |

### Cinematic Animations

- **Logo intro** (30s): Camera dolly through olive grove → Ephod assembly. Stones orbit
  via `Path3D` elliptical splines, gold cable threads animate. Score: orchestral build
  ending in `finale_sting.wav`.
- **Quest transitions** (5–8s): `Camera3D` `Path3D` drone sweep over biome, fade to world.
  `AnimationPlayer` shifts `Environment.sky` time-of-day.
- **Co-op hand-hold** (IK sync): `SkeletonIK3D` chains player hand bones to shared
  `BoneAttachment3D` midpoint. Shared glow aura `OmniLight3D` energy tween from join point.
- **Ephod weave** (60s finale): `RigidBody3D` stones drop into slots; cable splines interlace;
  Urim/Thummim lights last; deferred light burst; all crowd characters celebrate simultaneously.

---

## 6. UI & HUD Design

**Owner: UI Team F**

- **Stone inventory**: 12 holographic orb slots in bottom HUD bar. Tribe-coloured glow ring.
  Empty = dim grey sphere; Filled = gem SVG + pulsing `OmniLight3D`.
- **Compass**: Top HUD, tribal icon at objective direction. 44pt+ touch target, fades in cutscenes.
- **Verse popup**: `AnimationPlayer`-driven 3D scroll (`panel_parchment.jpg` surface) unrolling
  from top. `SoftBody3D` page physics on desktop; `Tween` rotation fallback on mobile.
- **Gem popup**: Full-screen dim overlay + centred gem SVG + bloom (WorldBase.gd ✅).
- **Loading screens**: Characters "weave" Ephod threads via `AnimationPlayer` on 2D spline paths.
  Progress bar = stone slots filling left-to-right.
- **Minimum font size**: 16pt body, 20pt headings — enforced project-wide.
- **Touch targets**: All interactive elements ≥ 44×44px (`custom_minimum_size` required).

---

## 7. Audio Direction

**Owner: Audio Team G**

### Spatial Audio
- SFX placed via `AudioStreamPlayer3D` with `area_mask` per zone
- Reverb presets: Cave (`AudioEffectReverb` large), courtyard (medium), exterior (subtle)
- Footsteps: Surface-tagged via `PhysicsMaterial`; `AudioManager` picks correct clip
- Elder voices: Lofi murmur system wired in `AudioManager.gd` ✅

### Music Architecture
- 12 per-tribe quest themes + 8 scene themes (all in `AssetRegistry.MUSIC` ✅)
- Dynamic cross-fade: `AudioManager.cross_fade(new_track)` on scene transitions
- Co-op bonus layer: Second audio bus unmuted when cross-tribe players meet (layered score)
- Finale: Orchestral build — each tribe's instrument joins as their stone is placed

### Priority Audio Queue

| File | Priority | Style Notes |
|------|----------|-------------|
| `elder_murmur_1/2/3.wav` | HIGH | Warm, low, reassuring |
| `child_murmur_1/2.wav` | HIGH | Bright, inquisitive, gentle |
| `co_op_sync_chime.wav` | MED | Bell + string, 2-note harmony |
| `stone_place_finale.wav` | MED | Stone on stone, warm resonance |
| `urim_thummim_ignite.wav` | HIGH | Orchestral swell + harmonic overtone |

---

## 8. Accessibility Standards

**Owner: QA Team H**

- **Colour-blind**: All gem/tribe colours have shape-based secondary indicator. Test against
  Deuteranopia, Protanopia, Tritanopia profiles.
- **Motor assist**: Extended timer option (`time_limit` × 2.0); tap count halved in assist mode.
- **Reading**: Dialogue text ≥ 16pt. Verse scrolls pauseable indefinitely. Screen reader hint
  text on all `Button` nodes.
- **Flicker safety**: No effects faster than 3 Hz. Stone collect flash = 1 frame bloom, not strobe.
- **Touch targets**: Minimum 44×44px everywhere — enforced via `custom_minimum_size`.

---

## 9. Implementation Roadmap

| Milestone | Owner | Sprint | Status |
|-----------|-------|--------|--------|
| Procedural cartoon characters (Character.gd) | Tech Art C | S1 | ✅ Integrated into PlayerBody.gd |
| Elder SVGs (12) | Character A | S1 | ✅ `assets/sprites/elders/` |
| Gem SVGs (12) | VFX D | S1 | ✅ `assets/sprites/gems/` |
| Avatar SVGs (32) | Character A | S1 | ✅ `assets/sprites/avatars/` |
| Mobile particle reduction | Tech Art C | S1 | ✅ WorldBase.gd |
| All 12 biome worlds | Environment B | S1 | ✅ Quest1–12.gd |
| PBR skin SSS shader | Tech Art C | S2 | 🔲 Character.gd `_skin_mat` |
| Strand hair shader | Tech Art C | S2 | 🔲 Custom `ShaderMaterial` |
| Cloth sim (robe hem, tzitzit) | Tech Art C | S2 | 🔲 `SoftBody3D` on avatar |
| Voice murmur recordings | Audio G | S2 | 🔲 lofi system wired ✅ |
| Dynamic weather per biome | Environment B | S3 | 🔲 WorldBase weather layer |
| Elder mocap animation set | Animation E | S3 | 🔲 `AnimationPlayer` per NPC |
| Co-op IK hand-hold | Animation E | S3 | 🔲 `SkeletonIK3D` |
| Finale ephod spline cables | VFX D + Anim E | S3 | 🔲 `ImmediateMesh` splines |
| Spatial reverb zones | Audio G | S3 | 🔲 `AudioEffectReverb` per zone |
| LOD pipeline automation | Tech Art C | S4 | 🔲 LOD generation script |
| FSR 2 integration | Tech Art C | S4 | 🔲 Godot rendering plugin |
| Accessibility full pass | QA H | S4 | 🔲 All platforms |
| Final visual/audio QA parity | QA H | S5 | 🔲 All 4 platforms |

---

## 10. Biblical Fidelity Checklist for All Artists

Before submitting any asset, verify:

- [ ] No word "temple" or "church" in any texture text, scroll, or UI label
      → Physical descriptors only: "gold-plated cedar pillars", "blue and purple and scarlet
        curtains", "the seven-flame lampstand"
- [ ] Tribe colour matches `Global.gd TRIBES["x"]["color"]` exactly
- [ ] Gem appearance matches Exodus 28:17-20 (see `SPRITE_CATALOG.md` gem colour table)
- [ ] Elder robe does NOT include priestly ephod (only the breastplate finale NPC wears it)
- [ ] All scripture text quoted verbatim from NIV or KJV — no paraphrase
- [ ] Nature fact is real science — verify in `Global.gd` `nature_fact` field
- [ ] No violent imagery, no weapon props, no blood particles — ever
- [ ] Elders always look warm and welcoming — never stern or intimidating

---

*"Whatever you do, work at it with all your heart, as working for the Lord."*
*— Colossians 3:23*

*Last updated: February 22, 2026 — Art Director assignment, full team structure, Sprint roadmap added.*