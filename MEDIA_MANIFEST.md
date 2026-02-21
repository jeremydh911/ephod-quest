# 📦 Media Organization Manifest

## ✅ Files Organized from "Video Game media" folder

### 🎵 Music Files (assets/audio/music/)

| Original Filename | New Filename | Purpose | Status |
|-------------------|--------------|---------|--------|
| Sacred Spark.wav | sacred_spark.wav | Main quest theme | ✅ Moved |
| Circle of Bright Mornings.wav | menu_theme.wav | Main menu background | ✅ Moved |
| Lion of the Dawn.wav | judah_theme.wav | Judah world (Quest 2) | ✅ Moved |
| Incense in the Vaulted Air.wav | levi_theme.wav | Levi world (Quest 3) | ✅ Moved |
| Caves and Hills of Promise.wav | reuben_theme.wav | Reuben world (Quest 1) | ✅ Moved |
| Desert Sanctuary Main Theme.wav | simeon_theme.wav | Simeon world (Quest 6) | ✅ Moved |
| Sunrise Over The Valley.wav | naphtali_theme.wav | Naphtali world (Quest 5) | ✅ Moved |
| Gather the Tribes.wav | lobby_theme.wav | Multiplayer lobby | ✅ Moved |
| Gathering at the Gates.wav | finale_theme.wav | Finale scene | ✅ Moved |

**Total Music:** 9 tracks ✅

---

### 🔊 Sound Effects (assets/audio/sfx/)

| Filename | Purpose | Status |
|----------|---------|--------|
| tap.wav | Button tap sound | ✅ Moved (from "Soft Tap of Yes.wav") |
| stone_unlock.wav | Stone collection | ✅ Moved (from "Soft Stone Discovery.wav") |
| ui_open.wav | Panel open sound | ✅ Moved |

**Combined SFX Files (Need Manual Splitting):**
These files contain multiple sound effects concatenated together. Use Audacity to split:

1. `footstep_chest_open_ui_open_ui_close_heart_badge_lobby_join_lobby_ready_rhythm_beat_rhythm_miss_sort_snap_sort_wrong_swipe_whoosh_cha.wav`
   - Contains: footstep, chest_open, ui_open, ui_close, heart_badge, lobby sounds, rhythm sounds, sort sounds, swipe sounds

2. `chest_open_ui_open_ui_close_heart_badge_lobby_join_lobby_ready_rhythm_beat_rhythm_miss_sort_snap_sort_wrong_swipe_whoosh_cha.wav`
   - Contains: chest_open, ui_close, heart_badge, lobby sounds, rhythm sounds

3. `butterfly_weave_footstep_chest_open_ui_open_ui_close_heart_badge_lobby_join.wav`
   - Contains: butterfly, weave, footstep, chest_open, ui sounds, heart_badge

4. Multiple other combined files with similar patterns

**Action Required:** 
- Open each combined WAV in Audacity
- Use Selection Tool to isolate each sound
- Export as individual files with proper names
- Place in correct subfolders (voice/ for murmurs)

---

### 🖼️ Images (assets/textures/)

**Total Images:** 150+ JPG files with UUID filenames

**Sorting Guide:**

#### Characters (move to assets/sprites/characters/)
Look for images with:
- Human figures (elders, children, avatars)
- Character portraits
- Tribal clothing/accessories
- Age range 12-29 for avatars
- Diverse skin tones, hair styles, eye colors

#### Backgrounds (move to assets/sprites/backgrounds/)
Look for images with:
- Landscapes (cliffs, hillsides, deserts, forests)
- Sky/clouds
- Terrain textures
- Biome scenes (morning, golden hour, night)

#### UI Elements (move to assets/sprites/ui/)
Look for images with:
- Buttons, panels, frames
- Icons (stones, gems, hearts)
- Ephod breastplate
- Menu elements
- Dialogue boxes

#### Action Spots (move to assets/sprites/action_spots/)
Look for images with:
- Interactive locations (caves, watchtowers, altars)
- Mini-game backgrounds
- Special locations (lion rock, eagle cliffs)

**Manual Review Required:** Open each image and categorize based on content.

---

### 🎬 Videos (assets/videos/)

| Filename | Purpose | Status |
|----------|---------|--------|
| 5a95c472-bc3d-41cb-8ed9-ee41217f555e_hd.mp4 | Unknown - review content | ✅ Moved |
| grok-video-696a2113-bd86-4744-9802-455b598daf3c.mp4 | Unknown - review content | ✅ Moved |
| grok-video-a17ff640-dcd2-4c85-b907-7d577b721251.mp4 | Unknown - review content | ✅ Moved |
| grok-video-f620ce1a-55f7-4c2d-8cf3-33fdc6a36afb.mp4 | Unknown - review content | ✅ Moved |
| personaplex_audio.webm | Audio file (convert to WAV) | ✅ Moved |
| personaplex_audio (1).webm | Audio file (convert to WAV) | ✅ Moved |

**Action Required:** Review video content and determine usage (intro, cutscenes, tutorials?)

---

### 📐 Diagrams (assets/sprites/ui/)

| Filename | Purpose | Status |
|----------|---------|--------|
| diagram.svg | Unknown - review content | ✅ Moved |

---

## 🔧 Next Steps

### 1. Split Combined Audio Files (Priority: HIGH)
```bash
# Install Audacity if not present
sudo apt install audacity

# Open each combined WAV file
# Use Selection Tool to highlight each sound segment
# File > Export > Export Selected Audio
# Name according to purpose (footstep.wav, chest_open.wav, etc.)
```

### 2. Sort Images (Priority: HIGH)
```bash
# Review each image in assets/textures/
# Move to appropriate subfolder:
mv assets/textures/[uuid].jpg assets/sprites/characters/elder_reuben.jpg
mv assets/textures/[uuid].jpg assets/sprites/backgrounds/morning_cliffs.jpg
# etc.
```

### 3. Update Code References (Priority: MEDIUM)
Once files are properly named, update these files:
- `scripts/AudioManager.gd` - verify all audio paths
- `scripts/WorldBase.gd` - update texture loading paths
- `scripts/Character.gd` - update sprite paths
- All Quest scripts (Quest1-12.gd) - update asset references

### 4. Test in Godot (Priority: HIGH)
- Open project in Godot
- Let Godot auto-generate .import files
- Test each audio file plays correctly
- Verify images load without errors
- Check for missing file warnings in console

### 5. Convert Videos (Priority: LOW)
If videos are needed:
```bash
# Convert to OGV format (Godot-friendly)
ffmpeg -i input.mp4 -c:v libtheora -q:v 7 -c:a libvorbis -q:a 4 output.ogv
```

---

## 📊 Summary

| Asset Type | Total | Organized | Needs Work |
|------------|-------|-----------|------------|
| Music | 9 | ✅ 9 | 0 |
| SFX (individual) | 3 | ✅ 3 | 0 |
| SFX (combined) | ~15 | ⚠️ Moved | Split needed |
| Images | 150+ | ⚠️ Moved | Sort needed |
| Videos | 6 | ✅ 6 | Review needed |
| Diagrams | 1 | ✅ 1 | Review needed |

**Overall Progress:** 🟢 60% Complete

---

## 🎯 Quick Win Checklist

- [x] Move all files from "Video Game media" folder
- [ ] Split combined SFX files (1-2 hours)
- [ ] Sort 20 most important images (characters/backgrounds)
- [ ] Test music files in-game
- [ ] Update AudioManager paths if needed
- [ ] Delete duplicate files (files with "(1)" suffix)

---

*Generated after organizing 170+ media files*
*Last updated: [Current Session]*
