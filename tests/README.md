# Playwright Tests — Twelve Stones: Ephod Quest

## Why Playwright works differently for Godot games

Godot 4 exports a game as an HTML5 page where all rendering happens inside a
single `<canvas>` element via WebGL.  There are **no DOM text nodes** for game
buttons — Playwright cannot use `page.click('text=Start')`.

Instead every interaction is **coordinate-based**: the helper in
`helpers/godot-canvas.js` translates percentage positions (derived from each
scene's anchor layout) to absolute pixel clicks on the canvas.

Errors from `push_error()` and GDScript parser failures are piped to the
browser `console.error`, so `collectErrors()` captures them automatically.

---

## Prerequisites

### 1 — Export the game to HTML5

Open the project in Godot 4.3+:

```
Project → Export → Web
Export path: build/web/index.html   (preset already configured)
Click "Export Project"
```

Or headlessly from the repo root:

```bash
godot --headless --export-debug "Web" build/web/index.html
```

### 2 — Install Node dependencies

```bash
cd tests
npm install
npx playwright install chromium firefox
```

---

## Running the tests

| Command | What it does |
|---------|-------------|
| `npm test` | Headless, all suites (auto-starts Python dev server) |
| `npm run test:headed` | Browser visible — good for debugging |
| `npm run test:ui` | Interactive Playwright UI |
| `npm run test:main-menu` | `@main-menu` tests only |
| `npm run test:avatar` | `@avatar` tests only |
| `npm run test:quests` | `@quest` — all 12 tribes load-check |
| `npm run test:multiplayer` | `@multiplayer` tests only |
| `npm run test:report` | Open last HTML report |

The Python static server is started automatically.  Manual: `npm run serve`.

---

## Test suites

| Suite | Tag | What is checked |
|-------|-----|-----------------|
| Game Load | `@main-menu` | Canvas visible, no parse errors on init |
| Main Menu Nav | `@main-menu` | Start / VerseVault / Multiplayer buttons |
| Avatar Pick | `@avatar` | All 12 tribe buttons, right panel, confirm |
| All 12 Quests | `@quest` | Each tribe → confirm → quest loads without errors |
| Quest 1 Smoke | `@quest` | Dialogue advance, mini-game taps, keyboard |
| Touch Controls | `@touch` | Tap & swipe, no crash |
| Lobby | `@multiplayer` | Scene load, Host button, two-context test |
| Verse Vault | `@verse-vault` | Scene load, tap interactions |
| Full Smoke | `@smoke` | Main → AvatarPick → Reuben → Quest1 played |

---

## Screenshots

Every test saves a PNG to `tests/test-results/`.  On failure, a video is also saved.

---

## Calibrating coordinates

Button positions come from anchor percentages in the `.tscn` files.
If you move nodes, update the constants in `helpers/godot-canvas.js`.
Run `npm run test:headed` to visually confirm clicks land correctly.

---

## Limitations

- **Canvas-rendered UI** — assertions are: (a) no console errors, (b) screenshots for manual review.
- **Multiplayer P2P** — real ENet connections require a STUN/TURN relay; the lobby test only verifies the scene loads cleanly.
- **Audio** — browser autoplay policy may mute music on first load; the game handles this gracefully.
