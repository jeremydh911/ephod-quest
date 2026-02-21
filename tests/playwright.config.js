// @ts-check
// playwright.config.js – Twelve Stones: Ephod Quest (headless-compatible)
// WebGL software rendering enabled via SwiftShader so Godot 4 wasm can init.

const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
    testDir: '.',
    testMatch: '**/*.spec.js',

    // Give Godot time to compile shaders (wasm can take 30-60s headlessly)
    timeout: 120_000,
    expect: { timeout: 20_000 },

    // Retry once on failure to account for flaky timing
    retries: 1,

    use: {
        baseURL: 'http://localhost:8000',
        screenshot: 'only-on-failure',
        video: 'retain-on-failure',
        trace: 'on-first-retry',
        ignoreHTTPSErrors: true,
        bypassCSP: true,
        ...devices['Galaxy S9+'],
    },

    outputDir: 'test-results/',
    reporter: [['list'], ['html', { outputFolder: 'playwright-report', open: 'never' }]],

    webServer: {
        command: "python3 -m http.server 8000 --directory '/media/jeremiah/8t Backup/projects/ephod-quest/build/web'",
        url: 'http://localhost:8000',
        reuseExistingServer: true,
        timeout: 30_000,
    },

    projects: [
        {
            name: 'chromium',
            use: {
                ...devices['Desktop Chrome'],
                hasTouch: true,         // required for touchscreen.tap() in touch tests
                launchOptions: {
                    args: [
                        '--use-gl=angle',
                        '--use-angle=swiftshader-webgl',
                        '--enable-experimental-web-platform-features',
                        '--enable-features=SharedArrayBuffer,WebAssemblyBaseline',
                        '--disable-web-security',
                        '--allow-running-insecure-content',
                        '--no-sandbox',
                        '--disable-setuid-sandbox',
                        '--disable-dev-shm-usage',
                        '--ignore-gpu-blacklist',
                        '--enable-gpu-rasterization',
                    ],
                },
            },
        },
    ],
});
