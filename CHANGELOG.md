# Changelog

All notable changes to Islamic Todo App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Arabic localization (in progress)
- Cloud backup sync (planned)
- Widget support (planned)
- Dark mode theme option (planned)

## [1.0.0] - 2026-01-26

### 🎉 Initial Production Release

#### Added - Core Features
- **Prayer Management System**
  - Automatic prayer time calculation based on location
  - Support for 5 daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha)
  - Nafila prayer tracking (Tahajjud, Duha, Witr, Awwabin, etc.)
  - Prayer completion tracking with timestamps
  - Customizable prayer reminders
  - Qibla direction calculator
  - Multiple calculation methods (MWL, ISNA, Egypt, Makkah, etc.)
  - Madhab selection (Shafi, Hanafi)

- **Task Management**
  - Create, edit, and delete tasks
  - Schedule tasks with specific times
  - Set task priorities (high, medium, low)
  - Add categories and tags
  - Deadline tracking
  - Task completion tracking
  - Time-blocked scheduling between prayers
  - Free time slot discovery

- **Calendar System**
  - Daily timeline view with prayers and tasks
  - Weekly overview with completion indicators
  - Monthly calendar with progress tracking
  - Interactive date navigation
  - Visual completion status

- **Daily Challenges**
  - Tasbih counter (SubhanAllah, Alhamdulillah, Allahu Akbar)
  - Additional Adhkar tracking
  - Morning Adhkar (Adhkar As-Sabah)
  - Evening Adhkar (Adhkar Al-Masa)
  - After-prayer Adhkar
  - Before-sleep Adhkar
  - Quran reading tracker (Hizb-based)
  - Custom challenge goals
  - Completion tracking and streaks

- **Progress & Analytics**
  - Prayer streak tracking
  - Task completion statistics
  - Weekly and monthly progress charts
  - Completion rate percentages
  - Most productive time analysis
  - Achievement milestones
  - Visual progress indicators

- **Notifications**
  - Prayer time reminders
  - Customizable advance notifications (5-60 minutes)
  - Task deadline alerts
  - Background prayer time updates
  - Persistent notifications

- **Settings & Customization**
  - Location selection (auto or manual)
  - Prayer calculation method selection
  - Madhab preference
  - Notification preferences
  - 12/24 hour format
  - Week start day
  - Theme preferences

- **Data Management**
  - Local encrypted database (Hive)
  - Backup to file
  - Restore from backup
  - Export data
  - Import data
  - Data persistence across app restarts

- **User Experience**
  - Minimalist black & white design
  - Smooth animations
  - Onboarding flow for new users
  - Empty states with helpful guidance
  - Pull-to-refresh functionality
  - Responsive design for all screen sizes

#### Added - Platform Support
- iOS 13.0+
- Android 8.0+ (API level 26+)
- macOS 10.14+
- Windows 10+
- Web (PWA-ready)

#### Added - Technical
- Flutter 3.9+ compatibility
- Riverpod state management
- Go Router navigation
- Hive local database
- Google Fonts integration
- Prayer time calculations (Adhan package)
- Location services (Geolocator)
- Background task scheduling (WorkManager)
- Local notifications system
- File picker for backup/restore
- Share functionality

#### Security
- Android release signing configuration
- ProGuard rules for code obfuscation
- Encrypted local database
- Secure backup/restore mechanism
- Privacy-focused design (no data collection)
- No third-party tracking

#### Documentation
- Comprehensive README
- Privacy Policy
- Terms of Service
- Release signing guide
- Deployment checklist
- Contributing guidelines
- Code documentation

#### Legal & Compliance
- GDPR compliance
- CCPA compliance
- App Store guidelines compliance
- Google Play policies compliance
- Privacy descriptions for all permissions
- Transparent data handling

### Fixed
- Code analysis warnings (132 issues resolved)
- Unused imports removed
- Deprecated API usage updated
- Empty catch blocks addressed
- Null safety improvements
- Performance optimizations

### Changed
- App name from "islamic_todo_app" to "Islamic Todo"
- Improved notification system reliability
- Enhanced prayer time accuracy
- Optimized database queries
- Better error handling throughout app
- Improved onboarding experience

### Security
- Added Android manifest permissions with descriptions
- Added iOS privacy usage descriptions
- Added macOS privacy descriptions
- Implemented release signing for Android
- Created ProGuard rules for code protection
- Secured sensitive files in .gitignore

## Version Numbering

- **Major version (1.0.0)**: Breaking changes, major new features
- **Minor version (1.1.0)**: New features, backward compatible
- **Patch version (1.0.1)**: Bug fixes, minor improvements

## Upcoming Features (Roadmap)

### Version 1.1.0 (Planned)
- [ ] Arabic language support
- [ ] RTL layout support
- [ ] Additional Islamic calculation methods
- [ ] Custom prayer adjustment settings
- [ ] Widget support (iOS & Android)
- [ ] Siri/Google Assistant shortcuts
- [ ] More Nafila prayer options

### Version 1.2.0 (Planned)
- [ ] Cloud backup sync (optional)
- [ ] Cross-device synchronization
- [ ] Dark mode theme
- [ ] Multiple theme options
- [ ] Custom color schemes
- [ ] Font size adjustments

### Version 1.3.0 (Planned)
- [ ] Enhanced Quran reading features
- [ ] Hadith of the day
- [ ] Dua collections
- [ ] Islamic calendar integration
- [ ] Ramadan special features
- [ ] Hajj preparation tools

### Version 2.0.0 (Future)
- [ ] Community features (optional)
- [ ] Prayer time sharing
- [ ] Mosque finder
- [ ] Qibla AR view
- [ ] Advanced analytics
- [ ] Habit tracking

## Support

For bug reports and feature requests, please use:
- **GitHub Issues**: https://github.com/brahimje/Islamic-Todo-App/issues
- **Email**: support@islamictodo.app

## Contributors

See [CONTRIBUTORS.md](CONTRIBUTORS.md) for a list of contributors.

---

**JazakAllahu Khairan** for using Islamic Todo! May Allah accept our efforts. 🤲

[Unreleased]: https://github.com/brahimje/Islamic-Todo-App/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/brahimje/Islamic-Todo-App/releases/tag/v1.0.0
