# Playwright Testing for Twelve Stones: Ephod Quest

## Setup
1. Export game to HTML5: In Godot, Project > Export > Web > Export to `build/web/index.html`.
2. Serve locally: `cd build/web && python -m http.server 8000` (or use any web server).
3. Install Playwright: `npm install @playwright/test`.
4. Install browsers: `npx playwright install`.

## Run Tests
- `npx playwright test` - Run all tests.
- `npx playwright test --headed` - Run with browser visible.
- `npx playwright show-report` - View results.

## Test Coverage
- Full game playthrough (all quests).
- Multiplayer lobby.
- Touch controls simulation.
- Error checking.

Note: Selectors may need adjustment based on actual UI elements. Tests assume basic button texts and canvas interactions.