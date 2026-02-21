// helpers/godot-canvas.js  (headless-compatible version)
// ─────────────────────────────────────────────────────────────────────────────
// Utilities for interacting with a Godot 4 web-export game via Playwright.
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Wait for the Godot canvas to finish loading.
 * Headless-safe: if the #status overlay never disappears (WebGL fallback),
 * we still proceed after the load timeout + grace period.
 */
async function waitForGodot(page, { gracePeriodMs = 3000, loadTimeout = 60_000 } = {}) {
    // 1. Canvas must be in the DOM
    await page.waitForSelector('canvas', { timeout: loadTimeout });

    // 2. Wait for status overlay to vanish OR time out (proceed either way)
    try {
        await page.waitForFunction(() => {
            const status = document.getElementById('status');
            if (!status) return true; // custom shell or no status – skip
            const style = window.getComputedStyle(status);
            return style.display === 'none' ||
                   style.visibility === 'hidden' ||
                   style.opacity === '0';
        }, { timeout: Math.min(loadTimeout, 30_000) }); // cap at 30s
    } catch {
        // Timed out waiting for status – headless WebGL may be initialising
        // slowly; canvas is present so proceed with grace period.
        console.warn('[waitForGodot] status overlay timeout – continuing anyway');
    }

    // 3. Grace period so the first scene can execute _ready()
    await page.waitForTimeout(gracePeriodMs);
}

// ─────────────────────────────────────────────────────────────────────────────
// Canvas bounding rect (cached per page lifetime)
// ─────────────────────────────────────────────────────────────────────────────
async function canvasRect(page) {
    return await page.evaluate(() => {
        const c = document.querySelector('canvas');
        if (!c) throw new Error('No <canvas> element found – did the game load?');
        const r = c.getBoundingClientRect();
        return { x: r.left, y: r.top, width: r.width, height: r.height };
    });
}

// ─────────────────────────────────────────────────────────────────────────────
// Coordinate helpers
// ─────────────────────────────────────────────────────────────────────────────
async function clickAt(page, xPct, yPct) {
    const r = await canvasRect(page);
    const x = r.x + r.width * xPct;
    const y = r.y + r.height * yPct;
    await page.mouse.click(x, y);
}

async function tapAt(page, xPct, yPct) {
    const r = await canvasRect(page);
    const x = r.x + r.width * xPct;
    const y = r.y + r.height * yPct;
    await page.touchscreen.tap(x, y);
}

async function swipeInCanvas(page, from, to, { steps = 10, delayMs = 200 } = {}) {
    const r = await canvasRect(page);
    const sx = r.x + r.width * from.x;
    const sy = r.y + r.height * from.y;
    const ex = r.x + r.width * to.x;
    const ey = r.y + r.height * to.y;

    await page.touchscreen.tap(sx, sy);
    await page.waitForTimeout(50);
    const mouse = page.mouse;
    await mouse.move(sx, sy);
    await mouse.down();
    for (let i = 1; i <= steps; i++) {
        await mouse.move(
            sx + (ex - sx) * (i / steps),
            sy + (ey - sy) * (i / steps),
        );
        await page.waitForTimeout(delayMs / steps);
    }
    await mouse.up();
}

// ─────────────────────────────────────────────────────────────────────────────
// Error collector
// ─────────────────────────────────────────────────────────────────────────────
function collectErrors(page) {
    const errors = [];
    page.on('console', (msg) => {
        if (msg.type() === 'error') errors.push(msg.text());
    });
    page.on('pageerror', (err) => {
        errors.push(`[pageerror] ${err.message}`);
    });
    return errors;
}

// ─────────────────────────────────────────────────────────────────────────────
// assertNoErrors  – filters out known harmless noise
// ─────────────────────────────────────────────────────────────────────────────
function assertNoErrors(errors, context) {
    const critical = errors.filter(e =>
        // harmless browser/Godot-web noise
        !e.includes('favicon') &&
        !e.includes('SharedArrayBuffer') &&          // Godot threading warning
        !e.includes('AudioContext was not allowed')  // autoplay policy
    );
    if (critical.length > 0) {
        throw new Error(`[${context}] Console errors:\n` + critical.join('\n'));
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout positions  (calibrated to 1280×720 canvas)
// ─────────────────────────────────────────────────────────────────────────────
const MAIN_MENU = {
    START:       [0.50, 0.618],
    VERSE_VAULT: [0.50, 0.702],
    MULTIPLAYER: [0.50, 0.788],
    SUPPORT:     [0.50, 0.874],
    QUIT:        [0.50, 0.960],
    CONTINUE:    [0.50, 0.618],
    START_WITH_SAVE: [0.50, 0.702],
};

const TRIBE_COL_X = [0.105, 0.240, 0.375];
const TRIBE_ROW_Y = [0.235, 0.321, 0.407, 0.493];

const TRIBE_POSITIONS = {
    reuben:   [TRIBE_COL_X[0], TRIBE_ROW_Y[0]],
    simeon:   [TRIBE_COL_X[1], TRIBE_ROW_Y[0]],
    levi:     [TRIBE_COL_X[2], TRIBE_ROW_Y[0]],
    judah:    [TRIBE_COL_X[0], TRIBE_ROW_Y[1]],
    dan:      [TRIBE_COL_X[1], TRIBE_ROW_Y[1]],
    naphtali: [TRIBE_COL_X[2], TRIBE_ROW_Y[1]],
    gad:      [TRIBE_COL_X[0], TRIBE_ROW_Y[2]],
    asher:    [TRIBE_COL_X[1], TRIBE_ROW_Y[2]],
    issachar: [TRIBE_COL_X[2], TRIBE_ROW_Y[2]],
    zebulun:  [TRIBE_COL_X[0], TRIBE_ROW_Y[3]],
    joseph:   [TRIBE_COL_X[1], TRIBE_ROW_Y[3]],
    benjamin: [TRIBE_COL_X[2], TRIBE_ROW_Y[3]],
};

const AVATAR_GRID = {
    topLeft:     [0.615, 0.35],
    topRight:    [0.820, 0.35],
    bottomLeft:  [0.615, 0.52],
    bottomRight: [0.820, 0.52],
};

const AVATAR_CONFIRM  = [0.88, 0.93];
const BACK_MENU_BTN   = [0.07, 0.06];

// ─────────────────────────────────────────────────────────────────────────────
// Exports
// ─────────────────────────────────────────────────────────────────────────────
module.exports = {
    waitForGodot,
    canvasRect,
    clickAt,
    tapAt,
    swipeInCanvas,
    collectErrors,
    assertNoErrors,
    MAIN_MENU,
    TRIBE_POSITIONS,
    AVATAR_GRID,
    AVATAR_CONFIRM,
    BACK_MENU_BTN,
};
