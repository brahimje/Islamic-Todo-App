# Production Deployment Checklist

## Pre-Release Checklist

### ✅ Phase 1: Configuration (COMPLETED)
- [x] Android manifest permissions configured
- [x] iOS Info.plist privacy descriptions added
- [x] macOS Info.plist updated
- [x] App name changed to "Islamic Todo"
- [x] ProGuard rules created
- [x] Keystore configuration guide created
- [x] Privacy Policy created
- [x] Terms of Service created
- [x] .gitignore updated for sensitive files
- [x] Critical code warnings fixed

### 🔧 Phase 2: Build Setup (ACTION REQUIRED)

#### Android Release Signing
1. **Generate Keystore** (DO THIS FIRST!)
   ```bash
   keytool -genkey -v -keystore ~/islamic-todo-release.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias islamic-todo
   ```
   - Store password securely in password manager
   - Keep keystore file in multiple secure locations

2. **Create key.properties**
   ```bash
   cd android
   nano key.properties
   ```
   Add:
   ```properties
   storePassword=YOUR_PASSWORD
   keyPassword=YOUR_PASSWORD
   keyAlias=islamic-todo
   storeFile=/Users/YOUR_USERNAME/islamic-todo-release.jks
   ```

3. **Test Release Build**
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

#### iOS/macOS Setup
1. **Apple Developer Account** ($99/year required)
   - Sign up at https://developer.apple.com
   - Complete profile setup

2. **Configure Signing in Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```
   - Select your team
   - Configure bundle identifier: `com.islamictodo.islamic-todo-app`
   - Enable automatic signing

3. **Test iOS Build**
   ```bash
   flutter build ios --release
   flutter build macos --release
   ```

### 📱 Phase 3: App Assets

#### App Icons
```bash
# Install dependencies
flutter pub get

# Generate icons
flutter pub run flutter_launcher_icons

# Generate splash screens
flutter pub run flutter_native_splash:create
```

**Verify Generated Assets:**
- Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Web: `web/icons/`

#### Required App Store Assets
Create the following for app stores:

**Screenshots (Required):**
- iPhone 6.7" (1290 x 2796): 3-10 screenshots
- iPhone 6.5" (1242 x 2688): 3-10 screenshots  
- iPad Pro 12.9" (2048 x 2732): 3-10 screenshots
- Android Phone (1080 x 1920): 2-8 screenshots
- Android Tablet (1920 x 1200): 1-8 screenshots

**Promotional Graphics:**
- Android Feature Graphic (1024 x 500)
- App Preview Video (optional but recommended)

**App Icon (Already have):**
- 1024 x 1024 PNG (no transparency)

### 🧪 Phase 4: Testing

#### Manual Testing
- [ ] Test on real Android device (not just emulator)
- [ ] Test on real iOS device (not just simulator)
- [ ] Test all prayer time calculations
- [ ] Test all notification types
- [ ] Test location permissions
- [ ] Test backup/restore functionality
- [ ] Test task creation and completion
- [ ] Test calendar views
- [ ] Test progress tracking
- [ ] Test settings changes
- [ ] Test onboarding flow
- [ ] Test app on different screen sizes
- [ ] Test RTL support (when implemented)
- [ ] Test offline functionality
- [ ] Test background notifications

#### Device Coverage
Test on:
- [ ] Old Android device (Android 8-9)
- [ ] Mid-range Android (Android 11-12)
- [ ] Latest Android (Android 13+)
- [ ] iPhone (iOS 14-15)
- [ ] iPhone (iOS 16+)
- [ ] iPad
- [ ] Different screen sizes

#### Edge Cases
- [ ] Test with location denied
- [ ] Test with notifications denied
- [ ] Test with airplane mode
- [ ] Test during actual prayer times
- [ ] Test across midnight (day transition)
- [ ] Test across time zones
- [ ] Test with large amounts of data (100+ tasks)
- [ ] Test app updates (data migration)

### 📝 Phase 5: Store Preparation

#### App Store Connect (iOS)
1. **Create App Listing**
   - Log in to App Store Connect
   - Create new app
   - Bundle ID: `com.islamictodo.islamic-todo-app`
   - SKU: `islamic-todo-001`

2. **App Information**
   - Name: Islamic Todo
   - Subtitle: Prayer & Task Management
   - Category: Productivity, Lifestyle
   - Privacy Policy URL: (Upload PRIVACY_POLICY.md to website)
   - Support URL: (GitHub Issues or website)

3. **Description** (4000 chars max)
   ```
   Islamic Todo - Your Spiritual Productivity Companion
   
   Seamlessly integrate Islamic practices with daily productivity. Track prayers, manage tasks, and maintain spiritual goals all in one minimalist app.
   
   FEATURES:
   • 📿 Prayer Tracking - Never miss Fajr, Dhuhr, Asr, Maghrib, Isha
   • 🕌 Nafila Prayers - Track Tahajjud, Duha, Witr, and more
   • ✅ Task Management - Organize your daily activities
   • 📅 Smart Calendar - Visual progress tracking
   • 📊 Progress Analytics - Monitor streaks and achievements
   • 🌙 Daily Challenges - Adkar, Quran reading, Tasbih counter
   • 🔔 Smart Reminders - Prayer and task notifications
   • 📍 Location-Based - Accurate prayer times for your area
   
   And more...
   ```

4. **Keywords** (100 chars max)
   ```
   prayer,islam,muslim,salah,quran,productivity,tasks,reminder,adhan,islamic,dua,nafila
   ```

5. **What's New** (4000 chars max)
   ```
   Version 1.0.0
   • Initial release
   • Prayer time tracking
   • Task management
   • Daily challenges
   • Progress tracking
   ```

#### Google Play Console (Android)
1. **Create App**
   - Sign in to Play Console
   - Create app
   - App name: Islamic Todo
   - Language: English (add Arabic later)

2. **Store Listing**
   - Short description (80 chars):
     ```
     Track prayers, manage tasks, and achieve spiritual goals with Islamic Todo
     ```
   
   - Full description (4000 chars): (Same as iOS)
   
   - App category: Productivity
   - Tags: Islam, Prayer, Muslim, Productivity

3. **Content Rating**
   - Complete questionnaire
   - Target: Everyone
   - No sensitive content

4. **Privacy Policy**
   - Upload privacy policy URL
   - Complete Data Safety form:
     - Location: Yes (for prayer times)
     - No data shared with third parties
     - No data collected for advertising

### 🔒 Phase 6: Security Review

#### Code Security
- [ ] No hardcoded API keys
- [ ] No sensitive data in logs
- [ ] Proper error handling (no crashes)
- [ ] Input validation on all forms
- [ ] SQL injection protection (using Hive)
- [ ] Secure backup file handling

#### Permission Audit
- [ ] Only request necessary permissions
- [ ] Explain permission usage before requesting
- [ ] Handle permission denials gracefully
- [ ] No background location tracking (except for prayer calculations)

#### Data Protection
- [ ] Local data encrypted (Hive)
- [ ] No plaintext password storage
- [ ] Secure backup/restore process
- [ ] User data deletion on uninstall

### 📊 Phase 7: Analytics & Monitoring (Optional)

#### Crash Reporting
```yaml
# Add to pubspec.yaml (optional)
dependencies:
  sentry_flutter: ^7.0.0
  # OR
  firebase_crashlytics: ^3.4.0
```

#### Analytics
```yaml
# Optional analytics
dependencies:
  firebase_analytics: ^10.7.0
```

**Privacy Note:** If adding analytics, update Privacy Policy!

### 🚀 Phase 8: Release

#### Beta Testing
1. **TestFlight (iOS)**
   - Upload build to App Store Connect
   - Add internal testers
   - Get 10-50 users to test
   - Collect feedback
   - Fix critical bugs

2. **Google Play Beta**
   - Upload AAB to Play Console
   - Create beta track
   - Add testers via email
   - Collect feedback

#### Production Release

**iOS Release:**
```bash
# Build release
flutter build ios --release

# Archive in Xcode
open ios/Runner.xcworkspace
# Product -> Archive -> Upload to App Store
```

**Android Release:**
```bash
# Build release bundle
flutter build appbundle --release

# Upload to Play Console
# Release -> Production -> Create new release
```

### 📱 Phase 9: Post-Release

#### Monitor
- [ ] Check crash reports daily (first week)
- [ ] Monitor app store reviews
- [ ] Respond to user feedback
- [ ] Track download numbers
- [ ] Monitor performance metrics

#### Marketing
- [ ] Create GitHub release
- [ ] Post on social media
- [ ] Share in Muslim tech communities
- [ ] Create demo video
- [ ] Write blog post
- [ ] Submit to app directories

### 🔄 Phase 10: Maintenance

#### Regular Updates
- [ ] Fix bugs reported by users
- [ ] Update dependencies monthly
- [ ] Add requested features
- [ ] Improve performance
- [ ] Update for new OS versions
- [ ] Maintain prayer time accuracy

#### Version Numbering
- Major (1.0.0): Breaking changes
- Minor (1.1.0): New features
- Patch (1.0.1): Bug fixes

---

## Quick Commands Reference

```bash
# Get dependencies
flutter pub get

# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screen
flutter pub run flutter_native_splash:create

# Analyze code
flutter analyze

# Fix formatting
dart fix --apply

# Run tests
flutter test

# Build Android
flutter build apk --release                 # APK
flutter build appbundle --release          # AAB (recommended)

# Build iOS
flutter build ios --release
flutter build ipa --release

# Build macOS
flutter build macos --release

# Build Windows
flutter build windows --release

# Clean build
flutter clean && flutter pub get
```

---

## Important Notes

1. **NEVER commit:**
   - `android/key.properties`
   - `*.jks` or `*.keystore` files
   - API keys or secrets
   - Passwords

2. **Backup these files securely:**
   - Keystore file
   - Keystore passwords
   - Apple Developer certificates
   - Release signing credentials

3. **Version Management:**
   - Update version in `pubspec.yaml`
   - Update build number for each release
   - Maintain CHANGELOG.md

4. **Legal Requirements:**
   - Privacy Policy must be accessible
   - Terms of Service must be clear
   - Content ratings must be accurate
   - Age restrictions must be appropriate

---

## Support Contacts

- **Technical Issues**: GitHub Issues
- **App Store**: App Store Connect Support
- **Play Store**: Play Console Support
- **Users**: support@islamictodo.app

---

**May Allah accept this effort and make it beneficial for the Ummah! 🤲**
