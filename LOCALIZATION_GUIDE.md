# 🌍 Localization System Guide

## Overview
The Islamic Todo App supports multiple languages using Flutter's official localization system. Currently supported:
- **English** (en) - LTR
- **Arabic** (ar) - RTL

Future support can be easily added:
- Urdu (ur)
- Indonesian (id)
- French (fr)
- Turkish (tr)
- And more...

---

## 📝 Adding/Modifying Translations

### 1. **Modify ARB Files**
Translations are stored in `lib/l10n/`:
- `app_en.arb` - English translations
- `app_ar.arb` - Arabic translations

Each string has this format:
```json
{
  "keyName": "English text",
  "@keyName": {
    "description": "What this string is used for"
  }
}
```

Example in Arabic:
```json
{
  "appName": "مهام إسلامية",
  "@appName": {
    "description": "اسم التطبيق"
  }
}
```

### 2. **Generate Localization Files**
After modifying ARB files, regenerate the Dart classes:

```bash
flutter gen-l10n
```

This creates:
- `lib/generated_files/l10n/app_localizations.dart` (base class)
- `lib/generated_files/l10n/app_localizations_en.dart` (English)
- `lib/generated_files/l10n/app_localizations_ar.dart` (Arabic)

---

## 🎯 Using Localized Strings in Code

### Option 1: Using Extension (Recommended)
```dart
import 'package:islamic_todo_app/core/extensions/localization_extensions.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appName),  // Simple and clean!
      ),
      body: Column(
        children: [
          Text(context.l10n.todaysTasks),
          Text(context.l10n.noTasks),
        ],
      ),
    );
  }
}
```

### Option 2: Direct Access
```dart
import 'package:islamic_todo_app/generated_files/l10n/app_localizations.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(l10n.appName);
  }
}
```

### Option 3: Avoid at Module Level
```dart
// ❌ DON'T DO THIS - Can't access context outside build()
final String title = AppLocalizations.of(context)?.appName ?? '';

// ✅ DO THIS - Access strings within build()
@override
Widget build(BuildContext context) {
  return Text(context.l10n.appName);
}
```

---

## 🔤 Locale Detection & RTL Support

### Check Current Language
```dart
bool isArabic = context.isArabic;
if (isArabic) {
  // Show Arabic-specific UI
} else {
  // Show English UI
}
```

### Auto-Handled RTL
Flutter automatically mirrors layouts for RTL languages. But you can explicitly set direction:

```dart
Directionality(
  textDirection: context.textDirection,
  child: Row(
    children: [...],
  ),
)
```

---

## ✨ Supported Locale Properties

### All Available Strings  
Access via `context.l10n.<property>`:

#### App Info
- `appName` - "Islamic Todo"
- `appTagline` - "Harmonize your spiritual and daily life"

#### Navigation
- `navHome`, `navCalendar`, `navProgress`, `navSettings`, `navChallenges`

#### Prayer Names (5 Fard)
- `fajr`, `dhuhr`, `asr`, `maghrib`, `isha`
- `sunrise` - Sunrise time

#### Nafilah Prayers
- `tahajjud`, `doha`, `ishraq`, `awwabin`, `witr`, `tahiyyatMasjid`

#### Task Management
- `todaysTasks`, `addTask`, `tasksCompleted`, `allTasksCompleted`, `noTasks`
- `taskTitle`, `taskDescription`, `taskDeadline`, `taskPriority`, `taskCategory`
- `saveTask`, `deleteTask`, `editTask`

#### Priority & Categories
- `priorityHigh`, `priorityMedium`, `priorityLow`
- `categoryWork`, `categoryPersonal`, `categoryFamily`, `categoryHealth`, `categoryLearning`, `categoryOther`

#### Common Actions
- `save`, `cancel`, `delete`, `edit`, `done`, `confirm`, `ok`

#### Messages
- `taskAdded`, `taskUpdated`, `taskDeleted`, `prayerMarked`, `settingsSaved`
- `loading`, `error`, `retry`, `noData`

---

## 🌐 Adding a New Language

### Step 1: Create New ARB File
Create `lib/l10n/app_ur.arb` for Urdu:

```json
{
  "@@locale": "ur",
  "appName": "اسلامی ٹوڈو",
  "appTagline": "اپنی روحانی اور روزمرہ کی زندگی میں ہماہنگی پیدا کریں",
  ...copy all other keys...
}
```

### Step 2: Add to Configuration
Update `l10n.yaml`:
```yaml
preferred-supported-locales: [en, ar, ur]
```

### Step 3: Regenerate
```bash
flutter gen-l10n
```

The system automatically:
- ✅ Generates `app_localizations_ur.dart`
- ✅ Updates `app_localizations.dart` with new locale
- ✅ Adds Urdu to `supportedLocales` list
- ✅ Enables language selection in settings

---

## 🛠️ System Configuration

### l10n.yaml
```yaml
arb-dir: lib/l10n                           # Where ARB files are
template-arb-file: app_en.arb               # Template (English)
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/generated_files/l10n
preferred-supported-locales: [en, ar]       # Add more as needed
```

### pubspec.yaml
Already configured:
```yaml
flutter:
  generate: true                              # Enable generation

# Dependencies (required)
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.0                               # Pinned by flutter_localizations
```

---

## 🔍 Migration Guide: From AppStrings

### Before (AppStrings)
```dart
import 'package:islamic_todo_app/core/constants/app_strings.dart';

Text(AppStrings.appName)
```

### After (Localization)
```dart
import 'package:islamic_todo_app/core/extensions/localization_extensions.dart';

Text(context.l10n.appName)
```

### Conversion Checklist
- [ ] Remove `import 'app_strings.dart'`
- [ ] Add `import 'localization_extensions.dart'`
- [ ] Replace `AppStrings.` with `context.l10n.`
- [ ] Ensure code is in widget's `build()` method
- [ ] Test both English and Arabic modes

---

## 📱 Testing Localization

### Change Language in Settings
(Once setting is implemented)

### Force Language in Code
```dart
// For testing, temporarily force Arabic
MaterialApp(
  locale: const Locale('ar'),  // Force Arabic
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
)
```

### Device Settings
- Android: Settings > Language > Select language
- iOS: Settings > General > Language  
- macOS: System Preferences > Language & Region

---

## ✅ Checklist for Implementation

### Phase 1: Infrastructure (DONE ✓)
- [x] Create `lib/l10n/` directory
- [x] Create `app_en.arb` and `app_ar.arb`
- [x] Set up `l10n.yaml` configuration
- [x] Generate localization classes
- [x] Create localization extension helpers
- [x] Update `main.dart` with delegates/locales
- [x] Update `pubspec.yaml` with `flutter_localizations`

### Phase 2: Widget Migration (In Progress)
- [ ] Update `home_screen.dart`
- [ ] Update `add_edit_task_screen.dart`
- [ ] Update `settings_screen.dart`
- [ ] Update `calendar_screen.dart`
- [ ] Update `progress_screen.dart`
- [ ] Update `challenges_screen.dart`
- [ ] Update all dialog/alert strings

### Phase 3: Language Selection (Pending)
- [ ] Add language picker to settings
- [ ] Store selected language in SharedPreferences
- [ ] Apply language on app restart
- [ ] Show flag icons for languages

### Phase 4: Additional Languages (Optional)
- [ ] Add Urdu translation
- [ ] Add Indonesian translation
- [ ] Add French translation
- [ ] Add Turkish translation

---

## 🐛 Troubleshooting

### Issue: "No instance of AppLocalizations"
**Cause**: Using localization outside `build()` method
**Fix**: Move code inside `build()` or create a variable inside method

### Issue: Arabic text appears LTR
**Cause**: Don't need to fix! Flutter automatically handles RTL
**Solution**: Verify in device settings that Arabic locale is set

### Issue: Missing translation in new language
**Cause**: Didn't copy all keys from template
**Fix**: Run `flutter gen-l10n` in verbose mode to find missing keys

### Issue: "Build failed" after modifying ARB
**Cause**: Syntax error in JSON file
**Fix**: Validate JSON format, check commas and quotes

---

## 📚 Resources
- [Flutter Localization Documentation](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [Intl Package](https://pub.dev/packages/intl)
- [ARB File Format](https://github.com/google/app-resource-bundle/wiki)

---

## 📝 Code Examples

### Example 1: Localized List
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final priorities = [
      context.l10n.priorityHigh,
      context.l10n.priorityMedium,
      context.l10n.priorityLow,
    ];
    
    return ListView.builder(
      itemCount: priorities.length,
      itemBuilder: (context, index) => Text(priorities[index]),
    );
  }
}
```

### Example 2: Localized Dialogs
```dart
void _showDeleteConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.l10n.deleteTask),
      content: Text(context.l10n.confirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            // Delete logic
            Navigator.pop(ctx);
          },
          child: Text(context.l10n.delete),
        ),
      ],
    ),
  );
}
```

### Example 3: Locale-Aware Formatting
```dart
String formatPrayerTime(BuildContext context) {
  final time = DateTime.now();
  final isArabic = context.isArabic;
  
  return isArabic
    ? '${time.hour}:${time.minute.toString().padLeft(2, '0')} ${context.l10n.fajr}'
    : '${time.hour}:${time.minute.toString().padLeft(2, '0')} ${context.l10n.fajr}';
}
```

---

**Happy Coding! 🚀**
