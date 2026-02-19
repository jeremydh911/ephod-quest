# Deployment Guide for Twelve Stones

## Platform Export Settings

This document provides comprehensive deployment instructions for exporting *Twelve Stones* to all target platforms using Godot 4.3.

---

## Prerequisites

### Godot 4.3 Setup
- **Godot Version:** 4.3+ (Standard or .NET if using C# scripts)
- **Export Templates:** Download from Godot Engine website or within editor
- **Installation:** Editor → Manage Export Templates → Download and Install

### Platform-Specific Requirements
Each platform requires specific SDKs, certificates, and tools. Details below.

---

## iOS Deployment

### Requirements
- **macOS Computer:** Xcode requires macOS
- **Xcode:** Version 14.0 or later
- **Apple Developer Account:** $99/year for App Store distribution
- **Provisioning Profile:** Created in Apple Developer Portal
- **Certificates:** Development and Distribution certificates

### Export Settings in Godot

1. **Go to:** Project → Export → Add → iOS
2. **Configure:**

```
Application:
  - App Store Team ID: [Your Team ID]
  - Bundle Identifier: com.ephod-quest.twelvestones
  - Display Name: Twelve Stones
  - Short Version: 1.0
  - Version: 1.0.0

Icons:
  - iPhone App Icon (120x120): res://assets/icons/ios_120.png
  - iPad App Icon (152x152): res://assets/icons/ios_152.png
  - App Store Icon (1024x1024): res://assets/icons/ios_1024.png

Landscape:
  - Supported: Yes
  - Launch Screens: Custom or default

Capabilities:
  - Push Notifications: No (unless adding)
  - Game Center: Optional
  - In-App Purchases: Optional

Privacy:
  - Camera Usage Description: (If needed)
  - Microphone Usage Description: (If needed)
  - Network Usage Description: "For multiplayer features"

Architectures:
  - ARM64: Yes (iPhone 5s and later)
```

### Build Process

```bash
# Export from Godot creates an Xcode project
# Open the exported .xcodeproj in Xcode

# In Xcode:
# 1. Select your development team
# 2. Configure signing certificates
# 3. Set deployment target: iOS 13.0+
# 4. Build and test on simulator or device
# 5. Archive for App Store submission

# TestFlight Distribution:
# Product → Archive → Distribute App → App Store Connect
```

### App Store Submission Checklist
- [ ] App icons for all required sizes
- [ ] Screenshots (6.5" and 5.5" displays)
- [ ] App description and keywords
- [ ] Age rating: 4+ or appropriate rating
- [ ] Privacy policy URL (required)
- [ ] Support URL
- [ ] Marketing materials
- [ ] App review information

---

## Android Deployment

### Requirements
- **Android SDK:** API Level 21+ (Android 5.0)
- **Android SDK Command-line Tools**
- **JDK:** Version 11 or 17
- **Keystore:** For signing the APK/AAB

### Creating a Keystore (First Time)

```bash
keytool -genkeypair -v \
  -keystore twelvestones.keystore \
  -alias twelvestones \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass [YOUR_PASSWORD] \
  -keypass [YOUR_PASSWORD] \
  -dname "CN=Ephod Quest, OU=Dev, O=Ephod Quest, L=City, ST=State, C=US"

# Keep this file SECURE and BACKED UP!
```

### Export Settings in Godot

1. **Go to:** Project → Export → Add → Android
2. **Configure:**

```
Custom Build:
  - Use Custom Build: Yes (for plugins/permissions)
  - Min SDK: 21
  - Target SDK: 34 (or latest)

Gradle Build:
  - Gradle Build Directory: (Auto-generated)

Keystore:
  - Debug Keystore: (Auto-generated debug key)
  - Debug Keystore User: androiddebugkey
  - Debug Keystore Password: android
  - Release Keystore: /path/to/twelvestones.keystore
  - Release Keystore User: twelvestones
  - Release Keystore Password: [YOUR_PASSWORD]

Package:
  - Unique Name: com.ephodquest.twelvestones
  - Version Name: 1.0.0
  - Version Code: 1 (increment for each release)

Screen:
  - Orientation: Landscape or Sensor Landscape
  - Support Small: Yes
  - Support Normal: Yes
  - Support Large: Yes
  - Support XLarge: Yes

Launcher Icons:
  - Main 192x192: res://assets/icons/android_192.png
  - Adaptive Foreground 432x432: res://assets/icons/android_432.png
  - Adaptive Background 432x432: res://assets/icons/android_432_bg.png

Permissions:
  - Internet: Yes (for multiplayer)
  - Network State: Yes
  - Write External Storage: No (unless saving to external)
  - Read External Storage: No

Graphics:
  - OpenGL: ES 3.0

Architectures:
  - ARM64-v8a: Yes
  - ARMv7: Yes (for older devices)
  - x86_64: Optional (for emulators)
```

### Build Process

```bash
# Export APK (For testing or non-Play Store distribution)
# Project → Export → Android → Export Project
# Choose: APK
# Output: twelvestones_v1.0.0.apk

# Export AAB (For Google Play Store)
# Project → Export → Android → Export Project
# Choose: Android App Bundle
# Output: twelvestones_v1.0.0.aab

# Test installation:
adb install twelvestones_v1.0.0.apk
```

### Google Play Console Submission
- [ ] Create app in Play Console
- [ ] Upload AAB file
- [ ] Fill out store listing (title, description, screenshots)
- [ ] Content rating questionnaire
- [ ] Privacy policy URL
- [ ] Target audience and content (COPPA compliance)
- [ ] Store graphics (feature graphic, screenshots)
- [ ] Submit for review

---

## macOS Deployment

### Requirements
- **macOS Computer:** For building and testing
- **Xcode Command Line Tools:** `xcode-select --install`
- **Apple Developer Account:** For distribution (optional for development)
- **Notarization:** Required for macOS 10.15+ distribution

### Export Settings in Godot

1. **Go to:** Project → Export → Add → macOS
2. **Configure:**

```
Application:
  - Bundle Identifier: com.ephodquest.twelvestones
  - Name: Twelve Stones
  - Info: Twelve Stones Biblical Game
  - Version: 1.0.0
  - Copyright: © 2026 Ephod Quest

Binary Format:
  - Universal (x86_64 + ARM64): Recommended for M1/M2 support
  - x86_64: For Intel Macs only
  - ARM64: For Apple Silicon only

Icon:
  - Application Icon (1024x1024): res://icon.icns
  - (Convert PNG to ICNS using Icon Composer or online tools)

Codesign:
  - Enabled: Yes (for distribution)
  - Identity: "Developer ID Application: [Your Name] ([Team ID])"
  - Certificate File: [Path to .p12 certificate]
  - Certificate Password: [Certificate password]
  - Provisioning Profile: [Optional for Mac App Store]

Notarization:
  - Apple ID: [Your Apple ID]
  - Password: [App-specific password]
  - Team ID: [Your Team ID]
  - Apple ID Provider: [If multiple teams]

Entitlements:
  - App Sandbox: Required for Mac App Store
  - Network Client: Yes (for multiplayer)
  - Network Server: Yes (if hosting)

Privacy:
  - Network Description: "For multiplayer features"
```

### Build Process

```bash
# Export from Godot creates .app or .dmg

# For direct distribution (outside App Store):
# 1. Export as .app
# 2. Code sign:
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: [Your Name]" \
  TwelveStones.app

# 3. Create DMG (optional):
hdiutil create -volname "Twelve Stones" \
  -srcfolder TwelveStones.app \
  -ov -format UDZO TwelveStones.dmg

# 4. Notarize:
xcrun notarytool submit TwelveStones.dmg \
  --apple-id [YOUR_APPLE_ID] \
  --password [APP_PASSWORD] \
  --team-id [TEAM_ID] \
  --wait

# 5. Staple:
xcrun stapler staple TwelveStones.dmg
```

### Mac App Store Submission
- [ ] Use Mac App Store export preset
- [ ] Enable App Sandbox
- [ ] Configure entitlements
- [ ] Upload via Xcode or Transporter
- [ ] Fill out App Store Connect listing

---

## Windows Deployment

### Requirements
- **Windows PC or Wine/CrossOver on macOS/Linux:** For testing
- **Rcedit:** For embedding icon and metadata (optional)
- **No Developer Account Required:** For direct distribution

### Export Settings in Godot

1. **Go to:** Project → Export → Add → Windows Desktop
2. **Configure:**

```
Binary Format:
  - 64-bit: Yes (primary)
  - 32-bit: Optional (for older systems)
  - Embed PCK: Yes (single executable)

Executable:
  - Icon: res://icon.ico (convert from PNG using online tools)
  - File Description: Twelve Stones Biblical Game
  - Product Name: Twelve Stones
  - File Version: 1.0.0.0
  - Product Version: 1.0.0.0
  - Company Name: Ephod Quest
  - Copyright: © 2026 Ephod Quest
  - Trademarks: Twelve Stones™

Console Window:
  - Enable Console: No (disable for release)

Resources:
  - Embed PCK: Yes

Code Signing:
  - Certificate: Optional (improves trust)
  - Password: [Certificate password]
  - Timestamp Server: http://timestamp.comodoca.com/authenticode
```

### Build Process

```bash
# Export from Godot creates .exe

# For distribution:
# 1. Export as TwelveStones.exe
# 2. Test on Windows
# 3. Create installer (optional):

# Using Inno Setup (free):
# Create script for installer with:
# - Installation directory
# - Desktop shortcut
# - Start menu entry
# - Uninstaller

# Using NSIS (free alternative)
# Or zip for portable version
```

### Distribution Options
- **Steam:** Requires Steamworks SDK integration
- **Itch.io:** Direct upload
- **Epic Games Store:** Submit via developer portal
- **Microsoft Store:** Requires packaging as MSIX
- **Direct Download:** Host on your website

---

## Ubuntu / Linux Deployment

### Requirements
- **Linux System:** For building and testing
- **No Special Tools Required:** Godot exports natively

### Export Settings in Godot

1. **Go to:** Project → Export → Add → Linux/X11
2. **Configure:**

```
Binary Format:
  - 64-bit: Yes (primary)
  - 32-bit: Optional (for older systems)
  - Embed PCK: Yes

Executable:
  - Icon: res://icon.png (for .desktop file)

Resources:
  - Embed PCK: Yes

Texture Format:
  - ETC2: For better compatibility
```

### Build Process

```bash
# Export from Godot creates binary

# Set executable permissions:
chmod +x TwelveStones.x86_64

# Create .desktop file for desktop integration:
cat > twelvestones.desktop << EOF
[Desktop Entry]
Name=Twelve Stones
Comment=Biblical Adventure Game
Exec=/path/to/TwelveStones.x86_64
Icon=/path/to/icon.png
Terminal=false
Type=Application
Categories=Game;Education;
EOF

# For distribution:
# 1. Create tar.gz:
tar -czf TwelveStones_v1.0.0_linux64.tar.gz TwelveStones.x86_64 icon.png

# 2. Or create .deb package:
# Use dpkg-deb with proper DEBIAN/control file

# 3. Or create AppImage:
# Use appimagetool for universal Linux compatibility

# 4. Or Flatpak/Snap:
# More complex but better integration
```

### Distribution Options
- **Steam:** Linux support
- **Itch.io:** Direct upload
- **Flathub:** Flatpak distribution
- **Snap Store:** Snap package distribution
- **Direct Download:** tar.gz or AppImage

---

## Web (HTML5) Deployment (Optional)

### Requirements
- **Web Server:** For hosting
- **HTTPS:** Required for some features
- **CORS Configuration:** For external resources

### Export Settings

```
Custom HTML Shell: Optional
Export Type: Regular or Threads (experimental)
Head Include: (Custom HTML/JS if needed)

Limitations:
- Large initial download
- No multiplayer without WebRTC
- Performance varies by browser
- No local file access
```

---

## Cross-Platform Testing Checklist

Before each release, test on all platforms:

### Functionality Testing
- [ ] Game launches successfully
- [ ] All menus navigate correctly
- [ ] Save/load system works
- [ ] All 12 mini-games function
- [ ] Scripture display correct
- [ ] Audio plays properly
- [ ] Multiplayer connects (if applicable)

### Performance Testing
- [ ] 60 FPS maintained
- [ ] Load times under 3 seconds
- [ ] Memory usage acceptable
- [ ] Battery life reasonable (mobile)
- [ ] No crashes during extended play

### Compatibility Testing
- [ ] iOS 13+ (various devices)
- [ ] Android 5.0+ (various devices)
- [ ] macOS 10.15+ (Intel and Apple Silicon)
- [ ] Windows 10/11 (64-bit and 32-bit)
- [ ] Ubuntu 20.04+ and other Linux distros

### Localization Testing (If applicable)
- [ ] Text displays correctly
- [ ] Hebrew characters render properly
- [ ] UI adjusts for text length
- [ ] Audio sync with text

---

## Release Checklist

Before submitting to any store:

- [ ] Version numbers updated everywhere
- [ ] Icons for all required sizes
- [ ] Screenshots and promotional materials
- [ ] Privacy policy published
- [ ] Support email/website active
- [ ] COPPA compliance verified
- [ ] Age ratings obtained
- [ ] Legal review completed
- [ ] Final QA testing passed
- [ ] Backup of build and source code

---

## Godot 4.3 Specific Notes

### Breaking Changes from Godot 3.x
- Scene format changed (not compatible)
- GDScript syntax updates
- New rendering backend (Vulkan)
- Export templates different

### Optimization Tips
- Use Vulkan for better performance
- Enable threaded loading
- Compress textures appropriately
- Use PCK embedding for cleaner distribution
- Profile on target devices

### Known Issues
- Check Godot GitHub for platform-specific bugs
- Export templates may need updates
- Some plugins might not be compatible yet

---

## Continuous Integration / Continuous Deployment

### Automated Builds (Optional)

```yaml
# Example GitHub Actions for automated exports
name: Export Game
on: [push, pull_request]

jobs:
  export:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Export Android
        uses: godotengine/godot-ci@master
        with:
          preset: Android
      # Add steps for other platforms
```

---

## Support and Resources

- **Godot Documentation:** https://docs.godotengine.org/en/stable/
- **Export Documentation:** https://docs.godotengine.org/en/stable/tutorials/export/
- **Community Forums:** https://forum.godotengine.org/
- **Discord:** Official Godot Discord for real-time help

---

*Document Version: 1.0*  
*Last Updated: 2026-02-18*  
*Godot Version: 4.3*  
*Next Update: After platform testing*
