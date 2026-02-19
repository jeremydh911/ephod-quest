# Deployment Checklist for Twelve Stones: Ephod Quest

## General Requirements
- [x] App is fully functional with no code errors.
- [x] MIT License added (LICENSE file).
- [x] Privacy Policy created (PRIVACY_POLICY.md).
- [x] Credits added to README.md: Shawna Harlin (Designer), Jeremiah D Harlin (Developer).
- [x] Biblical content under fair use (educational, non-commercial).
- [x] No harmful content (no violence, appropriate for all ages).
- [x] Export presets configured for Android, iOS, Web, Windows, Linux.

## Android (Google Play Store)
- [x] Package name: org.twelvestones.ephod
- [x] Version: 1.0.0 (code: 1)
- [x] Min SDK: 24, Target SDK: 34
- [x] Permissions: INTERNET, ACCESS_NETWORK_STATE
- [x] Signed APK required (create keystore if needed).
- [ ] Icons: Add PNG files (192x192 main, 432x432 adaptive foreground/background) to assets/ and update paths in export_presets.cfg. (Placeholder created; replace with actual images.)
- [ ] Screenshots: Capture 2-8 screenshots (phone/tablet, various scenes). (Note: Run game in Godot, use screenshot tool or device.)
- [ ] Store Listing:
  - Title: Twelve Stones: Ephod Quest
  - Short Description: Biblical adventure with 12 tribes, collect stones, memorize scripture.
  - Full Description: From README.md
  - Category: Education or Games > Adventure
  - Age Rating: Everyone (PEGI 3 or ESRB E)
  - Privacy Policy URL: Link to PRIVACY_POLICY.md hosted online. (Host on GitHub Pages: https://jeremydh911.github.io/ephod-quest/PRIVACY_POLICY.md)
- [ ] Donations: Include in description: "Support us voluntarily at ko-fi.com/ephodquest or paypal.me/ephodquest"
- [ ] Developer Account: $25 one-time fee.
- [ ] Test on real Android device (min SDK 24).
- [ ] Upload APK/AAB, submit for review (1-7 days).

## iOS (Apple App Store)
- [x] Bundle ID: org.twelvestones.ephod
- [x] Version: 1.0.0
- [x] Targeted Device Family: iPhone + iPad
- [x] Copyright: © Twelve Stones Team
- [ ] Icons: Add PNG files (1024x1024 app icon) to assets/ and update path in export_presets.cfg. (Placeholder created; replace with actual images.)
- [ ] Screenshots: Capture 5-10 screenshots (iPhone/iPad, various sizes). (Note: Run game in Godot, use screenshot tool or device.)
- [ ] Store Listing:
  - Name: Twelve Stones: Ephod Quest
  - Subtitle: Biblical Co-op Adventure
  - Description: From README.md
  - Category: Games > Adventure or Education
  - Age Rating: 4+ (Apple rating)
  - Privacy Policy URL: Link to PRIVACY_POLICY.md hosted online. (Host on GitHub Pages: https://jeremydh911.github.io/ephod-quest/PRIVACY_POLICY.md)
- [ ] Donations: Include in description: "Support us voluntarily at ko-fi.com/ephodquest or paypal.me/ephodquest"
- [ ] Developer Program: $99/year membership.
- [ ] Provisioning Profile: Create in Apple Developer account.
- [ ] Build on Mac with Xcode, test on device.
- [ ] Upload IPA via App Store Connect, submit for review (1-7 days).

## Additional Steps
- [x] Automated Testing: Playwright test script created for full game testing (see `tests/` folder).
- [ ] Host Privacy Policy online (e.g., GitHub Pages).
- [ ] Create Google Play Console and App Store Connect accounts.
- [ ] Prepare marketing: Website, social media, trailer.
- [ ] Beta testing: Use internal testing tracks.
- [ ] Compliance: Ensure no ads, in-app purchases (none), or data collection.
- [ ] Post-Launch: Monitor reviews, fix issues, plan updates.

## Notes
- Icons: Create simple placeholders (e.g., 12 stones symbol) using tools like GIMP or online generators.
- Screenshots: Run game, capture key scenes (menu, quest, finale).
- If rejected: Common reasons - missing privacy policy, inappropriate content (unlikely), or technical issues.
- Ready to build once icons are added!