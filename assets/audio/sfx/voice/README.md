# Voice Mumble Files — Ephod Quest

These short lofi-style audio clips play automatically whenever a dialogue line
appears, giving each character a unique vocal texture without full voice acting.

## Required files

| File | Speaker type | Style |
|---|---|---|
| `elder_murmur_1.wav` | Elder characters | Warm, low, gentle — 0.4–0.8 s |
| `elder_murmur_2.wav` | Elder characters | Warm, slow hum |
| `elder_murmur_3.wav` | Elder characters | Deep, kind tone |
| `child_murmur_1.wav` | "You" / Player | Bright, curious — 0.3–0.5 s |
| `child_murmur_2.wav` | "You" / Player | Light, inquisitive |
| `neutral_murmur_1.wav` | Other NPCs | Friendly mid-tone |
| `neutral_murmur_2.wav` | Other NPCs | Natural conversational |

## How they are selected (`AudioManager.play_voice`)

- Speaker name `"You"` or `"Player"` → **child** murmur, random 1–2
- Speaker name contains `"Elder"` → **elder** murmur, random 1–3
- Any other speaker → **neutral** murmur, random 1–2

Missing files are silently skipped — the game runs normally without them.
Add files incrementally; no code changes required.

## Recommended audio specs

- Format: **WAV** (PCM) or **OGG Vorbis**
- Sample rate: 44 100 Hz
- Bit depth: 16-bit
- Length: 0.3–0.8 seconds
- Volume: ~ –12 dBFS peak (balanced against SFX bus)
- Style tip: short low-pass filtered "mmm" or "ah" sounds give a warm lofi feel.
  A single syllable, slightly pitched, works perfectly.

## Free sources

- [freesound.org](https://freesound.org) — search "mumble" / "hum" CC0 sounds
- Record yourself: hum softly into a phone for each type, trim to 0.5 s
