// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  TWELVE STONES — Visual Design Screenshot System                        ║
// ║  Playwright-based art pipeline: snapshots every world design mockup     ║
// ║  "He made everything beautiful in its time." — Ecclesiastes 3:11        ║
// ╚══════════════════════════════════════════════════════════════════════════╝
//
// Usage:  cd tests && node playwright-designer.js
//         Outputs screenshots to: tests/design-screenshots/
//
// These screenshots serve as the visual bible for all Godot scene art.

const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const MOCKUP_DIR = path.join(__dirname, 'visual-mockups');
const OUT_DIR    = path.join(__dirname, 'design-screenshots');

const SCREENS = [
  { file: 'MainMenu.html',         name: 'MainMenu',             w: 1280, h: 720 },
  { file: 'AvatarPick.html',       name: 'AvatarPick',           w: 1280, h: 720 },
  { file: 'World1_Reuben.html',    name: 'World1_MorningCliffs', w: 1280, h: 720 },
  { file: 'World2_Judah.html',     name: 'World2_GoldenHillside',w: 1280, h: 720 },
  { file: 'World3_Levi.html',      name: 'World3_SacredHall',    w: 1280, h: 720 },
  { file: 'World4_Dan.html',       name: 'World4_EaglePlateau',  w: 1280, h: 720 },
  { file: 'World5_Naphtali.html',  name: 'World5_NightForest',   w: 1280, h: 720 },
  { file: 'World6_Simeon.html',    name: 'World6_DesertBorder',  w: 1280, h: 720 },
  { file: 'World7_Gad.html',       name: 'World7_MountainFort',  w: 1280, h: 720 },
  { file: 'World8_Asher.html',     name: 'World8_FertileValley', w: 1280, h: 720 },
  { file: 'World9_Issachar.html',  name: 'World9_StarObservatory',w: 1280, h: 720 },
  { file: 'World10_Zebulun.html',  name: 'World10_CoastalHarbour',w: 1280, h: 720 },
  { file: 'World11_Joseph.html',   name: 'World11_Vineyard',     w: 1280, h: 720 },
  { file: 'World12_Benjamin.html', name: 'World12_MoonlitForest',w: 1280, h: 720 },
  { file: 'VerseVault.html',       name: 'VerseVault',           w: 1280, h: 720 },
  { file: 'Finale.html',           name: 'Finale',               w: 1280, h: 720 },
];

async function captureAllScreens() {
  if (!fs.existsSync(OUT_DIR)) fs.mkdirSync(OUT_DIR, { recursive: true });

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    ignoreHTTPSErrors: true,
    colorScheme: 'dark',
  });

  let passed = 0;
  let skipped = 0;

  for (const screen of SCREENS) {
    const filePath = path.join(MOCKUP_DIR, screen.file);

    if (!fs.existsSync(filePath)) {
      console.log(`  ⚠  Skipping  ${screen.name}  (mockup not yet created)`);
      skipped++;
      continue;
    }

    const page = await context.newPage();
    await page.setViewportSize({ width: screen.w, height: screen.h });

    // Load local HTML file
    await page.goto(`file://${filePath}`, { waitUntil: 'domcontentloaded' });

    // Wait for CSS animations to settle
    await page.waitForTimeout(600);

    // Capture
    const outPath = path.join(OUT_DIR, `${screen.name}.png`);
    await page.screenshot({ path: outPath, fullPage: false });
    await page.close();

    console.log(`  ✅  ${screen.name.padEnd(28)} → ${path.relative(process.cwd(), outPath)}`);
    passed++;
  }

  await browser.close();

  console.log('\n─────────────────────────────────────────────────');
  console.log(`  Captured: ${passed}   Skipped: ${skipped}   Total: ${SCREENS.length}`);
  console.log(`  Screenshots saved to: ${OUT_DIR}`);
  console.log('─────────────────────────────────────────────────\n');
}

captureAllScreens().catch(err => {
  console.error('Playwright Designer Error:', err);
  process.exit(1);
});
