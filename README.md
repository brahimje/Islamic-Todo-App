# Islamic Todo App

A comprehensive Islamic productivity app that helps Muslims organize their daily prayers, tasks, and spiritual activities. Built with Flutter for cross-platform support.

---
**Note:** This is version 1.0. The app is still under active development—many features and fixes are planned for future updates. Core functions are working, and releases will be pushed as improvements are made.
---

## Features

- **Prayer Management**: Track daily prayers with accurate Islamic prayer times
- **Task Scheduling**: Organize daily tasks with smart scheduling and reminders
- **Islamic Challenges**: Daily Adkar (remembrances), Quran reading, and spiritual goals
- **Progress Tracking**: Visual progress bars, streaks, and achievements
- **Notifications**: Timely reminders for prayers and tasks
- **Backup & Restore**: Secure data backup and restoration
- **Multi-platform**: Works on Android, iOS, macOS, and Windows

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio or Xcode for platform-specific development

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/islamic_todo_app.git
   cd islamic_todo_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building for Production

#### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### macOS
```bash
flutter build macos --release
```

#### Windows
```bash
flutter build windows --release
```

## Configuration

### Prayer Times
The app uses accurate Islamic prayer time calculations based on your location. Ensure location permissions are granted for precise times.

### Notifications
Enable notifications for prayer reminders and task alerts.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Privacy Policy

This app collects minimal data necessary for functionality:
- Location data for prayer time calculations (optional)
- User preferences and app data (stored locally)
- No personal data is transmitted to external servers

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@islamictodo.com or create an issue on GitHub.
