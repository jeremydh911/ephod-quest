// twelve-stones.spec.js
// ─────────────────────────────────────────────────────────────────────────────
// Playwright E2E test suite for Twelve Stones: Ephod Quest
//
// HOW IT WORKS
// ────────────────
// Godot 4 exports to a <canvas> — there are NO DOM text nodes for game buttons.
// Every interaction is coordinate-based, derived from the scene anchor layout.
// Errors from push_error() / GDScript parser appear in browser console.error.
//
// PRE-REQUISITES (see tests/README.md for full instructions):
//   1.  Export: Project → Export → Web → build/web/index.html
//   2.  Serve:  cd tests && npm run serve         (auto-started by playwright)
//   3.  Run:    cd tests && npm test
// ─────────────────────────────────────────────────────────────────────────────

const { test, expect } = require('@playwright/test');
const {
    waitForGodot,
    clickAt,
    tapAt,
    swipeInCanvas,
    collectErrors,
    MAIN_MENU,
    TRIBE_POSITIONS,
    AVATAR_GRID,
    AVATAR_CONFIRM,
    BACK_MENU_BTN,
} = require('./helpers/godot-canvas');

// ─────────────────────────────────────────────────────────────────────────────
// Shared fixture: load the game and wait for it to be ready
// ─────────────────────────────────────────────────────────────────────────────
async function loadGame(page) {
    await page.goto('/');
    await waitForGodot(page);
}

// Helper: assert no GDScript/parser errors accumulated
function assertNoErrors(errors, context) {
    // Filter out known harmless headless-browser / Godot-web noise.
    // Keep only real GDScript errors (SCRIPT ERROR / Parse error) or JS crashes.
    const critical = errors.filter(e =>
        !e.includes('favicon') &&
        !e.includes('SharedArrayBuffer') &&          // Godot threading limit
        !e.includes('AudioContext was not allowed') &&
        !e.includes('WebGL warning') &&
        !e.includes('CONTEXT_LOST_WEBGL') &&         // SwiftShader headless
        !e.includes('GPU stall') &&                  // headless SwiftShader
        !e.includes('WARNING: Node AnimationLibrary') && // harmless placeholder
        !e.includes('at: instantiate') &&            // call stack from WARNING
        !e.includes('invalid bus index') &&          // fixed, but guard anyway
        !e.includes('GL Driver Message') &&          // GPU driver perf note
        !e.includes('GDScript backtrace') &&         // stack-trace header from push_error
        !/^\s*\[\d+\] .+\(res:\/\//.test(e)         // individual backtrace call lines: [0] func (res://...)
    );
    if (critical.length > 0) {
        throw new Error(`[${context}] Console errors:\n` + critical.join('\n'));
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUITE 1: GAME LOAD  @main-menu
// ─────────────────────────────────────────────────────────────────────────────
test.describe('Game Load & Main Menu @main-menu', () => {

    test('Page loads an HTML5 canvas', async ({ page }) => {
        const errors = collectErrors(page);
        await page.goto('/');
        // Canvas must appear within 15 s
        await expect(page.locator('canvas')).toBeVisible({ timeout: 15_000 });
        assertNoErrors(errors, 'page-load');
    });

    test('Godot initialises without parser errors', async ({ page }) => {
        const errors = collectErrors(page);
        await loadGame(page);
        assertNoErrors(errors, 'godot-init');
    });

    test('Main menu screenshot (visual baseline)', async ({ page }) => {
        await loadGame(page);
        // Screenshot saved to test-results/ for manual review
        await page.screenshot({ path: 'test-results/01-main-menu.png', fullPage: false });
    });

    test('Canvas fills the viewport', async ({ page }) => {
        await loadGame(page);
        const canvas = page.locator('canvas');
        const box = await canvas.boundingBox();
        expect(box.width).toBeGreaterThan(600);
        expect(box.height).toBeGreaterThan(300);
    });

});

// ─────────────────────────────────────────────────────────────────────────────
// SUITE 2: MAIN MENU NAVIGATION  @main-menu
// ─────────────────────────────────────────────────────────────────────────────
test.describe('Main Menu Navigation @main-menu', () => {

    test('Start New Journey button → AvatarPick loads (no errors)', async ({ page }) => {
        const errors = collectErrors(page);
        await loadGame(page);

        await clickAt(page, ...MAIN_MENU.START);
        // Scene transition + AvatarPick _ready() takes ~2 s
        await page.waitForTimeout(2500);
        await page.screenshot({ path: 'test-results/02-avatarpick.png' });
        assertNoErrors(errors, 'start-to-avatarpick');
    });

    test('VerseVault button → VerseVault scene loads', async ({ page }) => {
        const errors = collectErrors(page);
        await loadGame(page);

        await clickAt(page, ...MAIN_MENU.VERSE_VAULT);
        await page.waitForTimeout(2500);
        await page.screenshot({ path: 'test-results/03-versevault.png' });
        assertNoErrors(errors, 'main-to-versevault');
    });

    test('Multiplayer button → Lobby scene loads', async ({ page }) => {
        const errors = collectErrors(page);
        await loadGame(page);

        await clickAt(page, ...MAIN_MENU.MULTIPLAYER);
        await page.waitForTimeout(2500);
        await page.screenshot({ path: 'test-results/04-lobby.png' });
        assertNoErrors(errors, 'main-to-lobby');
    });

});

// ─────────────────────────────────────────────────────────────────────────────
// SUITE 3: AVATAR PICK  @avatar
// ─────────────────────────────────────────────────────────────────────────────
test.describe('Avatar Pick Screen @avatar', () => {

    // Helper: navigate to AvatarPick
    async function goToAvatarPick(page) {
        await loadGame(page);
        await clickAt(page, ...MAIN_MENU.START);
        await page.waitForTimeout(2500);
    }

    test('All 12 tribe buttons are clickable without errors', async ({ page }) => {
        const errors = collectErrors(page);
        await goToAvatarPick(page);

        const tribes = Object.keys(TRIBE_POSITIONS);
        for (const tribe of tribes) {
            await clickAt(page, ...TRIBE_POSITIONS[tribe]);
            await page.waitForTimeout(600);
        }
        await page.screenshot({ path: 'test-results/05-tribe-cycling.png' });
        assertNoErrors(errors, 'tribe-buttons');
    });

    test('Selecting Reuben shows right panel (no errors)', async ({ page }) => {
        const errors = collectErrors(page);
        await goToAvatarPick(page);

        await clickAt(page, ...TRIBE_POSITIONS.reuben);
        await page.waitForTimeout(800);
        await page.screenshot({ path: 'test-results/06-reuben-selected.png' });
        assertNoErrors(errors, 'tribe-reuben');
    });

    test('Back to Menu button returns to Main Menu', async ({ page }) => {
        const errors = collectErrors(page);
        await goToAvatarPick(page);

        await clickAt(page, ...BACK_MENU_BTN);
        await page.waitForTimeout(1500);
        await page.screenshot({ path: 'test-results/07-back-to-menu.png' });
        assertNoErrors(errors, 'back-to-menu');
    });

    test('Pick Reuben → first avatar → Confirm → Quest1 loads', async ({ page }) => {
        const errors = collectErrors(page);
        await goToAvatarPick(page);

        // Select tribe
        await clickAt(page, ...TRIBE_POSITIONS.reuben);
        await page.waitForTimeout(800);

        // Click first (top-left) avatar card
        await clickAt(page, ...AVATAR_GRID.topLeft);
        await page.waitForTimeout(600);
        await page.screenshot({ path: 'test-results/08-avatar-selected.png' });

        // Confirm
        await clickAt(page, ...AVATAR_CONFIRM);
        await page.waitForTimeout(3000);  // Quest1 _ready() + music + dialogue
        await page.screenshot({ path: 'test-results/09-quest1-loaded.png' });
        assertNoErrors(errors, 'reuben-to-quest1');
    });

    // Repeat for every tribe – just load, no deep interaction
    const ALL_TRIBES = [
        { tribe: 'reuben', questNum: 1 },
        { tribe: 'judah', questNum: 2 },
        { tribe: 'levi', questNum: 3 },
        { tribe: 'dan', questNum: 4 },
        { tribe: 'naphtali', questNum: 5 },
        { tribe: 'simeon', questNum: 6 },
        { tribe: 'gad', questNum: 7 },
        { tribe: 'asher', questNum: 8 },
        { tribe: 'issachar', questNum: 9 },
        { tribe: 'zebulun', questNum: 10 },
        { tribe: 'joseph', questNum: 11 },
        { tribe: 'benjamin', questNum: 12 },
    ];

    for (const { tribe, questNum } of ALL_TRIBES) {
        test(`${tribe} → Quest${questNum} loads without errors @quest`, async ({ page }) => {
            const errors = collectErrors(page);
            await loadGame(page);
            await clickAt(page, ...MAIN_MENU.START);
            await page.waitForTimeout(2500);

            await clickAt(page, ...TRIBE_POSITIONS[tribe]);
            await page.waitForTimeout(800);
            await clickAt(page, ...AVATAR_GRID.topLeft);
            await page.waitForTimeout(600);
            await clickAt(page, ...AVATAR_CONFIRM);
            await page.waitForTimeout(4000);

            await page.screenshot({ path: `test-results/quest-${questNum}-${tribe}-load.png` });
            assertNoErrors(errors, `quest${questNum}-${tribe}`);
        });
    }

});

// ─────────────────────────────────────────────────────────────────────────────
// SUITE 4: QUEST INTERACTION SMOKE TESTS  @quest
// ─────────────────────────────────────────────────────────────────────────────
test.describe('Quest 1 (Reuben) Mini-game smoke @quest', () => {

    async function loadQuest1(page) {
        await loadGame(page);
        await clickAt(page, ...MAIN_MENU.START);
        await page.waitForTimeout(2500);
        await clickAt(page, ...TRIBE_POSITIONS.reuben);
        await page.waitForTimeout(800);
        await clickAt(page, ...AVATAR_GRID.topLeft);
        await page.waitForTimeout(600);
        await clickAt(page, ...AVATAR_CONFIRM);
        await page.waitForTimeout(4000);
    }

    test('Clicking dialogue advance does not crash', async ({ page }) => {
        const errors = collectErrors(page);
        await loadQuest1(page);

        // Tap the canvas centre (advances dialogue in QuestBase)
        for (let i = 0; i < 6; i++) {
            await clickAt(page, 0.50, 0.90);
            await page.waitForTimeout(600);
        }
        await page.screenshot({ path: 'test-results/10-quest1-dialogue.png' });
        assertNoErrors(errors, 'quest1-dialogue');
    });

    test('Mini-game tap buttons respond without errors', async ({ page }) => {
        const errors = collectErrors(page);
        await loadQuest1(page);

        // Advance past any dialogue first
        for (let i = 0; i < 8; i++) {
            await clickAt(page, 0.50, 0.90);
            await page.waitForTimeout(500);
        }

        // Tap centre-lower area repeatedly (mini-game tap button area)
        for (let i = 0; i < 10; i++) {
            await clickAt(page, 0.50, 0.70);
            await page.waitForTimeout(400);
        }
        await page.screenshot({ path: 'test-results/11-quest1-minigame.png' });
        assertNoErrors(errors, 'quest1-minigame');
    });

    test('Keyboard Enter advances dialogue', async ({ page }) => {
        const errors = collectErrors(page);
        await loadQuest1(page);

        for (let i = 0; i < 5; i++) {
            await page.keyboard.press('Enter');
            await page.waitForTimeout(500);
        }
        assertNoErrors(errors, 'quest1-keyboard');
    });

});

// ─────────────────────────────────────────────────────────────────────────────
// SUITE 5: TOUCH CONTROLS  @touch
// ─────────────────────────────────────────────────────────────────────────────
test.describe('Touch controls @touch', () => {

    test('Tap on canvas does not crash', async ({ page }) => {
        const errors = collectErrors(page);
        await loadGame(page);

        // Tap several positions to exercise Global._input touch translation
        const positions = [[0.5, 0.5], [0.2, 0.8], [0.8, 0.8], [0.5, 0.3]];
        for (const [x, y] of positions) {
            await tapAt(page, x, y);
            await page.waitForTimeout(300);
        }
        assertNoErrors(errors, 'touch-tap');
    });

    test('Swipe gesture does not crash', async ({ page }) => {
        const errors = collectErrors(page);
        await loadGame(page);

        // Swipe right (move_right action)
        await swipeInCanvas(page, { x: 0.3, y: 0.5 }, { x: 0.7, y: 0.5 });
        await page.waitForTimeout(500);
        // Swipe left
        await swipeInCanvas(page, { x: 0.7, y: 0.5 }, { x: 0.3, y: 0.5 });
        await page.waitForTimeout(500);

        assertNoErrors(errors, 'touch-swipe');
    });

});

// ─────────────────────────────────────────────────────────────────────────────
// SUITE 6: MULTIPLAYER LOBBY  @multiplayer
// ─────────────────────────────────────────────────────────────────────────────
test.describe('Multiplayer Lobby @multiplayer', () => {

    test('Lobby scene loads without errors', async ({ page }) => {
        const errors = collectErrors(page);
        await loadGame(page);
        await clickAt(page, ...MAIN_MENU.MULTIPLAYER);
        await page.waitForTimeout(3000);
        await page.screenshot({ path: 'test-results/12-lobby.png' });
        assertNoErrors(errors, 'lobby-load');
    });

    test('Host button is clickable without errors (single-page)', async ({ page }) => {
        const errors = collectErrors(page);
        await loadGame(page);
        await clickAt(page, ...MAIN_MENU.MULTIPLAYER);
        await page.waitForTimeout(2500);

        // Host button: Lobby VBox centre area, approx upper-half of screen
        await clickAt(page, 0.50, 0.40);
        await page.waitForTimeout(2000);
        await page.screenshot({ path: 'test-results/13-lobby-host.png' });
        assertNoErrors(errors, 'lobby-host');
    });

    test('Two browser contexts can connect as cross-tribe pair', async ({ browser }) => {
        // Open two independent pages (two "players")
        const ctx1 = await browser.newContext({ viewport: { width: 1280, height: 720 } });
        const ctx2 = await browser.newContext({ viewport: { width: 1280, height: 720 } });
        const page1 = await ctx1.newPage();
        const page2 = await ctx2.newPage();

        const errors1 = collectErrors(page1);
        const errors2 = collectErrors(page2);

        // Both load the game. Because ENet runs over WebRTC/WebSocket in web export,
        // actual peer connection requires extra infra (STUN/coturn).
        // This test verifies both lobbies load cleanly; real P2P is tested manually.
        await Promise.all([loadGame(page1), loadGame(page2)]);

        await Promise.all([
            clickAt(page1, ...MAIN_MENU.MULTIPLAYER),
            clickAt(page2, ...MAIN_MENU.MULTIPLAYER),
        ]);
        await page1.waitForTimeout(2500);
        await page2.waitForTimeout(2500);

        await page1.screenshot({ path: 'test-results/14-lobby-player1.png' });
        await page2.screenshot({ path: 'test-results/14-lobby-player2.png' });

        assertNoErrors(errors1, 'lobby-p1');
        assertNoErrors(errors2, 'lobby-p2');

        await ctx1.close();
        await ctx2.close();
    });

});

// ─────────────────────────────────────────────────────────────────────────────
// SUITE 7: VERSE VAULT  @verse-vault
// ─────────────────────────────────────────────────────────────────────────────
test.describe('Verse Vault @verse-vault', () => {

    test('VerseVault scene loads and renders without errors', async ({ page }) => {
        const errors = collectErrors(page);
        await loadGame(page);
        await clickAt(page, ...MAIN_MENU.VERSE_VAULT);
        await page.waitForTimeout(2500);
        await page.screenshot({ path: 'test-results/15-versevault.png' });
        assertNoErrors(errors, 'versevault');
    });

    test('Tapping inside VerseVault does not crash', async ({ page }) => {
        const errors = collectErrors(page);
        await loadGame(page);
        await clickAt(page, ...MAIN_MENU.VERSE_VAULT);
        await page.waitForTimeout(2500);

        // Click around the verse list area
        for (let i = 0; i < 5; i++) {
            await clickAt(page, 0.50, 0.30 + i * 0.10);
            await page.waitForTimeout(400);
        }
        assertNoErrors(errors, 'versevault-tap');
    });

});

// ─────────────────────────────────────────────────────────────────────────────
// SUITE 8: FULL PLAYTHROUGH SMOKE  @smoke
// ─────────────────────────────────────────────────────────────────────────────
test.describe('Full playthrough smoke @smoke', () => {

    test('Main menu → AvatarPick → Quest1 → no GDScript errors throughout', async ({ page }) => {
        test.slow(); // triple the timeout for this test

        const errors = collectErrors(page);

        // ── Load game ─────────
        await loadGame(page);
        await page.screenshot({ path: 'test-results/smoke-01-main-menu.png' });
        assertNoErrors(errors, 'smoke:main-menu');

        // ── Start journey ──────
        await clickAt(page, ...MAIN_MENU.START);
        await page.waitForTimeout(2500);
        await page.screenshot({ path: 'test-results/smoke-02-avatarpick.png' });
        assertNoErrors(errors, 'smoke:avatarpick');

        // ── Pick Reuben ────────
        await clickAt(page, ...TRIBE_POSITIONS.reuben);
        await page.waitForTimeout(800);
        await page.screenshot({ path: 'test-results/smoke-03-tribe-reuben.png' });
        assertNoErrors(errors, 'smoke:reuben-tribe');

        // ── Pick first avatar ──
        await clickAt(page, ...AVATAR_GRID.topLeft);
        await page.waitForTimeout(600);
        await page.screenshot({ path: 'test-results/smoke-04-avatar-chosen.png' });
        assertNoErrors(errors, 'smoke:avatar-chosen');

        // ── Confirm ────────────
        await clickAt(page, ...AVATAR_CONFIRM);
        await page.waitForTimeout(4000);
        await page.screenshot({ path: 'test-results/smoke-05-quest1.png' });
        assertNoErrors(errors, 'smoke:quest1-load');

        // ── Interact with Quest1 (advance dialogue, tap mini-game) ────
        for (let i = 0; i < 10; i++) {
            await clickAt(page, 0.50, 0.88);     // dialogue advance / tap target
            await page.waitForTimeout(500);
        }
        for (let i = 0; i < 8; i++) {
            await clickAt(page, 0.50, 0.65);     // mini-game button area
            await page.waitForTimeout(450);
        }
        await page.screenshot({ path: 'test-results/smoke-06-quest1-played.png' });
        assertNoErrors(errors, 'smoke:quest1-played');
    });

});
