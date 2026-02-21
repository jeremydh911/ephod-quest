# Twelve Stones — Sprite Catalog
>
> **Series Template** — This catalog lists every sprite in the `assets/sprites/` library.
> All future games in the Twelve Stones series should reference and extend this catalog.
> All sprites are SVG format (Godot 4 native). Loaded via `AssetRegistry.gd` static dicts.

---

## Category: `gems/` — 12 Tribe Gemstones

*Exodus 28:17-21 — the 4-row breastplate stones, one per tribe*

| File | Tribe | Stone (KJV) | Colour |
|------|-------|-------------|--------|
| `gem_reuben.svg` | Reuben | Sardius/Carnelian | Deep red |
| `gem_simeon.svg` | Simeon | Topaz | Yellow-green |
| `gem_levi.svg` | Levi | Carbuncle | Red-garnet |
| `gem_judah.svg` | Judah | Emerald | Vivid green |
| `gem_dan.svg` | Dan | Sapphire | Royal blue |
| `gem_naphtali.svg` | Naphtali | Diamond | White-clear |
| `gem_gad.svg` | Gad | Ligure/Jacinth | Orange-amber |
| `gem_asher.svg` | Asher | Agate | Blue-banded |
| `gem_issachar.svg` | Issachar | Amethyst | Purple |
| `gem_zebulun.svg` | Zebulun | Beryl | Sea-green |
| `gem_joseph.svg` | Joseph | Onyx | Black-white |
| `gem_benjamin.svg` | Benjamin | Jasper | Vivid green |

**GDScript access:** `AssetRegistry.gem("reuben")`  
**Source:** Designed to match Exodus 28:17-21 (NIV/KJV cross-reference)

---

## Category: `elders/` — 12 Tribe Elders + 6 Elder Variants

### Tribe Elders (NPC dialogue portraits)

| File | Tribe | Elder Name | Description |
|------|-------|------------|-------------|
| `elder_reuben.svg` | Reuben | Hanoch | Warm brown, white-streaked beard |
| `elder_simeon.svg` | Simeon | Nemuel | Olive skin, full grey beard |
| `elder_levi.svg` | Levi | Jashub | Silver hair, priestly white robe |
| `elder_judah.svg` | Judah | Perez | Deep tan, confident posture |
| `elder_dan.svg` | Dan | Shuham | Alert eyes, dark beard |
| `elder_naphtali.svg` | Naphtali | Jahzeel | Gentle face, nature-leaf motif |
| `elder_gad.svg` | Gad | Ziphion | Weathered, sturdy build |
| `elder_asher.svg` | Asher | Jimnah | Warm smile, bread motif sash |
| `elder_issachar.svg` | Issachar | Tola | Wise eyes, scroll in hand |
| `elder_zebulun.svg` | Zebulun | Sered | Sea-blue robe, sailor bearing |
| `elder_joseph.svg` | Joseph | Manasseh | Regal bearing, gold-trim robe |
| `elder_benjamin.svg` | Benjamin | Bela | Youthful elder, kind eyes |

**GDScript access:** `AssetRegistry.elder("judah")`

### Generic Elder Variants (scene-fill, co-op quests, background NPCs)

*Identified from Grok reference art images*

| File | Description | Source Image |
|------|-------------|--------------|
| `elder_grey_teal.svg` | Silver hair, grey beard, teal/sage robe | Image 1 & 2 |
| `elder_white_tan.svg` | White hair, full white beard, warm tan robe | Image 2 |
| `elder_white_grey.svg` | White hair, shorter grey beard, grey robe | Image 4 grid |
| `elder_dark_olive.svg` | Dark complexion, dark beard, olive robe (younger elder) | Image 3 |
| `elder_white_brown.svg` | White hair/beard, brown robe + companion cat | Image 4 grid |
| `elder_silver_blue.svg` | Silver-blue hair, blue robe | Image 2 |

**GDScript access:** `AssetRegistry.elder_variant("elder_grey_teal")`

---

## Category: `characters/` — Diverse Child Avatars (Reference-Art Accurate)

*Ages 12–29, diverse skin/hair/eye/build — Identified from 4 Grok reference images*
*No stereotype casting. Any tribe can have any character.*

| File | Skin | Hair | Tunic | Notes |
|------|------|------|-------|-------|
| `girl_light_curly.svg` | Light | Brown curly | Pink | Image 3 group |
| `boy_light_dark.svg` | Light | Dark straight | Blue | Image 3 group |
| `boy_olive_curly.svg` | Olive | Black curly | Teal | Image 2 teens |
| `boy_olive_short.svg` | Olive | Short black | Cream | Image 3 group |
| `boy_dark_tightcurl.svg` | Dark brown | Tight curls | Rust | Image 3 group |
| `boy_deep_smooth.svg` | Deep | Smooth black | White/Gold robe | Image 2 ephod-wearer |
| `girl_tan_straight.svg` | Tan | Long straight | Earth | Image 4 group |
| `girl_olive_braid.svg` | Olive | Long braid | Blue | Image 4 group |
| `boy_light_gold.svg` | Light | Gold wavy | Gold | Image 2 teens |
| `girl_dark_coils.svg` | Dark | Coiled hair | Lavender | Image 3 group |
| `boy_tan_bangs.svg` | Tan | Dark bangs | Cream | Image 1 grid |
| `girl_light_auburn.svg` | Light | Auburn plaits | Green | Image 3 group |
| `boy_medium_waves.svg` | Medium | Brown waves | Khaki | Image 2 teens |
| `boy_copper_locs.svg` | Copper | Dark locs | Teal | Image 3 group |
| `prayer_pair.svg` | Mixed | — | Blue + Cream | Boy+girl greeting pose (Image 4 grid) |

**GDScript access:** `AssetRegistry.character("girl_light_curly")`

---

## Category: `avatars/` — 32 Playable Avatar Portraits

*Generated systematically: 4 skin × 4 hair × 2 eye colour combinations*
*Used by AvatarPick.tscn avatar selection cards*

**GDScript access:** `AssetRegistry.avatar(index)` or `AssetRegistry.random_avatar()`

---

## Category: `nature/` — Animals & Nature (Science-accurate)

| File | Subject | Science Fact | Verse |
|------|---------|-------------|-------|
| `butterfly.svg` | Butterfly (generic) | Tastes with feet (tarsal chemoreceptors) | Psalm 19:1 |
| `butterfly_colorful.svg` | Butterfly (pink/blue/gold, front-view) | Wing scales are modified hairs | Psalm 19:1 |
| `butterfly_pastel.svg` | Butterfly (teal/blue, side-view) | Cannot fly if body temp < 86°F | Psalm 19:1 |
| `eagle.svg` | Eagle (generic) | 4–8× human vision acuity | Isaiah 40:31 |
| `eagle_soaring.svg` | Bald eagle (soaring, wings spread) | Soars on thermals for hours | Isaiah 40:31 |
| `eagle_profile.svg` | Bald eagle (standing profile) | Can spot prey 2 miles away | Isaiah 40:31 |
| `lion.svg` | Lion | Roar heard up to 5 miles | Genesis 49:9 |
| `deer.svg` | Deer | Leaps 10 ft vertically | Psalm 18:33 |
| `wolf.svg` | Wolf | Pack social structure mirrors tribe unity | Genesis 49:27 |
| `sheep.svg` | Sheep | Recognise up to 50 sheep faces | Psalm 23:1 |
| `fish.svg` | Fish | Schools move as single organism | Matthew 4:19 |
| `olive_branch.svg` (nature) | Olive branch | Olive trees live 2,000+ years | Psalm 128:3 |
| `harp.svg` | Harp | 22 strings = 22 letters of Hebrew alphabet | Psalm 33:2 |
| `star_scroll.svg` | Star chart scroll | Stars named (Isaiah 40:26) | Isaiah 40:26 |
| `cat_companion.svg` | Pet tabby cat | Cats were revered in ancient Near East | — |

**GDScript access:** `AssetRegistry.nature_icon("butterfly")` or `AssetRegistry.nature_ext("eagle_soaring")`

---

## Category: `tools/` — Biblical Implements

*Labeled as TOOLS. Available for future quests, even if not yet in gameplay.*
*All carry biblical reference in SVG comment.*

| File | Tool | Tribe Association | Verse |
|------|------|------------------|-------|
| `shepherd_staff.svg` | Shepherd's crook/rod | Reuben, Joseph | Genesis 49:24 |
| `oil_lamp.svg` | Clay single-flame oil lamp | Levi (tabernacle lamps) | Exodus 27:20 |
| `olive_branch.svg` | Leafy olive branch with olives | Asher | Psalm 128:3 |
| `clay_jug.svg` | Terracotta water/oil vessel | All tribes (daily life) | John 4:14 |
| `cedar_plank.svg` | Hand-carved cedar plank, leaf motif | Levi (construction) | 1 Kings 6:15 |
| `scroll_sealed.svg` | Rolled parchment sealed with wax | Issachar, Levi | Psalm 119:105 |
| `stone_chisel.svg` | Iron chisel + mallet (engraving) | Judah (stone engraving) | Exodus 28:11 |
| `fishing_net.svg` | Woven casting net with sinkers | Zebulun | Matthew 4:19 |
| `bread_loaf.svg` | Round flatbread with sesame seeds | Asher ("rich food") | Genesis 49:20 |
| `balance_scales.svg` | Wooden balance scale | Issachar/justice | Proverbs 16:11 |

**GDScript access:** `AssetRegistry.tool("shepherd_staff")`

---

## Category: `items/` — Quest Collectibles & Key Items

*Exodus 28 ephod / hoshen variants — the central sacred object of the game*

| File | Item | Description | Verse |
|------|------|-------------|-------|
| `ephod_flat.svg` | Hoshen (flat/top-down) | 4×3 gem grid, gold threads, woven, with chains | Exodus 28:15 |
| `ephod_held.svg` | Hoshen (held up, displayed) | Child hands holding breastplate, all 12 gems visible | Exodus 28:4 |

**GDScript access:** `AssetRegistry.item("ephod_held")`

> **Note:** `ephod_worn.svg` (child wearing full ephod garment) is planned for the Finale scene.

---

## Category: `backgrounds/` — Scene Illustrations

| File | Scene | Description | Source |
|------|-------|-------------|--------|
| `ephod_breastplate.svg` | Ephod close-up | 12 gems in gold setting | Exodus 28 |
| `courtyard_pillars.svg` | Grand courtyard with pillars | Gold cedar pillars, veil door | Exodus 27:9 |
| `finale_assembly.svg` | Final assembly | All 12 tribes gathered | Revelation 21 |
| `courtyard_warm.svg` | Warm afternoon courtyard | Amber sunlight, arches, curtains | Reference image 1 |
| `curtain_chamber.svg` | Curtain/veil chamber | Blue/purple/scarlet curtains, cherubim embroidery | Exodus 26:31 |
| `outdoor_ruins.svg` | Outdoor biblical ruins | Sand, stone arches, olive trees | Reference image 4 |

**GDScript access:** `AssetRegistry.bg("courtyard_warm")`

---

## Category: `finale/` — Finale Scene Sprites

| File | Description |
|------|-------------|
| `ephod_weave.svg` | Gold thread weave animation frame (ephod construction) |

---

## Category: `ui/` & `minigames/` — UI & Minigame Assets

*(Populated as UI/minigame-specific sprites are created)*

---

## Series Template Notes

This catalog is the **canonical sprite reference** for all games in the Twelve Stones series.

### Naming conventions

- Characters: `{gender}_{skin}_{hair}.svg` (e.g. `girl_light_curly.svg`)
- Tribe-specific: `{type}_{tribe}.svg` (e.g. `gem_judah.svg`, `elder_reuben.svg`)
- Tools: lowercase descriptive name (e.g. `balance_scales.svg`)
- Backgrounds: scene description (e.g. `courtyard_warm.svg`)

### Art style requirements (all series games)

- Soft pastel cartoon · big expressive eyes · rounded faces
- Diverse skin tones: light / light-olive / olive / tan / medium / dark / deep / copper
- Palette: Desert Sand `#E9D5B3` · Clay Brown `#8B6F47` · Olive Green `#6B7A4F` · Pure Gold `#FFD700` · Antique Gold `#C5A572`
- No dark/ominous tones · calming and welcoming

### Biblical fidelity requirements

- Every nature sprite must have a **real science fact** in SVG comment
- Every tool/item sprite must have a **scripture verse** in SVG comment
- Ephod/hoshen must exactly match Exodus 28:17-21 (4 rows × 3 stones)

### GDScript accessor summary

```gdscript
AssetRegistry.gem("reuben")           # → res://assets/sprites/gems/gem_reuben.svg
AssetRegistry.elder("judah")          # → res://assets/sprites/elders/elder_judah.svg
AssetRegistry.elder_variant("elder_grey_teal")  # → generic elder
AssetRegistry.character("girl_light_curly")      # → character sprite
AssetRegistry.nature_icon("butterfly")           # → NATURE dict
AssetRegistry.nature_ext("eagle_soaring")        # → NATURE_EXT dict (fallback to NATURE)
AssetRegistry.tool("shepherd_staff")             # → TOOLS dict
AssetRegistry.item("ephod_held")                 # → ITEMS dict
AssetRegistry.bg("courtyard_warm")               # → BACKGROUNDS dict
AssetRegistry.avatar(3)                          # → AVATARS array by index
AssetRegistry.random_avatar()                    # → random avatar path
```

---

*Last updated: Session — Full sprite library generation from Grok reference art*  
*Total SVG sprites: 96+ files across 10 categories*
