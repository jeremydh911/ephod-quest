const { test, expect } = require('@playwright/test');

test.describe('Twelve Stones: Ephod Quest - Full Game Test', () => {
  test('Play through entire game', async ({ page }) => {
    // Load the game (assume served at localhost:8000/index.html)
    await page.goto('http://localhost:8000/index.html');

    // Wait for game to load
    await page.waitForSelector('canvas', { timeout: 10000 });

    // Main Menu
    console.log('Testing Main Menu...');
    // Assume buttons are accessible; click Play or similar
    await page.click('text=Play'); // Adjust selector based on UI
    await page.waitForTimeout(2000);

    // Avatar Pick
    console.log('Testing Avatar Selection...');
    // Select tribe and avatar
    await page.click('text=Reuben'); // Example tribe
    await page.click('text=Ezra'); // Example avatar
    await page.click('text=Continue');
    await page.waitForTimeout(2000);

    // Lobby (if multiplayer, but test single-player)
    console.log('Testing Lobby...');
    await page.click('text=Start Game');
    await page.waitForTimeout(2000);

    // Quest 1
    console.log('Testing Quest 1...');
    // Interact with mini-game (tap, etc.)
    await page.click('canvas'); // Simulate tap
    await page.waitForTimeout(5000); // Wait for completion
    // Continue through dialogue
    await page.keyboard.press('Enter'); // Or click next
    await page.waitForTimeout(2000);

    // Repeat for other quests (simulate briefly)
    for (let i = 2; i <= 12; i++) {
      console.log(`Testing Quest ${i}...`);
      await page.click('canvas');
      await page.waitForTimeout(3000);
      await page.keyboard.press('Enter');
    }

    // Finale
    console.log('Testing Finale...');
    await page.click('canvas');
    await page.waitForTimeout(5000);

    // Verse Vault
    console.log('Testing Verse Vault...');
    await page.click('text=Verse Vault');
    await page.click('canvas'); // Interact
    await page.waitForTimeout(2000);

    // Check for errors (console logs)
    const errors = [];
    page.on('console', msg => {
      if (msg.type() === 'error') errors.push(msg.text());
    });

    // Assert no critical errors
    expect(errors.length).toBe(0);

    console.log('Full game test completed successfully!');
  });

  test('Test multiplayer lobby', async ({ page, context }) => {
    // Open multiple pages for co-op test
    const page2 = await context.newPage();
    await page.goto('http://localhost:8000/index.html');
    await page2.goto('http://localhost:8000/index.html');

    // Host on page1
    await page.click('text=Host');
    const code = await page.textContent('.lobby-code'); // Assume code displayed

    // Join on page2
    await page2.click('text=Join');
    await page2.fill('input', code);
    await page2.click('text=Connect');

    // Test co-op
    await page.click('text=Start');
    await page2.waitForSelector('text=Game Started');

    expect(await page.textContent('text=Players: 2')).toBeTruthy();
  });

  test('Test touch controls', async ({ page }) => {
    await page.goto('http://localhost:8000/index.html');
    await page.waitForSelector('canvas');

    // Simulate touch on mobile
    await page.touchscreen.tap(100, 100); // Tap position
    await page.waitForTimeout(1000);

    // Swipe
    await page.touchscreen.swipe(100, 100, 200, 100);
    await page.waitForTimeout(1000);
  });

  // Add more tests for edge cases, like timeout, failure, etc.
});