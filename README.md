# Twelve Stones — Ephod Quest

> *"For the LORD gives wisdom; from his mouth come knowledge and understanding."*
> — Proverbs 2:6

A 2D co-operative biblical adventure game built with **Godot Engine 4.3**.
Players choose from **12 tribes × 4 avatars** (48 unique characters) and journey
through tribal quests, collect gemstones, memorise scripture, and discover
creation science — ending with every tribe weaving together the high-priest's
breastplate in a shared finale.

---

## Vision

**No violence. No stats. No loot.**
Only heart, unity, and discovery.

Each of the 12 tribes has a unique landscape, elder, mini-games, collectible
gemstone, quest verse, and a nature-science fact — experienced in 10-20 hours
of meaningful play.

---

## Current Project Status

- **✅ COMPLETED**: All 12 quests fully implemented with unique mini-games
- **✅ Infrastructure**: All autoloads, multiplayer, touch controls, audio placeholders, export presets
- **✅ Playable**: Full game runs without errors; complete 10-20 hour experience
- **✅ Mobile-Ready**: Android export configured, touch-first design
- **Ready for**: Playtesting, deployment, and platform expansion

---

## Getting Started

### Prerequisites

- [Godot Engine 4.3](https://godotengine.org/download) (Standard version)

### Installation

```bash
git clone <https://github.com/jeremydh911/ephod-quest.git>
cd ephod-quest
```

Open Godot → **Import** → select `project.godot` → **Import & Edit**.

### Running

Press **F5** or click the ▶ Play button.
The game starts with a creative animated logo intro featuring the twelve tribal stones, then transitions to the main menu with an illustrated ephod breastplate.
Touch-screen joystick activates automatically on Android/iOS.

---

## Project Structure

```bash
ephod-quest/
├── scenes/             # .tscn scene files
│   ├── MainMenu.tscn
│   ├── Lobby.tscn      # Multiplayer lobby
│   ├── AvatarPick.tscn # Tribe + avatar selection
│   ├── Quest1.tscn     # Reuben — cave + ladder
│   ├── Quest2.tscn     # Judah  — hillside + praise roar
│   ├── Quest3.tscn     # Levi   — sacred hall + lamps
│   ├── Quest4.tscn     # Dan    — hilltop + eagle soar
│   ├── Quest5-12.tscn  # Stubs for remaining tribes
│   ├── VerseVaultScene.tscn
│   └── Finale.tscn     # Courtyard ephod-weave ending
├── scripts/            # GDScript files
│   ├── Global.gd       # Game state + all tribal data (48 avatars)
│   ├── MultiplayerLobby.gd
│   ├── AudioManager.gd
│   ├── VerseVault.gd   # Collectible verse library
│   ├── QuestBase.gd    # Shared quest framework
│   ├── TouchControls.gd
│   └── Quest1-4.gd, Finale.gd, QuestStub.gd …
├── assets/             # Audio placeholders + future art
├── DOCS/               # Game design documents
└── export_presets.cfg  # Android, iOS, PC, Web
```

---

## Tribes & Quest Roadmap

|#|Tribe|Gem|Quest Verse|Status|
|----|-------------|------------|--------------------------|----------|
|1|Reuben|Sardius|Proverbs 3:5-6|✅ Done|
| 2  | Judah       | Emerald    | Psalm 100:1-2           | ✅ Done  |
| 3  | Levi        | Carbuncle  | Matthew 5:16            | ✅ Done  |
| 4  | Dan         | Sapphire   | Proverbs 2:6            | ✅ Done  |
| 5  | Naphtali    | Diamond    | Psalm 19:14             | 🔲 Stub  |
| 6  | Simeon      | Ligure     | Psalm 46:10             | 🔲 Stub  |
| 7  | Gad         | Ligure     | Hebrews 12:1            | 🔲 Stub  |
| 8  | Asher       | Agate      | Luke 9:16               | 🔲 Stub  |
| 9  | Issachar    | Amethyst   | 1 Chronicles 12:32      | 🔲 Stub  |
| 10 | Zebulun     | Beryl      | Romans 15:7             | 🔲 Stub  |
| 11 | Joseph      | Onyx       | Genesis 50:20           | 🔲 Stub  |
| 12 | Benjamin    | Jasper     | Deuteronomy 33:12       | 🔲 Stub  |

---

## Multiplayer

- Open `Lobby.tscn` → **Host** or **Join** (enter code)
- Up to **12 players** simultaneously (one per tribe)
- Co-op actions activate automatically when matching tribes are online:
  - *Judah Roars → Reuben Climbs*
  - *Levi Prays → Gad Strengthens*
  - *Asher Shares Food → All tribes heal*
  - and more…

---

## Controls

|Action|Keyboard|Touch|
|-------------|---------------|-------------------|
|Move|WASD / ←↑↓→|Virtual joystick|
|Interact|E|Tap highlighted node|
|Accept UI|Enter|Tap button|

---

## Scripture Credits

All scripture quotations are from the **New International Version (NIV)**
unless noted.  
*THE HOLY BIBLE, NEW INTERNATIONAL VERSION®, NIV® Copyright © 1973, 1978, 1984, 2011 by Biblica, Inc.® Used by permission. All rights reserved worldwide.*

---

## License

MIT — see [LICENSE](LICENSE) for details.  
Biblical content is used under fair-use educational provisions.

---

## Privacy Policy

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for details on data collection and usage.

---

## Donations

If you enjoy "Twelve Stones: Ephod Quest" and want to support its development, consider a voluntary donation. Your support helps maintain and expand this educational game!

- **Ko-fi**: [ko-fi.com/ephodquest](https://ko-fi.com/ephodquest) (One-time or monthly donations)
- **PayPal**: [paypal.me/ephodquest](https://paypal.me/ephodquest) (Secure payments)

All donations are optional and go directly to covering development costs. Thank you for your generosity!

---

## Deployment

Ready for app store deployment! See [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) for full requirements and steps for Google Play and App Store.

---

## Credits

**Game Designer:** Shawna Harlin  
**Coder/Developer:** Jeremiah D Harlin  

Special thanks to the Godot community and biblical scholars for inspiration.

